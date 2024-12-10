const std = @import("std");
const util = @import("lib/util.zig");

const print = std.debug.print;

const AllocatedBlock = struct { id: u16 };
const EmptyBlock = struct {};

//const Block = union { AllocatedBlock, EmptyBlock };

pub fn main() !void {
    print("Advent of Code: Day 7\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var disk = std.ArrayList(?*(AllocatedBlock)).init(allocator);

    var next_id: u16 = 0;
    var is_block = true;
    for (input) |char| {
        const size = char - 48;

        if (is_block) {
            for (0..size) |_| {
                const block = try allocator.create(AllocatedBlock);
                block.* = AllocatedBlock{ .id = next_id };
                try disk.append(block);
            }
            next_id += 1;
        } else {
            for (0..size) |_| {
                try disk.append(null);
            }
        }

        is_block = !is_block;
    }

    print_disk(&disk);

    var start_cursor: usize = 0;
    for (0..disk.items.len) |offset| {
        const end_cursor = disk.items.len - 1 - offset;

        const item = disk.items[end_cursor] orelse {
            continue;
        };

        while (disk.items[start_cursor] != null) start_cursor += 1;

        if (start_cursor >= end_cursor) break;

        disk.items[start_cursor] = item;
        disk.items[end_cursor] = null;
    }

    print_disk(&disk);

    var checksum: u64 = 0;

    for (disk.items, 0..) |could_be_item, position| {
        const item = could_be_item orelse continue;

        checksum += item.id * position;
    }

    print("{d}", .{checksum});
}

fn print_disk(arr: *std.ArrayList(?*AllocatedBlock)) void {
    for (arr.items) |item| {
        const unwrapped = item orelse {
            print(".", .{});
            continue;
        };

        print("{}", .{unwrapped.id});
    }
    print("\n", .{});
}
