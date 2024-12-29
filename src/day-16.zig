const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const Cell = struct { blocked: bool, x: usize, y: usize };
const PathState = struct { score: u32, direction: ?Direction };

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");
    var map = try grid.Grid(*Cell).init(allocator);

    var line_count: usize = 0;

    var start_cell: ?*Cell = null;
    var end_cell: ?*Cell = null;

    var g_score = std.AutoHashMap(*Cell, *PathState).init(allocator);
    var f_score = std.AutoHashMap(*Cell, u64).init(allocator);

    var open_set = std.ArrayList(*Cell).init(allocator);

    while (input_iter.next()) |line| {
        for (line, 0..) |c, x| {
            const cell = try allocator.create(Cell);
            cell.* = Cell{ .blocked = false, .x = x, .y = line_count };
            switch (c) {
                '#' => cell.blocked = true,
                'S' => {
                    start_cell = cell;
                },
                'E' => {
                    end_cell = cell;
                },
                '.' => {},
                else => unreachable,
            }

            try map.add_cell(cell);
        }

        line_count += 1;
    }

    const start_state = try allocator.create(PathState);
    start_state.* = PathState{ .direction = Direction.e, .score = 0 };

    try g_score.put(start_cell.?, start_state);
    try f_score.put(start_cell.?, estimate(start_cell.?, end_cell.?));
    try open_set.append(start_cell.?);

    while (open_set.items.len < 0) {
        var current_cell: ?*Cell = null;
        var current_cell_f_score: ?u16 = null;
        var current_cell_g_score: ?*PathState = null;
        for (open_set.items) |cell_iter| {
            if (current_cell == null) {
                current_cell = cell_iter;
                current_cell_f_score = f_score.get(current_cell) orelse unreachable;
                current_cell_g_score = g_score.get(current_cell) orelse unreachable;
                continue;
            }

            const cell_f_score = f_score.get(current_cell) orelse unreachable;

            if (cell_f_score < current_cell_f_score) {
                current_cell = cell_iter;
                current_cell_f_score = cell_f_score;
            }
        }

        if (current_cell == end_cell) {
            print("found\n", .{});
            break;
        }

        var neighbor: ?*Cell = null;

        neighbor = get_neighbor(&map, current_cell, Direction.n);

        const neighbor_g_score = current_cell_g_score.?.score + get_turn_count(current_cell_g_score.?.direction, Direction.n) * 1000;
        const existing_neighbor_score: ?*PathState = try g_score.get(neighbor.?);
        if (existing_neighbor_score and neighbor_g_score < existing_neighbor_score.?.score or existing_neighbor_score == null) {
            switch (g_score.contains(neighbor)) {
                true => existing_neighbor_score.?.score = neighbor_g_score,
                false => {
                    const path_score = try allocator.create(PathState);
                    path_score.* = PathState{ .direction = Direction.n, .score = neighbor_g_score };
                    g_score.put(neighbor, path_score);
                },
            }

            try f_score.put(neighbor, neighbor_g_score + estimate(neighbor, end_cell));
        }
    }
}

fn estimate(cell: *Cell, end_cell: *Cell) u64 {
    const x_step: u32 = @as(u32, @intCast(usize_sub(end_cell.x, cell.x) orelse unreachable));
    const y_step: u32 = @as(u32, @intCast(usize_sub(end_cell.y, cell.y) orelse unreachable));
    return std.math.sqrt(std.math.pow(u64, x_step, 2) + std.math.pow(u32, y_step, 2));
}

fn get_neighbor(map: *grid.Grid(*Cell), cell: *Cell, direction: Direction) !?*Cell {
    return switch (direction) {
        Direction.n => map.get_cell(cell.x, usize_sub(cell.y, 1) orelse null) catch null,
        Direction.e => map.get_cell(cell.x + 1, cell.y) catch null,
        Direction.s => map.get_cell(cell.x, cell.y + 1) catch null,
        Direction.w => map.get_cell(usize_sub(cell.x, 1) orelse return null, cell.y) catch null,
    };
}

test "get_turn_count" {
    try std.testing.expectEqual(get_turn_count(Direction.n, Direction.e), 1);
    try std.testing.expectEqual(get_turn_count(Direction.n, Direction.s), 2);
    try std.testing.expectEqual(get_turn_count(Direction.n, Direction.n), 0);
    try std.testing.expectEqual(get_turn_count(Direction.n, Direction.w), 1);
}

fn get_turn_count(to: Direction, from: Direction) u32 {
    if (to == from) return 0;

    const from_degs: u16 = direction_to_degs(from);
    const to_degs = direction_to_degs(to);

    const degs_diff: i16 = @as(i16, @intCast(to_degs)) - @as(i16, @intCast(from_degs));

    return switch (@as(u16, @abs(degs_diff))) {
        270, 90 => 1,
        180 => 2,
        0 => 0,
        else => unreachable,
    };
}

fn direction_to_degs(dir: Direction) u16 {
    return switch (dir) {
        Direction.n => 0,
        Direction.e => 90,
        Direction.s => 180,
        Direction.w => 270,
        else => unreachable,
    };
}

fn usize_sub(a: usize, b: usize) i16 {
    const result: i16 = @as(i16, @intCast(a)) - @as(i16, @intCast(b));

    if (result < 0) return null;

    return @as(usize, @intCast(result));
}
