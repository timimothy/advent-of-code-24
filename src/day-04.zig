const std = @import("std");

// Way to solve this puzzle
// 1.   store all characters in the 2D array so that they
//      can be accessed using grid coordinates.
// 2.   Iterate over each cell and check for the letter X
// 3.   If the cell contains X search in the directions that are allowed.
//      Stopping if out of bounds or cell does not contribute to spelling
//      XMAS.

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var grid2 = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        var row = std.ArrayList(u8).init(allocator);
        for (line) |char| {
            std.debug.print("{c}\n", .{char});

            try row.append(char);
        }

        try grid2.append(row);
    }

    print_grid(&grid2);

    const result = count_xmas(&grid2);

    std.debug.print("{d}", .{result});
}

fn print_grid(grid: *std.ArrayList(std.ArrayList(u8))) void {
    for (grid.items) |row| {
        for (row.items) |char| {
            std.debug.print("{c}", .{char});
        }

        std.debug.print("\n", .{});
    }
}

fn count_xmas(grid: *std.ArrayList(std.ArrayList(u8))) u16 {
    const y_size = grid.items.len;
    const x_size = grid.items[0].items.len;

    var total: u16 = 0;

    for (grid.items, 0..) |row, y| {
        for (row.items, 0..) |char, x| {
            const result = is_x_mas(grid, x, y, x_size, y_size);

            if (result) {
                total += 1;

                std.debug.print("{c}", .{char});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    return total;
}

const Direction = struct { xMod: usize, xAsc: bool, yMod: usize, yAsc: bool };

const e = Direction{ .xMod = 1, .yMod = 0, .xAsc = true, .yAsc = false };
const n = Direction{ .xMod = 0, .yMod = 1, .xAsc = true, .yAsc = false };
const ne = Direction{ .xMod = 1, .yMod = 1, .xAsc = true, .yAsc = false };
const nw = Direction{ .xMod = 1, .yMod = 1, .xAsc = false, .yAsc = false };
const s = Direction{ .xMod = 0, .yMod = 1, .xAsc = true, .yAsc = true };
const se = Direction{ .xMod = 1, .yMod = 1, .xAsc = true, .yAsc = true };
const sw = Direction{ .xMod = 1, .yMod = 1, .xAsc = false, .yAsc = true };
const w = Direction{ .xMod = 1, .yMod = 0, .xAsc = false, .yAsc = true };

const xmas = "XMAS";

fn scan_for_xmas(grid: *std.ArrayList(std.ArrayList(u8)), startX: usize, startY: usize, maxX: usize, maxY: usize) u16 {
    var count: u16 = 0;

    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, e);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, n);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, ne);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, nw);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, s);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, se);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, sw);
    count += scan_for_xmas_in_direction(grid, startX, startY, maxX, maxY, w);

    return count;
}

fn scan_for_xmas_in_direction(grid: *std.ArrayList(std.ArrayList(u8)), pos_x: usize, pos_y: usize, maxX: usize, maxY: usize, direction: Direction) u16 {
    var correct: u16 = 0;
    var xCursor = pos_x;
    var yCursor = pos_y;

    while (correct < 4 and xCursor < maxX and yCursor < maxY) {
        const char = get_grid_value(grid, pos_x, pos_y);

        if (xmas[correct] != char) return 0;

        correct += 1;

        if (direction.yAsc) {
            yCursor += direction.yMod;
        } else {
            if (yCursor == 0 and direction.yMod > 0) break;
            yCursor -= direction.yMod;
        }

        if (direction.xAsc) {
            xCursor += direction.xMod;
        } else {
            if (xCursor == 0 and direction.xMod > 0) break;
            xCursor -= direction.xMod;
        }
    }

    return if (correct == 4) 1 else 0;
}

const Grid = std.ArrayList(std.ArrayList(u8));

fn is_x_mas(grid: *Grid, pos_x: usize, pos_y: usize, max_x: usize, max_y: usize) bool {
    if (pos_x == 0 or pos_x == (max_x - 1)) return false;
    if (pos_y == 0 or pos_y == (max_y - 1)) return false;

    const char = get_grid_value(grid, pos_x, pos_y);

    if (char != 'A') return false;

    const ne_char = get_grid_value(grid, pos_x + 1, pos_y - 1);
    const sw_char = get_grid_value(grid, pos_x - 1, pos_y + 1);
    const first = ne_char == 'M' and sw_char == 'S' or ne_char == 'S' and sw_char == 'M';

    const nw_char = get_grid_value(grid, pos_x - 1, pos_y - 1);
    const se_char = get_grid_value(grid, pos_x + 1, pos_y + 1);

    const second = nw_char == 'M' and se_char == 'S' or nw_char == 'S' and se_char == 'M';

    return first and second;
}

fn get_grid_value(grid: *Grid, x: usize, y: usize) u8 {
    return grid.items[y].items[x];
}
