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

    var count: u16 = 0;
    while (input_iter.next()) |pattern| {
        const valid = try is_valid(&patterns, &pattern, 0);

        if (valid) count += 1;
    }

    print("{}\n", .{count});
}

fn is_valid(patterns: *std.ArrayList([]const u8), pattern: *[]const u8, pos: usize) !bool {
    // print("{d} {d}\n", .{ pos, pattern.len });
    if (pattern.len == pos) return true;

    for (patterns.items) |atom| {
        if (atom.len + pos > pattern.len) continue;

        const atom_valid = std.mem.eql(u8, atom, pattern[pos .. atom.len + pos]);
        //    print("{d}: {s} {s} {any}\n", .{ pos, pattern[pos .. atom.len + pos], atom, atom_valid });
        if (!atom_valid) continue;

        if (try is_valid(patterns, pattern, pos + atom.len)) return true;
    }

    return false;
}
