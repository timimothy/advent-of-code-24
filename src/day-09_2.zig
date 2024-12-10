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

    var end_cursor: usize = disk.items.len - 1;

    while (end_cursor > 1) {
        //  print_disk(&disk);
        const item = disk.items[end_cursor] orelse {
            end_cursor -= 1;
            continue;
        };

        var file_start_cursor = end_cursor;

        while (file_start_cursor > 0) {
            const next_item = disk.items[file_start_cursor - 1] orelse {
                break;
            };

            if (next_item.id == item.id) {
                file_start_cursor -= 1;
            } else {
                break;
            }
        }
        const file_size = end_cursor - file_start_cursor + 1;
        // print("{} {} {} {}\n", .{ item.id, file_start_cursor, end_cursor, file_size });

        const start_cursor = find_null_block_start(&disk, file_size, end_cursor) orelse {
            if (file_start_cursor == 0) break;
            end_cursor = file_start_cursor - 1;
            continue;
        };

        if (start_cursor > file_start_cursor) continue;

        for (0..file_size) |offset| {
            disk.items[start_cursor + offset] = disk.items[file_start_cursor + offset];
            disk.items[file_start_cursor + offset] = null;
        }
    }
    // print_disk(&disk);

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

fn find_null_block_start(arr: *std.ArrayList(?*AllocatedBlock), block_size: usize, end: usize) ?usize {
    //    print("finding: {}\n", .{block_size});
    var cursor: usize = 0;
    var in_null_block: bool = false;
    var current_size: usize = 0;
    var start: usize = 0;
    while (cursor < arr.items.len and cursor < end) {
        //  print("{}: ", .{cursor});
        if (arr.items[cursor] != null) {
            in_null_block = false;
            current_size = 0;
            cursor += 1;
            //  print("\n", .{});
            continue;
        }

        if (!in_null_block) {
            start = cursor;
            in_null_block = true;
            //  print("null start, {}: ", .{start});
        }

        current_size += 1;
        // print("current_size, {}", .{current_size});
        if (current_size == block_size) {
            return start;
        }
        cursor += 1;
        //print("\n", .{});
    }

    return null;
}
