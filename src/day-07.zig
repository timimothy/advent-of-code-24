const std = @import("std");
const util = @import("lib/util.zig");

const print = std.debug.print;

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var line_iter = std.mem.splitSequence(u8, input, "\n");

    var total_calibration_result: u64 = 0;
    while (line_iter.next()) |line| {
        print("{s}\n", .{line});
        const semi_index = std.mem.indexOf(u8, line, ":") orelse unreachable;

        const test_value = try get_number_from_str(line[0..semi_index]);

        var numbers = std.ArrayList(u64).init(allocator);
        defer numbers.deinit();

        try populate_array_list_with_number_string(&numbers, line[semi_index + 2 ..]);

        // Possible iterations for the symbols
        for (0..(std.math.pow(u64, 2, numbers.items.len - 1))) |index| {
            var total: u64 = numbers.items[0];

            for (0..numbers.items.len - 1) |pos| {
                const bit = (index >> @as(u4, @intCast(pos))) & 1;

                switch (bit) {
                    0 => total *= numbers.items[pos + 1],
                    1 => total += numbers.items[pos + 1],
                    else => unreachable,
                }

                if (total > test_value) {
                    break;
                }
            }

            if (total == test_value) {
                total_calibration_result += test_value;
                break;
            }
        }
    }

    print("Total Calivration Result: {}\n", .{total_calibration_result});
}

fn get_number_from_str(str: []const u8) !u64 {
    return std.fmt.parseInt(u64, str, 10);
}

fn populate_array_list_with_number_string(array: *std.ArrayList(u64), str: []const u8) !void {
    var str_iter = std.mem.splitSequence(u8, str, " ");

    while (str_iter.next()) |number_str| {
        const value = try get_number_from_str(number_str);

        try array.append(value);
    }
}
