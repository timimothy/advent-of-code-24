const std = @import("std");

pub const Cell = struct {
    touched: bool = false,
    blocked: bool,
};

const Err = error{Err};

pub const Grid = struct {
    const Self = @This();

    cells: *std.ArrayList(*Cell),

    x_dim: usize = 0,
    y_dim: usize = 0,

    pub fn init(alloc: std.mem.Allocator) !Self {
        const cell_array = try alloc.create(std.ArrayList(*Cell));
        cell_array.* = std.ArrayList(*Cell).init(alloc);

        return Self{
            .cells = cell_array,
        };
    }

    pub fn add_cell(self: *Self, cell: *Cell) !void {
        try self.cells.append(cell);
    }

    pub fn get_cell(self: *Self, x: usize, y: usize) Err!*Cell {
        const block: i16 = @as(i16, @intCast(y)) * @as(i16, @intCast(self.x_dim));
        const pos: i16 = block + @as(i16, @intCast(x));
        std.debug.print("getting cell for: {} {} {} {}\n", .{ x, y, block, (x) });

        if (pos > self.cells.items.len) {
            return Err.Err;
        }
        return self.cells.items[@intCast(pos)];
    }
};
