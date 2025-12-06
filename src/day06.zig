const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;
const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;
const charToDigit = std.fmt.charToDigit;
const print = std.debug.print;
const assert = std.debug.assert;
const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");
const data_ex = @embedFile("data/day06_ex.txt");

const Sign = enum {
    add,
    multiply,
};

const Operation = struct {
    numbers: List(usize),
    sign: Sign,
};

fn part1(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");

    var operations = List(Operation).empty;
    while (lineIterator.next()) |line| {
        var itemIterator = tokenizeAny(u8, line, " ");

        var i: usize = 0;
        while (itemIterator.next()) |item| : (i += 1) {
            if (item[0] == '+') {
                operations.items[i].sign = Sign.add;
            } else if (item[0] == '*') {
                operations.items[i].sign = Sign.multiply;
            } else {
                const number = try parseInt(usize, item, 10);
                if (i >= operations.items.len) {
                    try operations.append(gpa, .{ .numbers = .empty, .sign = Sign.add });
                }
                try operations.items[i].numbers.append(gpa, number);
            }
        }
        // print("line: {s}\n", .{line});
    }

    var total: usize = 0;
    for (operations.items) |operation| {
        var opTotal: usize = if (operation.sign == Sign.multiply) 1 else 0;
        for (operation.numbers.items) |number| {
            switch (operation.sign) {
                Sign.add => opTotal += number,
                Sign.multiply => opTotal *= number,
            }
        }
        total += opTotal;
        // print("operation: {} | opTotal: {d} | total: {d}\n", .{ operation, opTotal, total });
    }

    return total;
}

const VertOperation = struct {
    len: usize,
    numbers: List([]const u8),
    sign: Sign,

    fn getNumber(self: VertOperation, i: usize) !usize {
        var result: usize = 0;

        for (self.numbers.items) |number| {
            if (i < number.len and number[i] != ' ') {
                result = result * 10 + try charToDigit(number[i], 10);
            }
        }

        return result;
    }
};

fn part2(buffer: []const u8) !usize {
    var operations = List(VertOperation).empty;
    const startAdd = if (indexOf(u8, buffer, '+')) |start| start else buffer.len;
    const startMultiply = if (indexOf(u8, buffer, '*')) |start| start else buffer.len;
    const startSigns = @min(startAdd, startMultiply);
    const lineLength = buffer.len - startSigns + 2;
    const lines = buffer.len / lineLength;

    // print("buffer.len: {d} | startSigns: {d} | lineLength: {d} | lines: {d}\n", .{ buffer.len, startSigns, lineLength, lines });

    for (buffer[startSigns..], 0..) |c, pos| {
        const opItem = if (operations.items.len > 0) &operations.items[operations.items.len - 1] else null;
        switch (c) {
            ' ' => {
                if (opItem) |item| item.len += 1;
            },
            '+', '*' => {
                if (opItem) |item| {
                    const startPos = pos - item.len;
                    item.len -= 1;

                    for (0..lines) |i| {
                        const start = i * lineLength + startPos;
                        const end = start + item.len;
                        // print("start: {d} | end: {d} | item: [{s}]\n", .{ start, end, buffer[start..end] });
                        try item.numbers.append(gpa, buffer[start..end]);
                    }
                }
                try operations.append(gpa, .{ .numbers = .empty, .sign = if (c == '+') Sign.add else Sign.multiply, .len = 1 });
            },
            else => {},
        }
        if (pos == buffer.len - startSigns - 1) {
            if (opItem) |item| {
                const startPos = pos + 1 - item.len;
                for (0..lines) |i| {
                    const start = i * lineLength + startPos;
                    const end = start + item.len;
                    // print("start: {d} | end: {d} | item: [{s}]\n", .{ start, end, buffer[start..end] });
                    try item.numbers.append(gpa, buffer[start..end]);
                }
            }
        }
    }

    var total: usize = 0;
    for (operations.items) |operation| {
        var opTotal: usize = if (operation.sign == Sign.multiply) 1 else 0;
        var i = operation.len - 1;
        while (true) : (i -= 1) {
            const number = try operation.getNumber(i);
            switch (operation.sign) {
                Sign.add => opTotal += number,
                Sign.multiply => opTotal *= number,
            }
            // print("i: {d} | number: {d} | opTotal: {d}\n", .{ i, number, opTotal });
            if (i <= 0) break;
        }
        total += opTotal;
        // print("operation: {} | opTotal: {d} | total: {d}\n", .{ operation, opTotal, total });
    }

    return total;
}

pub fn main() !void {
    const res1 = try part1(data);
    print("Part 1 result: {d}\n", .{res1});

    const res2 = try part2(data);
    print("Part 2 result: {d}\n", .{res2});
}

test "part1" {
    const expected = 4277556;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 3263827;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
