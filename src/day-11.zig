const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");

const print = std.debug.print;

const Stone = struct { value: u64, next: ?*Stone, blink: usize };
const Input = struct { value: u64, count: usize };

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var input_iter = std.mem.tokenize(u8, input, " ");

    var memo = std.AutoHashMap(Input, u64).init(allocator);

    // var first_stone: ?*Stone = null;
    // var current_stone: ?*Stone = null;

    var count: u64 = 0;
    while (input_iter.next()) |char| {
        const value = get_value_from_input(char) orelse unreachable;

        count += try count_stones(&memo, value, 75) orelse unreachable;
    }

    // current_stone = first_stone;

    // print_stone(first_stone);

    print("Start\n", .{});

    // while (current_stone) |stone| {
    //     count += 1;
    //     //print("Count: {}\n", .{count});

    //     for (0..75) |i| {
    //         if (i < stone.blink) {
    //             continue;
    //         }

    //         if (stone.value == 0) {
    //             stone.value = 1;
    //             current_stone = stone.next;
    //             continue;
    //         }

    //         const length = std.math.log(u64, 10, stone.value) + 1;

    //         if (@mod(length, 2) == 0) {
    //             const pow = std.math.pow(u64, 10, length / 2);
    //             const original = stone.value;
    //             stone.value = stone.value / pow;

    //             const next_stone = try allocator.create(Stone);
    //             next_stone.* = Stone{ .value = original - stone.value * pow, .next = stone.next, .blink = i + 1 };
    //             stone.next = next_stone;
    //             continue;
    //         }

    //         stone.value *= 2024;
    //     }
    //     current_stone = stone.next;
    // }

    // for (0..75) |i| {
    //     current_stone = first_stone;

    //     print("{}: ", .{i});
    //     //   print_stone(first_stone);
    //     while (current_stone) |stone| {
    //         if (skip) {
    //             current_stone = stone.next;
    //             skip = false;
    //             continue;
    //         }

    //         if (stone.value == 0) {
    //             stone.value = 1;
    //             current_stone = stone.next;
    //             continue;
    //         }

    //         const length = std.math.log(u64, 10, stone.value) + 1;

    //         if (@mod(length, 2) == 0) {
    //             const pow = std.math.pow(u64, 10, length / 2);
    //             const original = stone.value;
    //             stone.value = stone.value / pow;

    //             const next_stone = try allocator.create(Stone);
    //             next_stone.* = Stone{ .value = original - stone.value * pow, .next = stone.next };
    //             stone.next = next_stone;
    //             current_stone = stone.next;
    //             skip = true;
    //             continue;
    //         }

    //         stone.value *= 2024;
    //         current_stone = stone.next;
    //     }
    // }
    // print("Final: ", .{});
    // print_stone(first_stone);

    print("Stone count: {}", .{count});
}

fn get_value_from_input(input: ?[]const u8) ?u64 {
    if (input == null) return null;
    return std.fmt.parseInt(u64, input orelse return null, 10) catch null;
}

fn print_stone(stone: ?*Stone) void {
    var current = stone;
    while (current) |current_stone| {
        print("{d} ", .{current_stone.value});
        current = current_stone.next;
    }
    print("\n", .{});
}

fn count_stones(memo: *std.AutoHashMap(Input, u64), value: u64, count: usize) !?u64 {
    const memo_value = memo.get(.{ .value = value, .count = count });

    if (memo_value != null) {
        return memo_value;
    }

    var stone_count: u64 = 1;
    var current_value: u64 = value;
    for (0..count) |i| {
        if (current_value == 0) {
            current_value = 1;
            continue;
        }

        const length = std.math.log(u64, 10, current_value) + 1;

        if (@mod(length, 2) == 0) {
            const pow = std.math.pow(u64, 10, length / 2);
            const original = current_value;
            current_value = current_value / pow;

            stone_count += try count_stones(memo, original - current_value * pow, count - (i + 1)) orelse unreachable;
            continue;
        }

        current_value *= 2024;
    }

    try memo.put(.{ .value = value, .count = count }, stone_count);

    return stone_count;
}
