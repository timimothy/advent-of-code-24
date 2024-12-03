const std = @import("std");

const ArrayList = std.ArrayList;

// var token: Token = Token.none;

pub fn main() !void {
    std.debug.print("Day 1 of advent of code\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var total: u64 = 0;

    switch (stat.kind) {
        std.fs.Dir.Entry.Kind.named_pipe => {
            var list = ArrayList([]const u8).init(allocator);
            defer list.deinit();

            var enabled = true;
            const input = try stdin.readAllAlloc(allocator, 9999999999);

            //   total += try processBuf(allocator, buff);
            var cursor: usize = 0;

            std.debug.print("Len {d}\n", .{input.len});
            while (cursor < input.len) {
                switch (enabled) {
                    true => {
                        const dontStart = std.mem.indexOfPos(u8, input, cursor, "don't()") orelse input.len;

                        try list.append(input[cursor..dontStart]);
                        cursor = dontStart + 7;
                        enabled = false;
                    },
                    false => {
                        const doStart = std.mem.indexOfPos(u8, input, cursor, "do()") orelse input.len;
                        //     try list.append(input[cursor..doStart]);
                        cursor = doStart + 4;
                        enabled = true;
                    },
                }
            }

            for (list.items) |row| {
                std.debug.print("{s}\n", .{row});

                total += process_string(allocator, row);
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

// const Token = enum { mul, dont, do, none };

// const tokens = [_]Token{ Token.do, Token.dont, Token.mul };

// pub fn processBuf(alloc: std.mem.Allocator, input: []const u8) !u32 {
//     var cursor: usize = 0;
//     var total: u32 = 0;
//     std.debug.print("{s}:\n", .{input});
//     while (cursor < input.len) {
//         std.debug.print("Cursor: {d} | Token: {any}\n", .{ cursor, token });
//         if (token == Token.mul) {

//             //  std.debug.print("{s}: End Bracket {d}\n", .{ input[cursor..end], end });

//             var parts = std.mem.splitSequence(u8, input[cursor..end], ",");

//             var numList = ArrayList(u32).init(alloc);
//             var err = false;

//             while (parts.next()) |part| {
//                 if (!validString(part)) {
//                     err = true;
//                     break;
//                 }

//                 const number = std.fmt.parseInt(u32, part, 10) catch continue;

//                 try numList.append(number);
//             }
//             //   std.debug.print("extraction: {any} {any}\n", .{ err, numList.items });

//             if (!err and numList.items.len == 2) {
//                 total += (numList.items[0] * numList.items[1]);
//                 cursor = end + 1;
//             } else {
//                 cursor += 1;
//             }

//             token = Token.none;
//             continue;
//         }

//         const nexToken = getNextTokenPosition(input, cursor);

//         std.debug.print("{any}\n", .{
//             nexToken,
//         });
//         if (nexToken[0] == null) break;
//         cursor = nexToken[0].?;

//         const tokenOffset: usize = switch (nexToken[1]) {
//             Token.mul => 4,
//             Token.do => 4,
//             Token.dont => 6,
//             else => 1,
//         };

//         cursor += tokenOffset;

//         if (!(token == Token.dont and nexToken[1] != Token.do)) {
//             token = nexToken[1];
//         } else {
//             std.debug.print("Current Token: {any}, Next Token: {any}, Skipping\n", .{ token, nexToken[1] });
//         }

//         //  std.debug.print("{any} {any} {any}\n", .{ nexToken, cursor, token });
//     }

//     std.debug.print("{any}\n", .{
//         total,
//     });

//     return total;
// }

// pub fn getNextTokenPosition(input: []const u8, cursor: usize) struct { ?usize, Token } {
//     var lowestToken: Token = Token.none;
//     var lowestIndex: ?usize = null;
//     for (tokens) |iToken| {
//         switch (iToken) {
//             Token.do => {
//                 const index = std.mem.indexOfPos(u8, input, cursor, "do()");
//                 if (index == null) continue;
//                 if (lowestIndex == null or index.? < lowestIndex.?) {
//                     lowestIndex = index;
//                     lowestToken = Token.do;
//                 }
//             },
//             Token.dont => {
//                 const index = std.mem.indexOfPos(u8, input, cursor, "don't()");
//                 if (index == null) continue;
//                 if (lowestIndex == null or index.? < lowestIndex.?) {
//                     lowestIndex = index;
//                     lowestToken = Token.dont;
//                 }
//             },
//             Token.mul => {
//                 const index = std.mem.indexOfPos(u8, input, cursor, "mul");
//                 if (index == null) continue;
//                 if (lowestIndex == null or index.? < lowestIndex.?) {
//                     lowestIndex = index;
//                     lowestToken = Token.mul;
//                 }
//             },
//             else => {},
//         }
//     }

//     return .{ lowestIndex, lowestToken };
// }

fn process_string(alloc: std.mem.Allocator, input: []const u8) u32 {
    var total: u32 = 0;
    var cursor: usize = 0;
    //  std.debug.print("process\n", .{});
    while (cursor < input.len) {
        std.debug.print("cursor pos {d} {c}\n", .{ cursor, input[cursor] });
        const start = std.mem.indexOfPos(u8, input, cursor, "mul(") orelse {
            std.debug.print("breaking {d}\n", .{cursor});
            break;
        };

        const ending = std.mem.indexOfPos(u8, input, start + 4, ")") orelse break;
        //    std.debug.print("{s}\n", .{input[start..ending]});

        var numberIter = std.mem.splitSequence(u8, input[start + 4 .. ending], ",");

        var numList = ArrayList(u32).init(alloc);
        defer numList.deinit();
        var err = false;

        while (numberIter.next()) |numText| {
            if (!validString(numText)) {
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
