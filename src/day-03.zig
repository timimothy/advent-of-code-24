const std = @import("std");

const ArrayList = std.ArrayList;

const Mode = enum { do, dont };

pub fn main() !void {
    std.debug.print("Day 3 of advent of code\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var total: u64 = 0;

    var list = ArrayList([]const u8).init(allocator);
    defer list.deinit();

    var state = Mode.do;
    const input = try stdin.readAllAlloc(allocator, 9999999999);

    var cursor: usize = 0;

    std.debug.print("Len {d}\n", .{input.len});
    while (cursor < input.len) {
        switch (state) {
            Mode.do => {
                const dontStart = std.mem.indexOfPos(u8, input, cursor, "don't()") orelse input.len;

                try list.append(input[cursor..dontStart]);
                cursor = dontStart + 7;
                state = Mode.dont;
            },
            Mode.dont => {
                const doStart = std.mem.indexOfPos(u8, input, cursor, "do()") orelse input.len;
                cursor = doStart + 4;
                state = Mode.do;
            },
        }
    }

    for (list.items) |row| {
        std.debug.print("{s}\n", .{row});

        total += process_string(allocator, row);
    }

    std.debug.print("Total: {d}\n", .{total});
}

fn valid_string(text: []const u8) bool {
    for (text) |c| {
        if (!std.ascii.isDigit(c)) {
            return false;
        }
    }

    return true;
}

test "check if string is valid" {
    const valid = valid_string("(959]+: (510,621){/$ %from(535,780)<");
    try std.testing.expectEqual(false, valid);
}

fn process_string(alloc: std.mem.Allocator, input: []const u8) u32 {
    var total: u32 = 0;
    var cursor: usize = 0;

    while (cursor < input.len) {
        std.debug.print("cursor pos {d} {c}\n", .{ cursor, input[cursor] });
        const start = std.mem.indexOfPos(u8, input, cursor, "mul(") orelse {
            std.debug.print("breaking {d}\n", .{cursor});
            break;
        };

        const ending = std.mem.indexOfPos(u8, input, start + 4, ")") orelse break;

        var numberIter = std.mem.splitSequence(u8, input[start + 4 .. ending], ",");

        var numList = ArrayList(u32).init(alloc);
        defer numList.deinit();
        var err = false;

        while (numberIter.next()) |numText| {
            if (!valid_string(numText)) {
                err = true;
                break;
            }

            const number = std.fmt.parseInt(u32, numText, 10) catch break;

            numList.append(number) catch {
                err = true;
                break;
            };
        }

        std.debug.print("nums {any}\n", .{
            numList.items,
        });

        if (!err and numList.items.len == 2) {
            total += (numList.items[0] * numList.items[1]);
            cursor = ending + 1;
        } else {
            cursor += 1;
        }
    }

    return total;
}
