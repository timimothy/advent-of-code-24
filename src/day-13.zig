const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

pub fn main() !void {
    print("Advent of Code: Day 15 Part 1.\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    var tokens: u64 = 0;

    while (input_iter.next()) |line| {
        var parts = std.mem.tokenize(u8, line[12..], ", Y+");

        const x_1 = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10);
        const y_1 = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10);

        var next_line = input_iter.next() orelse unreachable;

        parts = std.mem.tokenize(u8, next_line[12..], ", Y+");

        const x_2 = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10);
        const y_2 = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10);

        next_line = input_iter.next() orelse unreachable;

        parts = std.mem.tokenize(u8, next_line[9..], ", Y=");

        const x_target = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10) + 10000000000000;
        const y_target = try std.fmt.parseInt(i64, parts.next() orelse unreachable, 10) + 10000000000000;

        const a = @divFloor((x_target * y_2 - y_target * x_2), (x_1 * y_2 - y_1 * x_2));
        const b = @divFloor((x_target - x_1 * a), x_2);

        if (a * x_1 + b * x_2 != x_target or a * y_1 + b * y_2 != y_target) continue;

        tokens += 3 * @as(u64, @intCast(a)) + @as(u64, @intCast(b));
    }

    print("Tokens: {}\n", .{tokens});
}
