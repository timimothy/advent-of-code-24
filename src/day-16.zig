const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const Cell = struct { blocked: bool, x: usize, y: usize };
const PathState = struct { score: u32, direction: ?Direction };

const Directions = [4]Direction{ Direction.e, Direction.n, Direction.s, Direction.w };

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

    while (input_iter.next()) |line| {
        if (line_count == 0) {
            map.x_dim = line.len;
        }
        for (line, 0..) |c, x| {
            const cell = try allocator.create(Cell);
            cell.* = Cell{ .blocked = c == '#', .x = x, .y = line_count };
            switch (c) {
                'S' => {
                    start_cell = cell;
                },
                'E' => {
                    end_cell = cell;
                },
                else => {},
            }

            try map.add_cell(cell);
        }

        line_count += 1;
    }

    map.y_dim = line_count;

    var came_from = std.AutoHashMap(*Cell, *Cell).init(allocator);
    var g_score = std.AutoHashMap(*Cell, *PathState).init(allocator);

    var traveled = std.AutoHashMap(*Cell, void).init(allocator);
    defer traveled.deinit();

    try a_star(
        allocator,
        &map,
        &came_from,
        &g_score,
        start_cell.?,
        end_cell.?,
        &traveled,
    );

    try print_map(
        allocator,
        &map,
        &came_from,
        end_cell.?,
        &g_score,
        &traveled,
    );
}

test "estimate" {
    var cell_1 = Cell{
        .x = 0,
        .y = 0,
        .blocked = true,
    };

    var cell_2 = Cell{
        .x = 4,
        .y = 3,
        .blocked = true,
    };

    try std.testing.expectEqual(
        5,
        estimate(
            &cell_1,
            &cell_2,
        ),
    );

    try std.testing.expectEqual(
        5,
        estimate(
            &cell_2,
            &cell_1,
        ),
    );
}

fn estimate(cell: *Cell, end_cell: *Cell) u64 {
    const x_step: u64 = usize_diff(end_cell.x, cell.x);
    const y_step: u64 = usize_diff(end_cell.y, cell.y);
    return std.math.sqrt(std.math.pow(u64, x_step, 2) + std.math.pow(u64, y_step, 2));
}

