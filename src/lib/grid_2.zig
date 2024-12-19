const std = @import("std");

const Err = error{Err};

pub fn Grid(comptime grid_type: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        cells: *std.ArrayList(grid_type),

        x_dim: usize = 0,
        y_dim: usize = 0,

        pub fn init(alloc: std.mem.Allocator) !Self {
            const cell_array = try alloc.create(std.ArrayList(grid_type));
            cell_array.* = std.ArrayList(grid_type).init(alloc);

            return Self{
                .allocator = alloc,
                .cells = cell_array,
            };
        }

        pub fn add_cell(self: *Self, cell_data: grid_type) !void {
            try self.cells.append(cell_data);
        }

        pub fn get_cell(self: *Self, x: usize, y: usize) Err!grid_type {
            if (x >= self.x_dim) return Err.Err;
            if (y >= self.y_dim) return Err.Err;

            const block: i16 = @as(i16, @intCast(y)) * @as(i16, @intCast(self.x_dim));
            const pos: i16 = block + @as(i16, @intCast(x));

            if (pos > self.cells.items.len) {
                return Err.Err;
            }
            return self.cells.items[@intCast(pos)];
        }
    };
}
