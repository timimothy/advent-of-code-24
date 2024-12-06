const std = @import("std");
const grid = @import("lib/grid.zig");

// Stop writing so much
const print = std.debug.print;
const Direction = grid.Direction;
const Grid = grid.Grid;

const Mod = struct { x: i16, y: i16 };

pub fn main() !void {
    print("Advent of Code: Day 6\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try stdin.readAllAlloc(allocator, 999999999);

    const map: *grid.Grid = try allocator.create(grid.Grid);
    defer allocator.destroy(map);
    map.* = try grid.Grid.init(allocator, input);

    print_map(map);
    print("\n", .{});

    var guard: *grid.Guard = map.guard.?;
    var mod = Mod{ .x = 0, .y = 0 };

    update_mod(&mod, guard.direction);

    while (guard.x >= 0 and guard.x < map.x_dim and 0 <= guard.y and guard.y < map.y_dim) {
        const current_cell = map.get_cell(guard.x, guard.y) catch unreachable;

        current_cell.touched = true;

        if (guard.x == 0 and mod.x < 0 or guard.y == 0 and mod.y < 0) {
            break;
        }

        if (guard.x == map.x_dim and mod.x >= 0 or guard.y == map.y_dim - 1 and mod.y >= 0) {
            break;
        }

        while ((map.get_cell(@intCast(@as(i16, @intCast(guard.x)) + mod.x), @intCast(@as(i16, @intCast(guard.y)) + mod.y)) catch unreachable).blocked) {
            guard.direction = turn_right_90(guard.direction);
            update_mod(&mod, guard.direction);
        }

        guard.x = @intCast(@as(i16, @intCast(guard.x)) + mod.x);
        guard.y = @intCast(@as(i16, @intCast(guard.y)) + mod.y);
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
