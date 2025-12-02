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
const bufPrint = std.fmt.bufPrint;
const printInt = std.fmt.printInt;
const print = std.debug.print;
const assert = std.debug.assert;
const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");
const data_ex = @embedFile("data/day02_ex.txt");

fn part1(buffer: []const u8) !usize {
    var rangesIterator = tokenizeAny(u8, buffer, ",");

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (rangesIterator.next()) |range| {
        var idsIterator = tokenizeSca(u8, range, '-');
        const firstId = if (idsIterator.next()) |id| id else continue;
        const lastId = if (idsIterator.next()) |id| id else continue;
        var currNum = try parseInt(usize, firstId, 10);
        const lastNum = try parseInt(usize, lastId, 10);

        while (currNum <= lastNum) {
            const num = buf[0..printInt(&buf, currNum, 10, .lower, .{})];
            if (@mod(num.len, 2) == 0) {
                const middle = @divExact(num.len, 2);
                if (std.mem.eql(u8, num[0..middle], num[middle..])) {
                    total += currNum;
                    // print("invalid ID: {d}\n", .{currNum});
                }
            }
            currNum += 1;
        }
        // print("range: {s} | firstId: {s} | lastId: {s} | total: {d}\n", .{ range, firstId, lastId, total });
    }

    return total;
}

fn part2(buffer: []const u8) !usize {
    var rangesIterator = tokenizeAny(u8, buffer, ",");

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (rangesIterator.next()) |range| {
        var idsIterator = tokenizeSca(u8, range, '-');
        const firstId = if (idsIterator.next()) |id| id else continue;
        const lastId = if (idsIterator.next()) |id| id else continue;
        var currNum = try parseInt(usize, firstId, 10);
        const lastNum = try parseInt(usize, lastId, 10);

        while (currNum <= lastNum) {
            const num = buf[0..printInt(&buf, currNum, 10, .lower, .{})];

            var splits: usize = 2;
            while (splits <= num.len) {
                const size = @divFloor(num.len, splits);
                const base = num[0..size];

                var currPos: usize = size;
                const invalid = while (currPos < num.len) : (currPos += size) {
                    if (!std.mem.eql(u8, base, num[currPos..@min(currPos + size, num.len)])) {
                        break false;
                    }
                } else true;
                if (invalid) {
                    total += currNum;
                    // print("invalid ID: {d}\n", .{currNum});
                    break;
                }
                splits += 1;
            }
            currNum += 1;
        }
        // print("range: {s} | firstId: {s} | lastId: {s} | total: {d}\n", .{ range, firstId, lastId, total });
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
    const expected = 1227775554;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 4174379265;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
