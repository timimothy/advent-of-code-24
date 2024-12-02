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
            while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
                const trimmed_line = std.mem.trimRight(u8, line, "\n");

                const safe = try lineIsSafeV1(trimmed_line);
                if (safe) {
                    std.debug.print("Safe\n", .{});
                    totalSafe += 1;
                }
            }
        },
        else => {
            return;
        },
    }

    std.debug.print("Total Safe: {d}\n", .{totalSafe});
}

pub fn lineIsSafeV1(line: []const u8) !bool {
    std.debug.print("'{s}': ", .{line});
    var safe: bool = true;
    var asc: bool = true;
    var first: bool = true;

    var lineIter = std.mem.splitSequence(u8, line, " ");

    var last: i16 = try std.fmt.parseInt(i16, lineIter.next().?, 10);

    while (lineIter.next()) |text| {
        const number = try std.fmt.parseInt(i16, text, 10);

        const diff = number - last;

        if (first) {
            first = false;
            asc = diff > 0;
        }

        std.debug.print("{d} ", .{diff});
        //  std.debug.print("{d} {d} {d}\n", .{ last, number, diff });

        const absDiff = @abs(diff);

        if ((absDiff < 1 or absDiff > 3) or (asc and diff < 0) or (!asc and diff > 0)) {
            std.debug.print("Breaking: Not Safe\n", .{});
            safe = false;
            break;
        }

        last = number;
    }

    return safe;
}
