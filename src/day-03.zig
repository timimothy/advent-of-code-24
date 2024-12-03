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

    var total: u64 = 0;

    switch (stat.kind) {
        std.fs.Dir.Entry.Kind.named_pipe => {
            while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 999999)) |buff| {
                var parts = std.mem.splitSequence(u8, buff, "mul");

                while (parts.next()) |part| {
                    std.debug.print("\"{s}\": ", .{part});

                    if (part.len == 0) continue;
                    if (part[0] != '(') {
                        // Not valid
                        std.debug.print("skip\n", .{});
                        continue;
                    }

                    const index = std.mem.indexOfPos(u8, part, 1, &[_]u8{')'}) orelse {
                        std.debug.print("no )\n", .{});
                        continue;
                    };

                    var numbers = std.mem.splitSequence(u8, part[1..index], ",");

                    var list = ArrayList(u64).init(allocator);
                    var err = false;
                    while (numbers.next()) |text| {
                        std.debug.print("'{s}', ", .{text});
                        const valid = validString(text);

                        if (!valid) {
                            err = true;
                            break;
                        }

                        const number: u64 = std.fmt.parseInt(u64, text, 10) catch continue;
                        try list.append(number);
                    }

                    if (list.items.len != 2 or err) {
                        std.debug.print("incorrect numbers\n", .{});
                        continue;
                    }

                    const mult = (list.items[0] * list.items[1]);

                    total += mult;
                    std.debug.print("{d}\n", .{total});
                }
            }
        },
        else => {
            return;
        },
    }
    std.debug.print("Total: {d}\n", .{total});
}

fn validString(text: []const u8) bool {
    for (text) |c| {
        if (c != '(' and c != ')' and !std.ascii.isDigit(c)) {
            return false;
        }
    }

    return true;
}

test "check if string is valid" {
    const valid = validString("(959]+: (510,621){/$ %from(535,780)<");
    try std.testing.expectEqual(false, valid);
}
