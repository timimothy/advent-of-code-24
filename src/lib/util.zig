const std = @import("std");

const GetInputError = error{NoPipedData};

pub fn get_input(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return GetInputError.NoPipedData;
    }

    return try stdin.readAllAlloc(allocator, 999999999);
}
