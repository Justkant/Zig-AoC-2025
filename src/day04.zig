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

const data = @embedFile("data/day04.txt");
const data_ex = @embedFile("data/day04_ex.txt");

fn part1(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");

    var total: usize = 0;
    var prevLine: ?[]const u8 = null;
    while (lineIterator.next()) |line| {
        const nextLine = lineIterator.peek();
        for (line, 0..) |case, i| {
            if (case == '@') {
                // check all around
                var around: usize = 0;
                if (i > 0 and line[i - 1] == '@') around += 1;
                if (i + 1 < line.len and line[i + 1] == '@') around += 1;
                if (prevLine != null and prevLine.?[i] == '@') around += 1;
                if (prevLine != null and i > 0 and prevLine.?[i - 1] == '@') around += 1;
                if (prevLine != null and i + 1 < prevLine.?.len and prevLine.?[i + 1] == '@') around += 1;
                if (nextLine != null and nextLine.?[i] == '@') around += 1;
                if (nextLine != null and i > 0 and nextLine.?[i - 1] == '@') around += 1;
                if (nextLine != null and i + 1 < nextLine.?.len and nextLine.?[i + 1] == '@') around += 1;

                if (around < 4) total += 1;
            }
        }

        // print("prevLine: {?s} | line: {s} | nextLine: {?s} | total: {d}\n", .{ prevLine, line, nextLine, total });
        prevLine = line;
    }

    return total;
}

fn part2(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");

    var map: [200][200]u8 = .{.{0} ** 200} ** 200;
    var mapLength: usize = 0;
    while (lineIterator.next()) |line| : (mapLength += 1) {
        for (line, 0..) |case, j| {
            map[mapLength][j] = case;
        }
    }

    var total: usize = 0;
    while (true) {
        var loopTotal: usize = 0;
        for (map, 0..) |line, lineIndex| {
            if (line[0] == 0) break;
            const prevLine = if (lineIndex > 0) map[lineIndex - 1] else null;
            const nextLine = if (lineIndex + 1 < map.len) map[lineIndex + 1] else null;
            for (line, 0..) |case, i| {
                if (case == 0) break;
                if (case == '@') {
                    // check all around
                    var around: usize = 0;
                    if (i > 0 and (line[i - 1] == '@' or line[i - 1] == 'x')) around += 1;
                    if (i + 1 < line.len and line[i + 1] == '@') around += 1;
                    if (prevLine != null and (prevLine.?[i] == '@' or prevLine.?[i] == 'x')) around += 1;
                    if (prevLine != null and i > 0 and (prevLine.?[i - 1] == '@' or prevLine.?[i - 1] == 'x')) around += 1;
                    if (prevLine != null and i + 1 < prevLine.?.len and (prevLine.?[i + 1] == '@' or prevLine.?[i + 1] == 'x')) around += 1;
                    if (nextLine != null and nextLine.?[i] == '@') around += 1;
                    if (nextLine != null and i > 0 and nextLine.?[i - 1] == '@') around += 1;
                    if (nextLine != null and i + 1 < nextLine.?.len and nextLine.?[i + 1] == '@') around += 1;

                    if (around < 4) {
                        loopTotal += 1;
                        map[lineIndex][i] = 'x';
                    }
                }
            }

            // print("prevLine: {?s} | line: {s} | nextLine: {?s} | loopTotal: {d} | total: {d}\n", .{ prevLine, line, nextLine, loopTotal, total });

            if (prevLine != null) {
                for (0..mapLength) |i| {
                    if (map[lineIndex - 1][i] == 'x') map[lineIndex - 1][i] = '.';
                }
            }

            if (nextLine != null and nextLine.?[0] == 0) {
                for (0..mapLength) |i| {
                    if (map[lineIndex][i] == 'x') map[lineIndex][i] = '.';
                }
            }
        }

        if (loopTotal == 0) break;
        total += loopTotal;
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
    const expected = 13;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 43;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
