const std = @import("std");

pub const Guard = struct {
    direction: Direction,
    x: usize,
    y: usize,
    x_default: usize,
    y_default: usize,
    direction_default: Direction,

    pub fn reset(self: *Guard) void {
        self.x = self.x_default;
        self.y = self.y_default;
        self.direction = self.direction_default;
    }
};

pub const Cell = struct {
    touched: bool = false,
    blocked: bool,
    x: usize,
    y: usize,
};

const Err = error{Err};

pub const Direction = enum { s, n, w, e, none };

pub const Grid = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    cells: *std.ArrayList(*Cell),
    guard: ?*Guard,

    x_dim: usize = 0,
    y_dim: usize = 0,

    pub fn init(alloc: std.mem.Allocator, input: []const u8) !Self {
        const cell_array = try alloc.create(std.ArrayList(*Cell));
        cell_array.* = std.ArrayList(*Cell).init(alloc);

        var data = Self{
            .allocator = alloc,
            .cells = cell_array,
            .guard = null,
        };

        try data.process_input(input);

        return data;
    }

    fn process_input(self: *Self, input: []const u8) !void {
        var row_iter = std.mem.splitSequence(u8, input, "\n");
        while (row_iter.next()) |row| {
            if (self.y_dim == 0) {
                self.x_dim = row.len;
            }

            for (row, 0..) |char, x_pos| {
                var blocked = false;

                switch (char) {
                    '#' => {
                        blocked = true;
                    },
                    '.' => {},
                    else => {
                        if (self.guard == null) {
                            const direction = get_direction(char);
                            const guard_ptr = try self.allocator.create(Guard);
                            guard_ptr.* = Guard{ .direction = direction, .x = x_pos, .y = self.y_dim, .y_default = self.y_dim, .x_default = x_pos, .direction_default = direction };
                            self.guard = guard_ptr;
                        }
                    },
                }

                const cell_ptr = try self.allocator.create(Cell);
                cell_ptr.* = .{ .blocked = blocked, .touched = false, .x = x_pos, .y = self.y_dim };
                try self.cells.append(cell_ptr);
            }

            self.y_dim += 1;
        }
    }

    pub fn get_cell(self: *Self, x: usize, y: usize) Err!*Cell {
        const block: i16 = @as(i16, @intCast(y)) * @as(i16, @intCast(self.x_dim));
        const pos: i16 = block + @as(i16, @intCast(x));

        if (pos > self.cells.items.len) {
            return Err.Err;
        }
        return self.cells.items[@intCast(pos)];
    }
};

fn get_direction(char: u8) Direction {
    return switch (char) {
        '^' => Direction.n,
        '<' => Direction.w,
        '>' => Direction.e,
        'V' => Direction.s,
        else => unreachable,
    };
}
