const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const MyKey = struct {
    slice: []i64,
};

const MyKeyContext = struct {
    pub fn hash(_: MyKeyContext, key: MyKey) u32 {
        var h = std.hash.Fnv1a_32.init();
        h.update(std.mem.sliceAsBytes(key.slice));
        return h.final();
    }

    pub fn eql(_: MyKeyContext, a: MyKey, b: MyKey, _: usize) bool {
        return std.mem.eql(i64, a.slice, b.slice);
    }
};

pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    const LineData = std.ArrayHashMap(
        MyKey,
        u64,
        MyKeyContext,
        true,
    );

    const Data = std.ArrayList(LineData);

    var data = Data.init(allocator);
    var total_sequences = std.ArrayHashMap(
        MyKey,
        void,
        MyKeyContext,
        true,
    ).init(allocator);

    while (input_iter.next()) |line| {
        print("{s}\n", .{line});
        var first_secret_int = try std.fmt.parseInt(u64, line, 10);

        var secret_diffs = std.ArrayList(i64).init(allocator);
        var sequence = std.ArrayHashMap(
            MyKey,
            u64,
            MyKeyContext,
            true,
        ).init(allocator);

        var previous_char: ?u64 = null;
        for (0..20) |secret_number| {
            first_secret_int = get_next_secret(first_secret_int);
            print("{d}\n", .{first_secret_int});
            const first_digit = get_first_digit(first_secret_int);
            if (secret_number == 0) {
                previous_char = first_digit;
                continue;
            }

            try secret_diffs.append(@as(i64, @as(i64, @intCast(first_digit)) - @as(i64, @intCast(previous_char.?))));
            previous_char = first_digit;

            if (secret_diffs.items.len < 4) continue;
            const current = secret_diffs.items[(secret_diffs.items.len - 4)..secret_diffs.items.len];
            const key = MyKey{ .slice = current };

            try total_sequences.put(key, {});

            if (sequence.contains(key)) continue;

            try sequence.put(key, first_digit);
        }

        try data.append(sequence);
    }

    var count: u64 = 0;
    for (total_sequences.keys()) |sequence| {
        var potential: u64 = 0;
        for (data.items) |sequence_map| {
            potential += sequence_map.get(sequence) orelse 0;
        }

        if (potential > count) count = potential;
    }

    print("{d}\n", .{count});
}

test "get_first_digit" {
    try std.testing.expectEqual(get_first_digit(123), 3);
}

fn get_first_digit(value: u64) u64 {
    if (value < 10) return value;
    return value - ((value / 10) * 10);
}

test "get_next_secret" {
    try std.testing.expectEqual(get_next_secret(123), 15887950);
}

fn get_next_secret(value: u64) u64 {
    var res = mix(value * 64, value);
    res = prune(res);
    res = mix(res / 32, res);
    res = prune(res);
    res = mix(res * 2048, res);
    res = prune(res);
    return res;
}

test "test_mix" {
    try std.testing.expectEqual(mix(15, 42), 37);
}

fn mix(value: u64, secret: u64) u64 {
    return value ^ secret;
}

fn prune(value: u64) u64 {
    return value % 16777216;
}
