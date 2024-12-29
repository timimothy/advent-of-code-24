const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const Combination = [5]u16;

const Type = enum { Key, Lock };

pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, "\n");

    // Current
    var current_combination: ?Combination = null;
    var current_combination_type: ?Type = null;
    var current_type_line: usize = 0;

    var locks = std.ArrayList(Combination).init(allocator);
    var keys = std.ArrayList(Combination).init(allocator);

    while (input_iter.next()) |line| {
        print("{s} {d}\n", .{ line, current_type_line });

        if (current_type_line == 5) {
            try switch (current_combination_type.?) {
                Type.Key => keys.append(current_combination.?),
                Type.Lock => locks.append(current_combination.?),
            };
            current_type_line = 0;
            current_combination = null;
            current_combination_type = null;
            continue;
        }

        if (current_combination == null) {
            current_combination = Combination{ 0, 0, 0, 0, 0 };
            current_combination_type = switch (std.mem.eql(u8, line, "#####")) {
                true => Type.Lock,
                false => Type.Key,
            };
            current_type_line = 0;

            continue;
        }

        for (line, 0..) |char, index| {
            if (char != '#') continue;

            current_combination.?[index] += 1;
        }

        current_type_line += 1;
    }
    print("Total Locks: {}\n", .{locks.items.len});
    print("Total Keys: {}\n", .{keys.items.len});
    var count: u16 = 0;

    for (locks.items) |lock| {
        for (keys.items) |key| {
            var fit = true;
            //print("{any} {any}\n", .{ lock, key });
            for (0..5) |index| {
                const sum = key[index] + lock[index];

                //    print("{any} {any} {d}\n", .{ lock, key, sum });
                fit = fit and sum <= 5;

                if (!fit) break;
            }

            if (fit) {
                count += 1;
            }
        }
    }
    print("Total: {}\n", .{count});
}
