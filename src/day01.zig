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
const print = std.debug.print;
const assert = std.debug.assert;
const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");
const data_ex = @embedFile("data/day01_ex.txt");

fn part1(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");

    var total: usize = 0;
    var pos: isize = 50;
    while (lineIterator.next()) |line| {
        const distance = @mod(try parseInt(isize, line[1..], 10), 100);

        pos += switch (line[0]) {
            'L' => -distance,
            'R' => distance,
            else => 0,
        };

        pos += if (pos < 0) 100 else if (pos > 99) -100 else 0;

        if (pos == 0) total += 1;

        // print("line: {s} | distance: {d} | pos: {d} | total: {d}\n", .{ line, distance, pos, total });
    }

    return total;
}

fn part2(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");

    var total: usize = 0;
    var pos: isize = 50;
    while (lineIterator.next()) |line| {
        const distance = try parseInt(isize, line[1..], 10);

        // add full rotations
        total += @divFloor(@as(usize, @intCast(distance)), 100);

        const finalDistance = @mod(distance, 100);
        const prevPos = pos;
        pos += switch (line[0]) {
            'L' => -finalDistance,
            'R' => finalDistance,
            else => 0,
        };

        const rotated = blk: {
            if (pos < 0) {
                pos += 100;
                if (prevPos != 0) break :blk true;
            } else if (pos > 99) {
                pos -= 100;
                break :blk true;
            }
            break :blk false;
        };

        if (pos == 0 or rotated) total += 1;

        // print("line: {s} | distance: {d} | rotations: {d} | finalDistance: {d} | pos: {d} | total: {d}\n", .{ line, distance, @divFloor(@as(usize, @intCast(distance)), 100), finalDistance, pos, total });
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
    const expected = 3;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 6;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
