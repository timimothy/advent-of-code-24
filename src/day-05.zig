const std = @import("std");

const print = std.debug.print;

const PageRulesError = error{IncorrectRuleString};

const PageRules = struct {
    ruleMap: std.AutoHashMap(u16, std.ArrayList(u16)),
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) PageRules {
        return PageRules{ .ruleMap = std.AutoHashMap(u16, std.ArrayList(u16)).init(alloc), .allocator = alloc };
    }

    pub fn deinit(self: *PageRules) void {
        var value_iter = self.*.ruleMap.iterator();
        while (value_iter.next()) |rules| {
            rules.value_ptr.*.deinit();
        }

        self.ruleMap.deinit();
    }

    pub fn add_rule(self: *PageRules, rule: []const u8) !void {
        var parts = std.mem.splitSequence(u8, rule, "|");

        // Create array to store results
        var numbers = std.ArrayList(u16).init(self.allocator);
        defer numbers.deinit();

        while (parts.next()) |text| {
            if (numbers.items.len > 2) return PageRulesError.IncorrectRuleString;
            const number = PageRules.to_number(text) catch return PageRulesError.IncorrectRuleString;
            numbers.append(number) catch return PageRulesError.IncorrectRuleString;
        }

        if (!self.ruleMap.contains(numbers.items[0])) {
            try self.ruleMap.put(numbers.items[0], std.ArrayList(u16).init(self.allocator));
        }

        var pages = self.ruleMap.getPtr(numbers.items[0]) orelse unreachable;

        try pages.append(numbers.items[1]);

        //    print("{any}\n", .{pages.items});
    }

    pub fn to_number(text: []const u8) !u16 {
        return try std.fmt.parseInt(u16, text, 10);
    }

    pub fn get_number_of_pages(self: *PageRules) u16 {
        return @intCast(self.*.ruleMap.keyIterator().len);
    }

    pub fn get_rules_for_page(self: *PageRules, page: u16) ?std.ArrayList(u16) {
        return self.*.ruleMap.get(page);
    }
};

const Sorter = struct {
    const Self = @This();

    rules: *PageRules,

    pub fn compare(self: Self, lhs: u16, rhs: u16) bool {
        const l_rules = self.rules.ruleMap.getPtr(lhs) orelse return false;

        for (l_rules.items) |item| {
            if (item == rhs) return true;
        }

        return false;
    }
};

pub fn main() !void {
    print("Advent of Code: Day 5\n", .{});

    const stdin = std.io.getStdIn().reader();
    const stat = try std.io.getStdIn().stat();

    if (stat.kind != std.fs.Dir.Entry.Kind.named_pipe) {
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try stdin.readAllAlloc(allocator, 999999999);

    // const rules = std.HashMap(u16,std.ArrayList(u16));

    var inputIter = std.mem.splitSequence(u8, input, "\n\n");

    var page_rules = PageRules.init(allocator);
    defer page_rules.deinit();

    if (inputIter.next()) |raw_page_rules| {
        try populate_page_rules(&page_rules, raw_page_rules);
    } else {
        return;
    }

    if (inputIter.next()) |raw_updates| {
        const result = try process_updates(allocator, raw_updates, &page_rules);

        print("correct: {d}\n", .{result[0]});
        print("incorrect: {d}\n", .{result[1]});
    }
}

fn populate_page_rules(rules: *PageRules, text: []const u8) !void {
    var line_iter = std.mem.splitSequence(u8, text, "\n");

    while (line_iter.next()) |line| {
        try rules.*.add_rule(line);
    }
}

fn process_updates(alloc: std.mem.Allocator, raw_update_string: []const u8, rules: *PageRules) !struct { u16, u16 } {
    var update_iter = std.mem.splitSequence(u8, raw_update_string, "\n");

    var correct: u16 = 0;
    var incorrect: u16 = 0;
    const sorter = Sorter{ .rules = rules };

    while (update_iter.next()) |update_string| {
        if (update_string.len == 0) break;
        const array = try get_array_from_text(alloc, update_string);
        defer array.deinit();

        if (is_valid(array, rules)) {
            const middleIndex = @divTrunc(array.items.len, 2);
            print("valid: {any} {any} {any}\n", .{ array.items, middleIndex, array.items[middleIndex] });

            correct += array.items[middleIndex];
        } else {
            print("not valid: {any}\n", .{array.items});
            std.mem.sort(u16, array.items, sorter, comptime Sorter.compare);
            print("sorted: {any}\n", .{array.items});
            const middleIndex = @divTrunc(array.items.len, 2);
            incorrect += array.items[middleIndex];
        }
    }

    return .{ correct, incorrect };
}

fn get_array_from_text(alloc: std.mem.Allocator, text: []const u8) !std.ArrayList(u16) {
    var raw_number_iter = std.mem.splitSequence(u8, text, ",");

    var numbers = std.ArrayList(u16).init(alloc);

    while (raw_number_iter.next()) |number_string| {
        const number = try std.fmt.parseInt(u16, number_string, 10);
        try numbers.append(number);
    }

    return numbers;
}

fn is_valid(updates: std.ArrayList(u16), page_rules: *PageRules) bool {
    for (updates.items, 0..) |value, cursor| {
        const rules = page_rules.*.ruleMap.getPtr(value) orelse continue;
        print("{d}: {any}\n", .{ value, rules.items });
        // print("Current Value: {} | is before {any} | required {any}\n", .{ value, updates.items[0..cursor], rules.items });

        for (0..cursor) |tailing_cursor| {
            const tail_value = updates.items[tailing_cursor];

            for (rules.items) |page| {
                if (page == tail_value) return false;
            }
        }
    }

    return true;
}
