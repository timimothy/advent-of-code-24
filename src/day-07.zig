const std = @import("std");
const util = @import("lib/util.zig");

const print = std.debug.print;

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var line_iter = std.mem.splitSequence(u8, input, "\n");

    var total_calibration_result: u128 = 0;

    // Array of numbers to process from input
    var numbers = std.ArrayList(u128).init(allocator);
    defer numbers.deinit();

    // Mask array to populate to determine which operator to use
    var mask = std.ArrayList(u8).init(allocator);
    defer mask.deinit();

    while (line_iter.next()) |line| {
        print("{s}\n", .{line});
        const semi_index = std.mem.indexOf(u8, line, ":") orelse unreachable;
        const test_value = try get_number_from_str(line[0..semi_index]);

        // Clear numbers
        numbers.clearAndFree();

        // Populate numbers array with numbers from input string
        try populate_array_list_with_number_string(&numbers, line[semi_index + 2 ..]);

        // Possible iterations for the symbols
        // Solution 1: 2 * number of white spaces
        // Solution 2: 3 * number of white spaces
        for (0..(std.math.pow(usize, 3, numbers.items.len - 1))) |index| {
            // Total of the current mask
            var total: u128 = numbers.items[0];

            // Clear the current mask
            mask.clearAndFree();

            // Convert the current iteration to a base 3 mask
            try to_base_3(&mask, index, numbers.items.len - 1);

            // Iterate over each number position
            for (0..numbers.items.len - 1) |pos| {
                // Get the mask value to determine the operation
                switch (mask.items[pos]) {
                    1 => total = join_numbers(total, numbers.items[pos + 1]) catch unreachable,
                    0 => total *= numbers.items[pos + 1],
                    2 => total += numbers.items[pos + 1],
                    else => unreachable,
                }

                // If we have exceeded the test value break early
                if (total > test_value) {
                    break;
                }
            }

            // If the total matches the test value update the calibration result
            if (total == test_value) {
                total_calibration_result += test_value;
                break;
            }
        }
    }

    print("Total Calibration Result: {}\n", .{total_calibration_result});
}

fn get_number_from_str(str: []const u8) !u128 {
    return std.fmt.parseInt(u128, str, 10);
}

fn populate_array_list_with_number_string(array: *std.ArrayList(u128), str: []const u8) !void {
    var str_iter = std.mem.splitSequence(u8, str, " ");

    while (str_iter.next()) |number_str| {
        const value = try get_number_from_str(number_str);

        try array.append(value);
    }
}

fn to_base_3(array: *std.ArrayList(u8), value: usize, pad: usize) !void {
    var index: usize = 0;

    var number = value;

    while (number > 0) {
        const digit = number % 3;
        number /= 3;
        try array.append(@as(u8, @intCast(digit)));
        index += 1;
    }

    if (index == 0) {
        // Handle case for 0 explicitly
        try array.append(0);
        index += 1;
    }

    while (array.items.len < pad) {
        try array.append(0);
    }
}

fn join_numbers(num1: u128, num2: u128) !u128 {
    var buff: [32]u8 = undefined;
    const printed = try std.fmt.bufPrint(&buff, "{}{}", .{ num1, num2 });
    return try std.fmt.parseInt(u128, printed, 10);
}
