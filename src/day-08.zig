const std = @import("std");
const util = @import("lib/util.zig");

const print = std.debug.print;

const Cell = struct { x: usize, y: usize };

pub fn main() !void {
    print("Advent of Code: Day 8\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var line_iter = std.mem.splitSequence(u8, input, "\n");

    var hash_map = std.AutoHashMap(u8, *std.ArrayList(*Cell)).init(allocator);
    var line_count: usize = 0;

    var max_x: usize = 0;
    while (line_iter.next()) |line| {
        print("{s}\n", .{line});
        if (max_x == 0) {
            max_x = line.len;
        }
        for (line, 0..) |char, x| {
            if (char == '.') continue;

            if (!hash_map.contains(char)) {
                const array = try allocator.create(std.ArrayList(*Cell));
                array.* = std.ArrayList(*Cell).init(allocator);
                try hash_map.put(char, array);
            }

            var array = hash_map.get(char) orelse unreachable;

            const cell = try allocator.create(Cell);
            cell.* = Cell{ .x = x, .y = line_count };
            try array.append(cell);
        }

        line_count += 1;
    }

    var key_iter = hash_map.keyIterator();

    var locations = std.AutoHashMap(Cell, void).init(allocator);

    while (key_iter.next()) |key| {
        const array = hash_map.get(key.*) orelse unreachable;
        print("{c}\n", .{key.*});
        // const combinations = (calculate_factorial(array.items.len) / (calculate_factorial(2) * calculate_factorial(array.items.len - 2)));
        // print("{}\n", .{combinations});

        // total += combinations;
        for (array.items[0 .. array.items.len - 1], 0..) |cell_a, index| {
            print("{}\n", .{cell_a.*});
            try locations.put(cell_a.*, {});
            for (index + 1..array.items.len) |cursor| {
                const cell_b = array.items[cursor];
                try locations.put(cell_b.*, {});

                const dx: i16 = (@as(i16, @intCast(cell_b.x)) - @as(i16, @intCast(cell_a.x)));
                const dy: i16 = (@as(i16, @intCast(cell_b.y)) - @as(i16, @intCast(cell_a.y)));

                var antinode_start = cell_b.*;
                while (get_antinode(
                    &antinode_start,
                    dx,
                    dy,
                    max_x,
                    line_count,
                ) catch null) |result| {
                    try locations.put(result, {});
                    antinode_start = result;
                }

                antinode_start = cell_a.*;
                while (get_antinode(
                    &antinode_start,
                    -dx,
                    -dy,
                    max_x,
                    line_count,
                ) catch null) |result| {
                    try locations.put(result, {});
                    antinode_start = result;
                }

                print("\n", .{});
            }
            //print("\n", .{});
        }
    }

    var total: usize = 0;
    var location_iter = locations.keyIterator();
    while (location_iter.next()) |_| {
        total += 1;
        //  print("{any}\n", .{loc.*});
    }

    print("{}\n", .{total});
}

fn calculate_factorial(num: usize) u32 {
    var total: u32 = @as(u32, @intCast(num));

    for (1..num) |value| {
        total *= @as(u32, @intCast(num - value));
    }

    return total;
}

fn get_antinode(cell: *Cell, dx: i16, dy: i16, max_x: usize, max_y: usize) !Cell {
    const antinode_x = @as(i16, @intCast(cell.x)) + dx;
    const antinode_y = @as(i16, @intCast(cell.y)) + dy;
    print("{} {} {} {}\n", .{ antinode_x, antinode_y, max_x, max_y });
    if (antinode_x >= 0 and antinode_x < max_x and antinode_y >= 0 and antinode_y < max_y) {
        return Cell{ .x = @as(usize, @intCast(antinode_x)), .y = @as(usize, @intCast(antinode_y)) };
    }

    return error.Error;
}
