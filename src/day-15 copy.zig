const std = @import("std");
const util = @import("lib/util.zig");
const Grid = @import("lib/grid_2.zig").Grid;
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const Content = enum { bedrock, robot, box };

const Entity = struct {
    cell_start: *Cell,
    cell_end: *Cell,

    content: Content,
};

const Cell = struct {
    const Self = @This();

    x: usize,
    y: usize,

    bedrock: bool,
    entity: *?Entity,
};

const PathState = struct { score: u32, direction: ?Direction };

const Map = Grid(*Cell);

pub fn main() !void {
    print("Advent of Code: Day 15\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var parts = std.mem.splitSequence(u8, input, "\n\n");

    var map = try Map.init(allocator);
    var robot: *Entity = undefined;

    const raw_map = parts.next() orelse unreachable;
    var raw_map_rows = std.mem.tokenize(u8, raw_map, "\n");

    print("{s}\n", .{raw_map});

    var y: usize = 0;
    while (raw_map_rows.next()) |row| {
        if (y == 0) {
            map.x_dim = row.len * 2;
        }
        for (row, 0..) |char, x| {
            switch (char) {
                '#', '.' => |matched_char| {
                    for (0..2) |_| {
                        const cell: *Cell = try allocator.create(Cell);
                        cell.* = Cell{
                            .contents = null,
                            .x = x,
                            .y = y,
                        };

                        try map.add_cell(cell);

                        if (matched_char == '#') {
                            cell.bedrock = true;
                        }
                    }
                },
                '@' => {
                    const cell: *Cell = try allocator.create(Cell);
                    cell.* = Cell{
                        .entity = null,
                        .x = x,
                        .y = y,
                    };

                    const entity = try allocator.create(Entity);
                    entity.* = Entity{ .content = Content.robot, .cell_start = cell, .cell_end = cell };
                    cell.entity = entity;

                    try map.add_cell(cell);

                    robot = entity;
                },
                'O' => {
                    const entity = try allocator.create(Entity);
                    entity.* = Entity{
                        .content = Content.box,
                        .cell_start = undefined,
                        .cell_end = undefined,
                    };

                    for (0..2) |count| {
                        const cell: *Cell = try allocator.create(Cell);
                        cell.* = Cell{
                            .entity = entity,
                            .x = x,
                            .y = y,
                        };

                        try map.add_cell(cell);

                        switch (count) {
                            0 => entity.cell_start = cell,
                            1 => entity.cell_end = cell,
                            else => unreachable,
                        }
                    }
                },
            }
        }
        y += 1;
    }

    map.y_dim = y;

    const moves = parts.next() orelse unreachable;
    for (moves) |move| {
        print("Current Move: {c}\n", .{move});

        const direction: Direction = switch (move) {
            '<' => Direction.w,
            '>' => Direction.e,
            'v' => Direction.s,
            '^' => Direction.n,
            else => continue,
        };

        try move_entity(&map, direction, robot.cell_start) orelse {
            continue;
        };

        //   try print_map(&map);
    }

    var gps: u32 = 0;
    for (map.cells.items) |cell| {
        if (cell.contents != Content.box) continue;

        gps += 100 * @as(u32, @intCast(cell.y)) + @as(u32, @intCast(cell.x));
    }

    print("GPS TOTAL: {}\n", .{gps});
}

fn move_entity(map: *Map, direction: Direction, entity: *Entity) !?*Cell {
    if (entity.cell_end == entity.cell_start) {
        try next_cell_blocked(map, direction);
    }
    const next_x = get_next_x(direction, cell.x);
    const next_y = get_next_y(direction, cell.y);

    const next_cell = try map.get_cell(next_x, next_y);

    const res_1 = try move_entity(map, direction, next_cell) orelse {
        return null;
    };

    if (res_1 == null) return null;

    switch (cell.contents) {
        Content.robot => {
            next_cell.contents = Content.robot;
            cell.contents = Content.empty;
        },
        Content.box => next_cell.contents = Content.box,
        else => {},
    }

    return next_cell;
}

fn get_next_cell(map: *Map, direction: Direction) !?*Entity {}

fn get_next_x(dir: Direction, x: usize) usize {
    return switch (dir) {
        Direction.e => x + 1,
        Direction.w => x - 1,
        else => x,
    };
}

fn get_next_y(dir: Direction, y: usize) usize {
    return switch (dir) {
        Direction.s => y + 1,
        Direction.n => y - 1,
        else => y,
    };
}

fn print_map(map: *Map) !void {
    for (0..map.y_dim) |y| {
        for (0..map.x_dim) |x| {
            const cell = try map.get_cell(x, y);

            switch (cell.contents) {
                Content.bedrock => print("#", .{}),
                Content.empty => print(".", .{}),
                Content.robot => print("@", .{}),
                Content.box => print("O", .{}),
            }
        }

        print("\n", .{});
    }
}
