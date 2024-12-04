const std = @import("std");

// Way to solve this puzzle
// 1.   store all characters in the 2D array so that they
//      can be accessed using grid coordinates.
// 2.   Iterate over each cell and check for the letter X
// 3.   If the cell contains X search in the directions that are allowed.
//      Stopping if out of bounds or cell does not contribute to spelling
//      XMAS.

const Row = struct {};

const Grid = struct {
    allocator: std.mem.Allocator,
    rows: std.ArrayList(Row),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Grid{ .allocator = allocator, .row = std.ArrayList(Row).init(allocator) };
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // const grid = Grid.init(allocator);

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
        for (row.items, 0..) |_, x| {
            const result = scan_for_xmas(grid, x, y, x_size, y_size);

            total += result;
            std.debug.print("{d}", .{result});
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

fn scan_for_xmas_in_direction(grid: *std.ArrayList(std.ArrayList(u8)), startX: usize, startY: usize, maxX: usize, maxY: usize, direction: Direction) u16 {
    var correct: u16 = 0;
    var xCursor = startX;
    var yCursor = startY;

    while (correct < 4 and xCursor < maxX and yCursor < maxY) {
        const char = grid.items[yCursor].items[xCursor];

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
