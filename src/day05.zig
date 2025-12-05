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

const data = @embedFile("data/day05.txt");
const data_ex = @embedFile("data/day05_ex.txt");

const Range = struct {
    start: usize,
    end: usize,

    fn inRange(self: Range, id: usize) bool {
        return self.start <= id and id <= self.end;
    }

    fn overlap(self: Range, range: Range) bool {
        return self.start <= range.end and range.start <= self.end;
    }
};

fn part1(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");
    var ranges = List(Range).empty;

    var total: usize = 0;
    while (lineIterator.next()) |line| {
        var rangeIterator = tokenizeSca(u8, line, '-');

        const rangeStart = rangeIterator.next();
        const rangeEnd = rangeIterator.next();

        if (rangeEnd == null) {
            const id = try parseInt(usize, rangeStart.?, 10);
            for (ranges.items) |range| {
                if (range.inRange(id)) {
                    total += 1;
                    break;
                }
            }
        } else if (rangeStart != null and rangeEnd != null) {
            try ranges.append(gpa, .{
                .start = try parseInt(usize, rangeStart.?, 10),
                .end = try parseInt(usize, rangeEnd.?, 10),
            });
        }
        // print("line: {s} | total: {d}\n", .{ line, total });
    }

    return total;
}

fn part2(buffer: []const u8) !usize {
    var lineIterator = tokenizeAny(u8, buffer, "\r\n");
    var ranges = List(Range).empty;

    while (lineIterator.next()) |line| {
        var rangeIterator = tokenizeSca(u8, line, '-');

        const rangeStart = rangeIterator.next();
        const rangeEnd = rangeIterator.next();

        if (rangeEnd == null) {
            break;
        } else if (rangeStart != null and rangeEnd != null) {
            var range: Range = .{
                .start = try parseInt(usize, rangeStart.?, 10),
                .end = try parseInt(usize, rangeEnd.?, 10),
            };

            var i: usize = 0;
            while (i < ranges.items.len) {
                if (range.overlap(ranges.items[i])) {
                    range.start = @min(range.start, ranges.items[i].start);
                    range.end = @max(range.end, ranges.items[i].end);
                    _ = ranges.swapRemove(i);
                    continue;
                }
                i += 1;
            }
            try ranges.append(gpa, range);
        }
        // print("line: {s}\n", .{line});
    }

    var total: usize = 0;
    for (ranges.items) |range| {
        total += range.end + 1 - range.start;
        // print("range: {} | diff: {d} | total {d}\n", .{ range, range.end + 1 - range.start, total });
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
    const expected = 14;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
