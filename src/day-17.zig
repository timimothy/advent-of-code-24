const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const Cell = struct { blocked: bool, x: usize, y: usize };
const PathState = struct { score: u32, direction: ?Direction };

const Computer = struct {
    register_a: u64,
    register_b: u64,
    register_c: u64,

    const Self = @This();


    pub fn execute(self: *Self, op: u16, value: u16) {
        switch (op) {
            0 => op_0(operand),
            1 => op_1(operand)
        }
    }

    fn op_0(self: *Self, operand: u16) void {
        const denominator = switch (operand) {
            0,1,2,3 => | val | val,
            4 => self.register_a,
            5 => self.register_b,
            6 => self.register_c,
            else => unreachable,
        };

        self.register_a = self.register_a / std.math.pow(u64, 2, denominator);
    }

    fn op_1(self: *Self, operand: u16) void {
        self.register_b = self.register_b ^ operand;
    }
};





pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");
    var map = try grid.Grid(*Cell).init(allocator);
}
