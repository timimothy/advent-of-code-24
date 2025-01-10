const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const Coordinate = struct {
    x: i32,
    y: i32,
};

const Robot = struct {
    coordinate: *Coordinate,
    velocity: *Coordinate,
};

pub fn main() !void {
    print("Advent of Code: Day 14 Part 2.\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    const width: u32 = 101;
    const height: u32 = 103;

    const x_mid_point: u32 = width / 2;
    const y_mid_point: u32 = height / 2;

    print("{d} {d}\n", .{ x_mid_point, y_mid_point });

    var robots = std.ArrayList(*Robot).init(allocator);

    while (input_iter.next()) |line| {
        // print("{s}\n", .{line});
        var parts = std.mem.tokenize(u8, line, " ");

        const position_string = parts.next() orelse unreachable;
        const velocity_string = parts.next() orelse unreachable;

        const coordinate = try allocator.create(Coordinate);
        const velocity = try allocator.create(Coordinate);
        coordinate.* = Coordinate{ .x = 0, .y = 0 };
        velocity.* = Coordinate{ .x = 0, .y = 0 };
        try get_coordinate_from_string(position_string[2..], coordinate);
        try get_coordinate_from_string(velocity_string[2..], velocity);

        const robot = try allocator.create(Robot);
        robot.* = Robot{
            .coordinate = coordinate,
            .velocity = velocity,
        };

        try robots.append(robot);
    }

    // var longest_run: u32 = 0;

    for (0..10000) |i| {
        for (robots.items) |robot| {
            simulate(robot.coordinate, robot.velocity, 1, width, height);
        }

        std.mem.sort(*Robot, robots.items, {}, sort_robots);

        var current_x: i32 = 0;
        var current_y: i32 = 0;
        var current_run: u32 = 1;
        var longest_run: u32 = 0;
        var longest_run_y: i32 = 0;

        for (robots.items) |robot| {
            //  print("{} {} {}\n", .{ robot.coordinate.x, robot.coordinate.y, current_run });
            if (current_x == robot.coordinate.x and current_y == robot.coordinate.y) continue;

            if (current_y != robot.coordinate.y or current_x + 1 != robot.coordinate.x) {
                if (current_run > longest_run) {
                    longest_run = current_run;
                    longest_run_y = current_y;
                }

                current_run = 0;
            }

            current_y = robot.coordinate.y;
            current_x = robot.coordinate.x;

            current_run += 1;
        }

        if (longest_run > 6) {
            print("Longest run: {} {}: {}\n", .{ i, longest_run_y, longest_run });
            try print_robots(allocator, &robots, width, height);
        }
    }
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
    coordinate.x += (@as(i32, @intCast(seconds)) * velocity.x);
    coordinate.y += (@as(i32, @intCast(seconds)) * velocity.y);

    coordinate.x = @mod(coordinate.x, @as(i32, @intCast(width)));
    coordinate.y = @mod(coordinate.y, @as(i32, @intCast(height)));
}

fn print_robots(allocator: std.mem.Allocator, robots: *std.ArrayList(*Robot), width: u32, height: u32) !void {
    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    try data.appendNTimes(0, width * height);

    for (robots.items) |robot| {
        var position: usize = @intCast(robot.coordinate.x);

        if (robot.coordinate.y > 1) {
            position += width * @as(usize, @intCast(robot.coordinate.y));
        }

        data.items[position] += 1;
    }

    for (0..height) |y| {
        print("{}:\t", .{y});
        for (0..width) |x| {
            switch (data.items[y * width + x] > 0) {
                true => print("#", .{}),
                false => print(" ", .{}),
            }
        }

        print("\n", .{});
    }
}

fn sort_robots(_: void, lhs: *Robot, rhs: *Robot) bool {
    if (lhs.coordinate.y - rhs.coordinate.y != 0) return lhs.coordinate.y < rhs.coordinate.y;

    return lhs.coordinate.x < rhs.coordinate.x;
}
