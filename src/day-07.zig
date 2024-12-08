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

    // Array of numbers to process from input
    var numbers = std.ArrayList(u64).init(allocator);
    defer numbers.deinit();

    // Iterate over each line and determine whether the test value can be made from
    // RHS of the :
    while (line_iter.next()) |line| {
        //   print("{s}\n", .{line});
        const semi_index = std.mem.indexOf(u8, line, ":") orelse unreachable;
        const test_value = try get_number_from_str(line[0..semi_index]);

        // Clear numbers
        numbers.clearAndFree();

        // Populate numbers array with numbers from input string
        try populate_array_list_with_number_string(&numbers, line[semi_index + 2 ..]);

        if (is_valid(&numbers, 1, numbers.items[0], test_value)) {
            total_calibration_result += test_value;
        }
    }

    print("Total Calibration Result: {}\n", .{total_calibration_result});
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

// This function is so much faster!!!
// Recursion, who would have thought.
fn is_valid(array: *std.ArrayList(u64), index: usize, value: u64, expected: u64) bool {
    if (index == array.items.len) {
        return value == expected;
    }

    if (is_valid(array, index + 1, value * array.items[index], expected)) return true;
    if (is_valid(array, index + 1, value + array.items[index], expected)) return true;

    const join = (value * std.math.pow(u64, 10, std.math.log(u64, 10, array.items[index]) + 1)) + array.items[index];

    if (is_valid(array, index + 1, join, expected)) return true;

    return false;
}
