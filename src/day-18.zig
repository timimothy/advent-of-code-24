const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const Cell = struct {
    blocked: bool,
};

const Coord = struct {
    x: u32,
    y: u32,
};

pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");
    var map = try grid.Grid(*Cell).init(allocator);

    map.x_dim = 6;
    map.y_dim = 6;

    for (0..map.y_dim * map.x_dim) |_| {
        const cell = allocator.create(Cell);
        cell.* = Cell{ .blocked = false };
        try map.add_cell(cell);
    }

    while (input_iter.next()) |raw_coordinate| {
        const coord = try get_coord_from_raw(raw_coordinate);

        const cell = try map.get_cell(coord.x, coord.y);

        cell.blocked = true;
    }
}

fn get_coord_from_raw(raw: *const []u8) !Coord {
    const parts = std.mem.tokenize(u8, raw, ",");

    const x = std.fmt.parseInt(u32, parts.next() orelse unreachable, 10);
    const y = std.fmt.parseInt(u32, parts.next() orelse unreachable, 10);

    return Coord{ .y = y, .x = x };
}
