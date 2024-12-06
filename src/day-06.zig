const std = @import("std");
const grid = @import("lib/grid.zig");

// Stop writing so much
const print = std.debug.print;

const Direction = enum { s, n, w, e, none };

const Mod = struct { x: i16, y: i16 };

pub fn main() !void {
    print("Advent of Code: Day 5\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try stdin.readAllAlloc(allocator, 999999999);

    var row_iter = std.mem.splitSequence(u8, input, "\n");

    const map: *grid.Grid = try allocator.create(grid.Grid);
    defer allocator.destroy(map);
    map.* = try grid.Grid.init(allocator);

    var initial_x: usize = 0;
    var initial_y: usize = 0;
    var direction: Direction = Direction.none;

    var row_count: usize = 0;
    var col_count: usize = 0;

    var mod = Mod{ .x = 0, .y = 0 };

    while (row_iter.next()) |row| {
        if (row_count == 0) {
            col_count = row.len;
        }

        for (row, 0..) |char, x_pos| {
            var blocked = false;

            switch (char) {
                '#' => {
                    blocked = true;
                },
                '.' => {},
                else => {
                    direction = get_direction(char);
                    update_mod(&mod, direction);
                    initial_x = x_pos;
                    initial_y = row_count;
                },
            }

            const cell_ptr = try allocator.create(grid.Cell);
            cell_ptr.* = .{ .blocked = blocked, .touched = false };
            try map.add_cell(cell_ptr);
        }

        row_count += 1;
    }

    map.x_dim = col_count;
    map.y_dim = row_count;

    print("Dimensions: {} {}\nRow Count: {}\nCol Count: {}\n", .{ row_count, col_count, row_count, col_count });

    print_map(map);
    print("\n", .{});

    print("Starting at: {any} {any}\n", .{ initial_x, initial_y });

    while (initial_x >= 0 and initial_x < col_count and 0 <= initial_y and initial_y < row_count) {
        //   print("Position at: {any} {any}\n", .{ initial_x, initial_y });
        const current_cell = map.get_cell(initial_x, initial_y) catch unreachable;

        current_cell.touched = true;
        //  print_map(map);
        if (initial_x == 0 and mod.x < 0 or initial_y == 0 and mod.y < 0) {
            break;
        }

        if (initial_x == col_count and mod.x >= 0 or initial_y == row_count - 1 and mod.y >= 0) {
            break;
        }

        //   print("{} {} {}\n", .{ initial_y, row_count, mod });

        // const next = map.get_cell(@intCast(@as(i16, @intCast(initial_x)) + mod.x), @intCast(@as(i16, @intCast(initial_y)) + mod.y));

        //    print("next: {any}\n", .{next});
        while ((map.get_cell(@intCast(@as(i16, @intCast(initial_x)) + mod.x), @intCast(@as(i16, @intCast(initial_y)) + mod.y)) catch unreachable).blocked) {
            direction = turn_right_90(direction);
            update_mod(&mod, direction);
        }

        initial_x = @intCast(@as(i16, @intCast(initial_x)) + mod.x);
        initial_y = @intCast(@as(i16, @intCast(initial_y)) + mod.y);

        //    print("Next Position at: {any} {any}\n", .{ initial_x, initial_y });
    }

    var count: u16 = 0;

    for (map.cells.items) |cell| {
        if (cell.touched) {
            count += 1;
        }
    }

    print("Count: {}", .{count});
}

const Error = error{Std};

fn get_direction(char: u8) Direction {
    return switch (char) {
        '^' => Direction.n,
        '<' => Direction.w,
        '>' => Direction.e,
        'V' => Direction.s,
        else => unreachable,
    };
}

fn turn_right_90(dir: Direction) Direction {
    return switch (dir) {
        Direction.n => Direction.e,
        Direction.e => Direction.s,
        Direction.s => Direction.w,
        Direction.w => Direction.n,
        else => unreachable,
    };
}

fn update_mod(mod: *Mod, dir: Direction) void {
    switch (dir) {
        Direction.n => {
            mod.x = 0;
            mod.y = -1;
        },
        Direction.e => {
            mod.x = 1;
            mod.y = 0;
        },
        Direction.s => {
            mod.x = 0;
            mod.y = 1;
        },
        Direction.w => {
            mod.x = -1;
            mod.y = 0;
        },
        else => unreachable,
    }
}

fn print_map(map: *grid.Grid) void {
    for (map.cells.items, 0..) |cell, index| {
        if (@mod(index, map.x_dim) == 0) {
            print("\n", .{});
        }

        const char: u8 = if (cell.touched) 'X' else if (cell.blocked) '#' else '.';
        print("{c}", .{char});
    }
}
