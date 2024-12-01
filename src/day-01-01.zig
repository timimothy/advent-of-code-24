const std = @import("std");

const ArrayList = std.ArrayList;

// Steps to solving this problem
// 1. Split the input into two arrays
// 2. Sort each array
// 3. Iterate over each sorted array and sum their differences

// Part 2
// When iterating over the

pub fn main() !void {
    std.debug.print("Day 1 of advent of code\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u32, u32).init(
        allocator,
    );
    defer map.deinit();

    // Set up array lists to store data
    var left = ArrayList(u32).init(allocator);
    var right = ArrayList(u32).init(allocator);

    switch (stat.kind) {
        std.fs.Dir.Entry.Kind.named_pipe => {
            while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
                const trimmed_line = std.mem.trimRight(u8, line, "\n");
                std.debug.print("'{s}'\n", .{trimmed_line});

                var lineIter = std.mem.splitSequence(u8, trimmed_line, "   ");

                const leftString = lineIter.next().?;
                std.debug.print("'{s}'\n", .{leftString});
                const leftInt = try std.fmt.parseInt(u32, leftString, 10);
                std.debug.print("'{d}'\n", .{leftInt});
                try left.append(leftInt);

                const rightString = lineIter.next().?;
                std.debug.print("'{s}'\n", .{rightString});
                const rightInt = try std.fmt.parseInt(u32, rightString, 10);
                try right.append(rightInt);

                if (map.contains(rightInt)) {
                    const value = map.get(rightInt).? + 1;
                    try map.put(rightInt, value);
                } else {
                    try map.put(rightInt, 1);
                }
            }
        },
        else => {
            return;
        },
    }

    const leftArray = try left.toOwnedSlice();
    const rightArray = try right.toOwnedSlice();

    std.mem.sort(u32, leftArray, {}, std.sort.asc(u32));
    std.mem.sort(u32, rightArray, {}, std.sort.asc(u32));

    var totalDifference: u32 = 0;
    var score: u32 = 0;

    for (leftArray, 0..) |leftValue, index| {
        const rightValue = rightArray[index];

        std.debug.print("{d} - {d}\n", .{ rightValue, leftValue });
        const difference = if (leftValue < rightValue) rightValue - leftValue else leftValue - rightValue;

        totalDifference += difference;

        std.debug.print("Index: {} Left: {} Right: {} Difference {}\n", .{ index, leftValue, rightValue, difference });

        if (map.contains(leftValue)) {
            const calc = map.get(leftValue).? * leftValue;
            score += calc;
        }
    }

    std.debug.print("Total Difference: {}\n", .{totalDifference});
    std.debug.print("Score: {}\n", .{score});
}
