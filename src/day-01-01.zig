const std = @import("std");

const ArrayList = std.ArrayList;

// Steps to solving this problem
// 1. Split the input into two arrays
// 2. Sort each array
// 3. Iterate over each sorted array and sum their differences

pub fn main() !void {
    std.debug.print("Day 1 of advent of code\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    // Set up array lists to store data
    var left = ArrayList(u16).init(allocator);
    var right = ArrayList(u16).init(allocator);

    // Split the input into lines
    var lineIter = std.mem.split(u8, input, "\n");

    // Iterate over each line to build left and right arrays
    while (lineIter.next()) |line| {
        var rowIter = std.mem.split(u8, line, "   ");

        // Read first number
        const leftInt = try std.fmt.parseInt(u16, rowIter.next().?, 10);
        try left.append(leftInt);

        // Read second number
        const rightInt = try std.fmt.parseInt(u16, rowIter.next().?, 10);
        try right.append(rightInt);
    }

    const leftArray = try left.toOwnedSlice();
    const rightArray = try right.toOwnedSlice();

    std.mem.sort(u16, leftArray, {}, std.sort.asc(u16));
    std.mem.sort(u16, rightArray, {}, std.sort.asc(u16));

    var totalDifference: u16 = 0;

    for (leftArray, 0..) |leftValue, index| {
        const rightValue = rightArray[index];

        const difference = rightValue - leftValue;

        totalDifference += difference;
        std.debug.print("Index: {} Left: {} Right: {} Difference {}\n", .{ index, leftValue, rightValue, difference });
    }

    std.debug.print("Total Difference: {}", .{totalDifference});
}
