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

    var totalSafe: u16 = 0;

    switch (stat.kind) {
        std.fs.Dir.Entry.Kind.named_pipe => {
            while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |buff| {
                const line = getLine(buff);
                var list = try getArrayList(allocator, line);

                const array = try list.toOwnedSlice();

                std.debug.print("{any}: ", .{array});
                const isSafe = lineIsSafeV1(array);

                if (isSafe) {
                    std.debug.print("Safe\n", .{});
                    totalSafe += 1;
                    continue;
                }
                std.debug.print("Not Safe: Skipping ", .{});
                // Mask one item and see if it will work.
                for (0..array.len) |skip| {
                    var first = true;
                    var asc = true;
                    var safe = true;
                    const start: usize = if (skip == 0) 1 else 0;
                    var last = array[start];

                    for (array[0..], 0..) |number, index| {
                        if (skip == index or index == start) {
                            std.debug.print("{d}:{d}, ", .{ index, number });

                            continue;
                        }

                        const diff = number - last;

                        if (first) {
                            first = false;
                            asc = diff > 0;
                        }

                        const absDiff = @abs(diff);

                        if ((absDiff < 1 or absDiff > 3) or (asc and diff < 0) or (!asc and diff > 0)) {
                            safe = false;
                            break;
                        }

                        last = number;
                    }

                    if (safe) {
                        std.debug.print("Safe\n", .{});
                        totalSafe += 1;
                        break;
                    }

                    if (skip == array.len - 1) {
                        std.debug.print("Not Safe\n", .{});
                    }
                }
            }
        },
        else => {
            return;
        },
    }
    std.debug.print("Total Safe: {d}\n", .{totalSafe});
}

fn getLine(text: []u8) []const u8 {
    return std.mem.trimRight(u8, text, "\n");
}

fn getArrayList(allocator: std.mem.Allocator, text: []const u8) !ArrayList(i32) {
    var list = ArrayList(i32).init(allocator);

    var lineIter = std.mem.splitSequence(u8, text, " ");

    while (lineIter.next()) |characters| {
        const number = try std.fmt.parseInt(i32, characters, 10);
        try list.append(number);
    }

    return list;
}

pub fn lineIsSafeV1(numbers: []i32) bool {
    var safe: bool = true;
    var asc: bool = true;
    var first: bool = true;
    var last = numbers[0];

    for (numbers[1..]) |number| {
        const diff = number - last;

        if (first) {
            first = false;
            asc = diff > 0;
        }

        const absDiff = @abs(diff);

        if ((absDiff < 1 or absDiff > 3) or (asc and diff < 0) or (!asc and diff > 0)) {
            safe = false;
            break;
        }

        last = number;
    }
    return safe;
}

// pub fn lineIsSafeV2(line: []const u8) !bool {
//     std.debug.print("{s}: ", .{line});
//     var safe: bool = true;
//     var asc: bool = true;
//     var first: bool = true;
//     var altered: bool = false;

//     var lineIter = std.mem.splitSequence(u8, line, " ");

//     var last: i16 = try std.fmt.parseInt(i16, lineIter.next().?, 10);

//     var numbers = ArrayList(i16).init(allocator);

//     while (lineIter.next()) |text| {
//         const number = try std.fmt.parseInt(i16, text, 10);

//         if (first) {
//             asc = number > last;
//         }

//         const isSafe = isSafeReading(last, number, asc);

//         if (isSafe) {
//             last = number;
//             continue;
//         }

//         if (altered) {
//             std.debug.print("Breaking: Not Safe\n", .{});
//             safe = false;
//             break;
//         }

//         if (first) {
//             first = false;
//         }

//         altered = true;
//     }

//     return safe;
// }

pub fn isSafeReading(num1: i16, num2: i16, asc: bool) bool {
    const diff = num2 - num1;
    const absDiff = @abs(diff);
    return !((absDiff < 1 or absDiff > 3) or (asc and diff < 0) or (!asc and diff > 0));
}
