const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    var count: u64 = 0;
    while (input_iter.next()) |line| {
        print("{s}\n", .{line});
        var first_secret_int = try std.fmt.parseInt(u64, line, 10);
        for (0..2000) |_| {
            first_secret_int = get_next_secret(first_secret_int);
        }
        count += first_secret_int;
    }

    print("{d}", .{count});
}

test "get_turn_count" {
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