fn get_neighbor(map: *grid.Grid(*Cell), cell: *Cell, direction: Direction) !?*Cell {
    return switch (direction) {
        Direction.n => map.get_cell(cell.x, usize_sub(cell.y, 1) catch return error.Err),
        Direction.e => map.get_cell(cell.x + 1, cell.y),
        Direction.s => map.get_cell(cell.x, cell.y + 1),
        Direction.w => map.get_cell(usize_sub(cell.x, 1) catch return error.Err, cell.y),
        else => unreachable,
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

fn usize_sub(a: usize, b: usize) !usize {
    if (b > a) return error.Err;
    const result = @as(i64, @intCast(a)) - @as(i64, @intCast(b));

    return @as(usize, @intCast(result));
}

fn usize_diff(a: usize, b: usize) u64 {
    const result = @as(i64, @intCast(a)) - @as(i64, @intCast(b));
    return @as(u64, @intCast(@abs(result)));
}

fn a_star(
    allocator: std.mem.Allocator,
    map: *grid.Grid(*Cell),
    came_from: *std.AutoHashMap(*Cell, *Cell),
    g_score: *std.AutoHashMap(*Cell, *PathState),
    start: *Cell,
    end: *Cell,
    traveled: *std.AutoHashMap(*Cell, void),
) !void {
    var f_score = std.AutoHashMap(*Cell, u64).init(allocator);

    var open_set = std.ArrayList(*Cell).init(allocator);
    try open_set.append(start);

    const start_path_state = try allocator.create(PathState);
    start_path_state.* = PathState{ .direction = Direction.e, .score = 0 };

    try g_score.put(start, start_path_state);
    try f_score.put(start, estimate(start, end));

    while (0 < open_set.items.len) {
        const current_cell = try get_current_cell(&open_set, &f_score) orelse unreachable;

        remove_item_from_list(&open_set, current_cell);

        const current_cell_g_score = g_score.get(current_cell) orelse unreachable;

        // if (current_cell == end) {
        //     print("FOUND {any}\n", .{current_cell_g_score.score});

        //     return;
        // }
        print("{any} {any} {d}\n", .{ current_cell, current_cell_g_score.direction, current_cell_g_score.score });

        for (Directions) |direction| {
            const neighbor: *Cell = try get_neighbor(map, current_cell, direction) orelse unreachable;

            if (neighbor.blocked) continue;

            const turn_count = get_turn_count(current_cell_g_score.direction.?, direction);

            print("\t{any} {d} \n", .{ neighbor, turn_count });

            const new_neighbor_g_score = current_cell_g_score.score + turn_count * 1000 + 1;
            const existing_neighbor_score: ?*PathState = g_score.get(neighbor);

            if (existing_neighbor_score != null and new_neighbor_g_score == existing_neighbor_score.?.score) {
                print("SAME COST DIFFERENT PATH {} {}\n", .{ current_cell, neighbor });

                var cell = current_cell;
                try traveled.put(current_cell, {});
                while (came_from.get(cell)) |from| {
                    try traveled.put(from, {});
                    cell = from;
                }
            }

            if (existing_neighbor_score != null and new_neighbor_g_score < existing_neighbor_score.?.score or existing_neighbor_score == null) {
                switch (g_score.contains(neighbor)) {
                    true => {
                        existing_neighbor_score.?.score = new_neighbor_g_score;
                        existing_neighbor_score.?.direction = direction;
                    },
                    false => {
                        const path_score: *PathState = try allocator.create(PathState);
                        path_score.* = PathState{ .direction = direction, .score = new_neighbor_g_score };
                        try g_score.put(neighbor, path_score);
                    },
                }

                try came_from.put(neighbor, current_cell);
                try f_score.put(neighbor, new_neighbor_g_score + estimate(neighbor, end));
                try add_item_to_list(&open_set, neighbor);
            }
        }
    }

    var cell = end;
    while (came_from.get(cell)) |from| {
        try traveled.put(from, {});
        cell = from;
    }

    try traveled.put(start, {});
    try traveled.put(end, {});
}

fn get_current_cell(open_set: *std.ArrayList(*Cell), f_score: *std.AutoHashMap(*Cell, u64)) !?*Cell {
    var current_cell: ?*Cell = null;
    var current_cell_f_score: ?u64 = null;

    for (open_set.items) |cell_iter| {
        if (current_cell == null) {
            current_cell = cell_iter;
            current_cell_f_score = f_score.get(cell_iter) orelse unreachable;

            continue;
        }

        const cell_f_score = f_score.get(current_cell.?) orelse unreachable;

        if (cell_f_score < current_cell_f_score.?) {
            current_cell = cell_iter;
            current_cell_f_score = cell_f_score;
        }
    }

    return current_cell;
}

fn remove_item_from_list(open_set: *std.ArrayList(*Cell), current_cell: *Cell) void {
    const item_index: ?usize = for (open_set.items, 0..) |cell, index| {
        if (cell == current_cell) break index;
    } else null;

    if (item_index == null) return;

    _ = open_set.orderedRemove(item_index.?);
}

fn add_item_to_list(open_set: *std.ArrayList(*Cell), cell: *Cell) !void {
    const item_index: ?usize = for (open_set.items, 0..) |c, index| {
        if (c == cell) break index;
    } else null;

    if (item_index != null) return;

    try open_set.append(cell);
}

fn print_map(
    allocator: std.mem.Allocator,
    map: *grid.Grid(*Cell),
    _: *std.AutoHashMap(*Cell, *Cell),
    end: *Cell,
    g_score: *std.AutoHashMap(*Cell, *PathState),
    traveled: *std.AutoHashMap(*Cell, void),
) !void {
    var path = std.ArrayList(*Cell).init(allocator);
    defer path.deinit();

    try path.append(end);

    var iter = traveled.keyIterator();

    while (iter.next()) |from| {
        try path.append(from.*);
    }

    for (0..map.y_dim) |y| {
        for (0..map.x_dim) |x| {
            const path_cell = for (path.items) |p| {
                if (p.x == x and p.y == y) break true;
            } else false;

            const map_cell = try map.get_cell(x, y);

            if (map_cell.blocked) {
                print("#", .{});
                continue;
            }

            if (path_cell) {
                print("O", .{});
                continue;
            }
            print(" ", .{});
        }
        print("\n", .{});
    }

    const score = g_score.get(end) orelse unreachable;
    print("Length: {}\n", .{path.items.len});
    print("Score: {}\n", .{score.score});
}
