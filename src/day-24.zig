const std = @import("std");
const util = @import("lib/util.zig");
const grid = @import("lib/grid_2.zig");
const Direction = @import("lib/enums.zig").Direction;

const print = std.debug.print;

const WireLookup = std.ArrayHashMap(
    []const u8,
    *Wire,
    MyKeyContext,
    true,
);

const MyKeyContext = struct {
    pub fn hash(_: MyKeyContext, key: []const u8) u32 {
        var h = std.hash.Fnv1a_32.init();
        h.update(std.mem.sliceAsBytes(key));
        return h.final();
    }

    pub fn eql(_: MyKeyContext, a: []const u8, b: []const u8, _: usize) bool {
        return std.mem.eql(u8, a, b);
    }
};

const Wire = struct {
    value: ?bool,
    from: ?*Gate,
    name: []const u8,
};

const Gate = struct {
    left: ?*Wire,
    right: ?*Wire,
    out: ?*Wire,
    operation: Operation,
};

const Operation = enum { AND, XOR, OR };

fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

pub fn main() !void {
    print("Advent of Code: Day 17\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try util.get_input(allocator);

    var section_iter = std.mem.splitSequence(u8, input, "\n\n");

    var lookup = WireLookup.init(allocator);
    defer lookup.deinit();

    const initial_values = section_iter.next() orelse unreachable;

    var initial_values_iter = std.mem.tokenize(u8, initial_values, "\n");
    while (initial_values_iter.next()) |line| {
        var parts = std.mem.tokenize(u8, line, ": ");

        const name = parts.next() orelse unreachable;
        const val = std.mem.eql(u8, parts.next() orelse unreachable, "1");

        const wire = try allocator.create(Wire);
        wire.* = Wire{ .value = val, .from = null, .name = name };

        try lookup.put(name, wire);
    }

    const actions = section_iter.next() orelse unreachable;
    var actions_iter = std.mem.tokenize(u8, actions, "\n");

    while (actions_iter.next()) |line| {
        var parts = std.mem.tokenize(u8, line, " ");

        const left = try get_or_init(&lookup, parts.next() orelse unreachable);

        const operation = get_operation(parts.next() orelse unreachable);

        const right = try get_or_init(&lookup, parts.next() orelse unreachable);

        _ = parts.next() orelse unreachable;
        const destination = try get_or_init(&lookup, parts.next() orelse unreachable);

        const gate = try allocator.create(Gate);
        gate.* = Gate{ .operation = operation, .left = left, .right = right, .out = destination };

        destination.*.from = gate;
    }

    print("{any}\n", .{lookup.values()});

    const keys = lookup.keys();

    //  std.mem.sort([]const u8, keys, {}, lessThan);
    var value: u64 = 0;
    for (keys) |key| {
        if (!std.mem.startsWith(u8, key, "z")) continue;

        //  print("{s}\n", .{key});

        const pos = try std.fmt.parseInt(u6, key[1..3], 10);
        //   print("{s} {d}\n", .{ key, pos });
        const wire = lookup.get(key).?;

        calculate_wire(wire, key[1..3]);
        // print("{s}: {any}\n", .{
        //     key,
        //     wire.value,
        // });

        if (wire.value.?) {
            value |= (@as(u64, 1) << pos);
        }
    }
    print("Count {d}\n", .{value});
}

fn get_or_init(wires: *WireLookup, key: []const u8) !*Wire {
    var value = wires.get(key);

    if (value == null) {
        const wire = try wires.allocator.create(Wire);
        wire.* = Wire{ .value = null, .from = null, .name = key };
        try wires.put(key, wire);
        value = wire;
    }

    return value orelse unreachable;
}

fn get_operation(key: []const u8) Operation {
    if (std.mem.eql(u8, key, "XOR")) return Operation.XOR;

    if (std.mem.eql(u8, key, "AND")) return Operation.AND;

    if (std.mem.eql(u8, key, "OR")) return Operation.OR;

    unreachable;
}

fn process(op: Operation, left: bool, right: bool) bool {
    return switch (op) {
        Operation.XOR => @as(u1, @intFromBool(left)) ^ @as(u1, @intFromBool(right)) == 1,
        Operation.AND => left and right,
        Operation.OR => left or right,
    };
}

fn calculate_wire(wire: *Wire, number: []const u8) void {
    if (std.mem.startsWith(u8, wire.name, "z") or std.mem.startsWith(u8, wire.name, "y") or std.mem.startsWith(u8, wire.name, "x")) {
        if (!std.mem.containsAtLeast(u8, wire.name, 1, number)) {
            print("{s} {s}\n", .{ number, wire.name });
        }
    }
    if (wire.*.value != null) return;

    wire.value = calculate_gate(wire.from.?, number);
}

fn calculate_gate(gate: *Gate, number: []const u8) bool {
    calculate_wire(gate.left.?, number);
    calculate_wire(gate.right.?, number);

    return process(gate.operation, gate.left.?.value.?, gate.right.?.value.?);
}
