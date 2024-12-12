const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const CellData = struct {
    height: u8,
};

const Coordinate = struct { x: u16, y: u16 };

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var map = try grid.Grid(*CellData).init(allocator);
    var starts = std.ArrayList(*Coordinate).init(allocator);

    var input_iter = std.mem.splitSequence(u8, input, "\n");

    var first_line = true;
    var line_count: u16 = 0;

    while (input_iter.next()) |line| {
        if (first_line) {
            map.x_dim = line.len;
            first_line = false;
        }
        for (line, 0..) |char, col_count| {
            const val = char - 48;
            //     print("{d}\n", .{val});
            const cell = try allocator.create(CellData);
            cell.* = CellData{ .height = val };

            try map.add_cell(cell);

            if (val != 0) {
                continue;
            }

            const coord = try allocator.create(Coordinate);
            coord.* = Coordinate{ .x = @intCast(col_count), .y = line_count };

            try starts.append(coord);
        }

        line_count += 1;
    }

    map.y_dim = line_count;

    try print_map(&map);

    var total: u16 = 0;

    for (starts.items) |coord| {
        total += try count_trails(&map, coord.x, coord.y, 0);
    }

    print("Total: {d}\n", .{total});
}

fn print_map(map: *grid.Grid(*CellData)) !void {
    for (0..map.y_dim) |y| {
        for (0..map.x_dim) |x| {
            const val = try map.get_cell(x, y);
            print("{d}", .{val.height});
        }
        print("\n", .{});
    }
}

fn count_trails(map: *grid.Grid(*CellData), x: u16, y: u16, next_value: u16) !u16 {
    const value = try map.get_cell(x, y);

    if (value.height != next_value) return 0;
    if (value.height == 9) {
        return 1;
    }

    var total: u16 = 0;

    if (x > 0) {
        total += try count_trails(map, x - 1, y, next_value + 1);
    }

    if (x < map.x_dim - 1) {
        total += try count_trails(map, x + 1, y, next_value + 1);
    }

    if (y > 0) {
        total += try count_trails(map, x, y - 1, next_value + 1);
    }

    if (y < map.y_dim - 1) {
        total += try count_trails(map, x, y + 1, next_value + 1);
    }

    return total;
}
