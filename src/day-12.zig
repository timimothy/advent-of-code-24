const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const Cell = struct { plant: u8, region: ?*Region, x: usize, y: usize };
const Region = struct { cells: *std.ArrayList(*Cell) };

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    var map = try grid.Grid(*Cell).init(allocator);
    var regions = std.ArrayList(*Region).init(allocator);

    var first = true;
    while (input_iter.next()) |line| {
        if (first) {
            map.x_dim = line.len;
            first = false;
        }

        for (line, 0..) |c, x| {
            const new_cell = try allocator.create(Cell);
            new_cell.* = Cell{ .plant = c, .region = null, .x = x, .y = map.y_dim };
            try map.add_cell(new_cell);
        }

        map.y_dim += 1;
    }

    for (0..map.y_dim) |y| {
        for (0..map.x_dim) |x| {
            const cell = try map.get_cell(x, y);

            if (cell.region != null) {
                continue;
            }

            const region = try allocator.create(Region);
            const cells = try allocator.create(std.ArrayList(*Cell));

            cells.* = std.ArrayList(*Cell).init(allocator);
            region.* = Region{ .cells = cells };

            try regions.append(region);

            try assign_region(&map, cell.plant, region, x, y);
        }
    }

    var price: u32 = 0;

    for (regions.items) |
        region,
    | {
        price += try calculate_price(&map, region);
    }

    print("{}\n", .{price});
}

fn assign_region(map: *grid.Grid(*Cell), plant: u8, region: *Region, x: usize, y: usize) !void {
    const cell = try map.get_cell(x, y);
    if (cell.plant != plant or cell.region != null) return;
    cell.region = region;

    try region.cells.append(cell);

    if (x > 0) {
        try assign_region(map, plant, region, x - 1, y);
    }
    if (x < map.x_dim - 1) {
        try assign_region(map, plant, region, x + 1, y);
    }
    if (y > 0) {
        try assign_region(map, plant, region, x, y - 1);
    }
    if (y < map.y_dim - 1) {
        try assign_region(map, plant, region, x, y + 1);
    }
}

fn calculate_price(map: *grid.Grid(*Cell), region: *Region) !u32 {
    var perimeter: u32 = 0;

    print("{}:\n", .{region.cells.items[0].plant});
    for (region.cells.items) |cell| {
        const value = try count_edge(map, cell);
        print("\t{d},{d}: {d}\n", .{ cell.x, cell.y, value });
        perimeter += value;
    }

    print("{c}: {} x {}\n", .{ region.cells.items[0].plant, region.cells.items.len, perimeter });

    return perimeter * @as(u32, @intCast(region.cells.items.len));
}

fn count_edge(map: *grid.Grid(*Cell), cell: *Cell) !u32 {
    var edges: u32 = 0;

    var adjacent: ?*Cell = null;

    adjacent = try get_cell_by_direction(map, cell, Direction.n);

    if (adjacent == null or (adjacent.?.plant != cell.plant)) {
        edges += 1;
    }

    adjacent = try get_cell_by_direction(map, cell, Direction.e);

    if (adjacent == null or (adjacent.?.plant != cell.plant)) {
        edges += 1;
    }

    adjacent = try get_cell_by_direction(map, cell, Direction.w);

    if (adjacent == null or (adjacent.?.plant != cell.plant)) {
        edges += 1;
    }

    adjacent = try get_cell_by_direction(map, cell, Direction.s);

    if (adjacent == null or (adjacent.?.plant != cell.plant)) {
        edges += 1;
    }

    print("\n", .{});
    return edges;
}

const Direction = enum { n, s, e, w };

fn get_cell_by_direction(map: *grid.Grid(*Cell), cell: *Cell, direction: Direction) !?*Cell {
    switch (direction) {
        Direction.n => {
            if (cell.y == 0) return null;
            return try map.get_cell(cell.x, cell.y - 1);
        },
        Direction.e => {
            if (cell.x == map.x_dim - 1) return null;
            return try map.get_cell(cell.x + 1, cell.y);
        },
        Direction.s => {
            if (cell.y == map.y_dim - 1) return null;
            return try map.get_cell(cell.x, cell.y + 1);
        },
        Direction.w => {
            if (cell.x == 0) return null;
            return try map.get_cell(cell.x - 1, cell.y);
        },
    }
}
