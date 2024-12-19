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
    var patterns = std.ArrayList([]const u8).init(allocator);

    const first_line = input_iter.next().?;
    var first_line_iter = std.mem.tokenize(u8, first_line, ", ");

    while (first_line_iter.next()) |pattern| {
        try patterns.append(pattern);
    }

    //   _ = input_iter.next();

    var count: u64 = 0;
    while (input_iter.next()) |pattern| {
        print("{s}\n", .{pattern});
        var cache = std.AutoHashMap(usize, u64).init(allocator);
        count += try is_valid(&patterns, &cache, pattern, 0);
    }

    print("{}\n", .{count});
}

fn is_valid(
    patterns: *std.ArrayList([]const u8),
    cache: *std.AutoHashMap(usize, u64),
    pattern: []const u8,
    pos: usize,
) !u64 {
    const existing_result = cache.get(pos);

    if (existing_result != null) {
        return existing_result.?;
    }

    if (pattern.len == pos) return 1;

    var count: u64 = 0;

    for (patterns.items) |atom| {
        if (atom.len + pos > pattern.len) continue;

        const atom_valid = std.mem.eql(u8, atom, pattern[pos .. atom.len + pos]);

        if (!atom_valid) continue;

        count += try is_valid(patterns, cache, pattern, pos + atom.len);
    }

    try cache.put(pos, count);

    return count;
}
