const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const Coordinate = struct { x: i32, y: i32 };

pub fn main() !void {
    print("Advent of Code: Day 14 Part 1.\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    var tl: u32 = 0;
    var tr: u32 = 0;
    var bl: u32 = 0;
    var br: u32 = 0;

    const width: u32 = 101;
    const height: u32 = 103;

    const x_mid_point: u32 = width / 2;
    const y_mid_point: u32 = height / 2;

    print("{d} {d}\n", .{ x_mid_point, y_mid_point });

    while (input_iter.next()) |line| {
        // print("{s}\n", .{line});
        var parts = std.mem.tokenize(u8, line, " ");

        const position_string = parts.next() orelse unreachable;
        const velocity_string = parts.next() orelse unreachable;
        var coordinate = Coordinate{ .x = 0, .y = 0 };
        var velocity = Coordinate{ .x = 0, .y = 0 };
        try get_coordinate_from_string(position_string[2..], &coordinate);
        try get_coordinate_from_string(velocity_string[2..], &velocity);

        simulate(&coordinate, &velocity, 100, width, height);
        print("{} \n", .{coordinate});

        if (coordinate.x == x_mid_point or coordinate.y == y_mid_point) continue;
        switch (coordinate.y < y_mid_point) {
            true => {
                switch (coordinate.x < x_mid_point) {
                    true => tl += 1,
                    false => tr += 1,
                }
            },
            false => {
                switch (coordinate.x < x_mid_point) {
                    true => bl += 1,
                    false => br += 1,
                }
            },
        }
    }

    print("{d} {d}\n{d} {d}\n", .{ tl, tr, bl, br });
    print("{d}", .{tl * tr * bl * br});
}

fn get_coordinate_from_string(str: []const u8, coord: *Coordinate) !void {
    var coordinate_iter = std.mem.tokenize(u8, str, ",");
    coord.*.x = try std.fmt.parseInt(i32, coordinate_iter.next() orelse unreachable, 10);
    coord.*.y = try std.fmt.parseInt(i32, coordinate_iter.next() orelse unreachable, 10);
}

test "simulate" {
    var coord = Coordinate{ .x = 2, .y = 4 };
    var vel = Coordinate{ .x = 2, .y = -3 };
    simulate(&coord, &vel, 5);

    try std.testing.expectEqual(1, coord.x);
    try std.testing.expectEqual(3, coord.y);
}

test "simulate_1" {
    var coord = Coordinate{ .x = 0, .y = 0 };
    var vel = Coordinate{ .x = -1, .y = -1 };
    simulate(&coord, &vel, 1, 11, 7);

    try std.testing.expectEqual(10, coord.x);
    try std.testing.expectEqual(6, coord.y);
}
fn simulate(coordinate: *Coordinate, velocity: *Coordinate, seconds: u32, width: u32, height: u32) void {
    // print("{} {} \n", .{ coordinate, velocity });
    coordinate.x += (@as(i32, @intCast(seconds)) * velocity.x);
    coordinate.y += (@as(i32, @intCast(seconds)) * velocity.y);

    //  print("{} {} \n", .{ coordinate, velocity });

    coordinate.x = @mod(coordinate.x, @as(i32, @intCast(width)));
    coordinate.y = @mod(coordinate.y, @as(i32, @intCast(height)));

    // print("{} {} \n", .{ coordinate, velocity });
}
