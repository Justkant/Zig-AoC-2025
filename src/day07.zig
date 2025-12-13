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

const data = @embedFile("data/day07.txt");
const data_ex = @embedFile("data/day07_ex.txt");

fn part1(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    const lineLen = if (lineIterator.peek()) |line| line.len else 0;
    const lineCount = @divFloor(buffer.len, lineLen + lineSep.len) + 1;
    var lines: []u8 = try gpa.alloc(u8, lineCount * lineLen);
    // print("lineLen {d} | lineCount: {d} | linesLen: {d}\n", .{ lineLen, lineCount, lineCount * lineLen });

    var i: usize = 0;
    while (lineIterator.next()) |line| : (i += 1) {
        const pos = i * line.len;
        @memcpy(lines[pos .. pos + lineLen], line);
        // print("line {s} | pos: {d} | posEnd: {d}\n", .{ line, pos, pos + lineLen });
    }

    var total: usize = 0;
    for (lineLen..lines.len) |l| {
        const upper = lines[l - lineLen];
        if (upper == 'S' or upper == '|') {
            if (lines[l] == '^') {
                const currLine = @divFloor(l, lineLen);
                const lineStart = currLine * lineLen;
                const lineEnd = (currLine + 1) * lineLen;
                const prevPos = @max(l - 1, lineStart);
                const nextPos = @min(l + 1, lineEnd);
                lines[prevPos] = '|';
                lines[nextPos] = '|';
                total += 1;
            } else {
                lines[l] = '|';
            }
        }
    }

    return total;
}

const Node = struct {
    pos: usize = 0,
    total: usize = 0,
    left: ?*Node = null,
    right: ?*Node = null,
    bottom: ?*Node = null,
    fn getTotal(self: *Node) usize {
        if (self.total != 0) {
            return self.total;
        }

        const done = self.left == null and self.right == null and self.bottom == null;
        if (done) {
            self.total = 1;
            return 1;
        }

        var total: usize = 0;
        if (self.left) |l| {
            total += l.getTotal();
        }
        if (self.bottom) |b| {
            total += b.getTotal();
        }
        if (self.right) |r| {
            total += r.getTotal();
        }
        self.total = total;
        return total;
    }
};

fn part2(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    const lineLen = if (lineIterator.peek()) |line| line.len else 0;
    const lineCount = @divFloor(buffer.len, lineLen + lineSep.len) + 1;
    var lines: []u8 = try gpa.alloc(u8, lineCount * lineLen);
    // print("lineLen {d} | lineCount: {d} | linesLen: {d}\n", .{ lineLen, lineCount, lineCount * lineLen });

    var i: usize = 0;
    while (lineIterator.next()) |line| : (i += 1) {
        const pos = i * line.len;
        @memcpy(lines[pos .. pos + lineLen], line);
    }

    var startNode: ?*Node = null;
    var nodes: []Node = try gpa.alloc(Node, lineCount * lineLen);
    for (nodes) |*node| {
        node.* = .{};
    }
    for (lineLen..lines.len) |l| {
        const upper = lines[l - lineLen];
        if (upper == 'S') {
            nodes[l - lineLen].pos = l - lineLen;
            startNode = &nodes[l - lineLen];
        }

        if (upper == 'S' or upper == '|') {
            if (lines[l] == '^') {
                const currLine = @divFloor(l, lineLen);
                const lineStart = currLine * lineLen;
                const lineEnd = (currLine + 1) * lineLen;
                const prevPos = @max(l - 1, lineStart);
                const nextPos = @min(l + 1, lineEnd);
                lines[prevPos] = '|';
                lines[nextPos] = '|';
                nodes[l - lineLen].pos = l - lineLen;
                nodes[l - lineLen].left = &nodes[prevPos];
                nodes[l - lineLen].right = &nodes[nextPos];
                nodes[prevPos].pos = prevPos;
                nodes[nextPos].pos = nextPos;
            } else {
                lines[l] = '|';
                nodes[l].pos = l;
                nodes[l - lineLen].bottom = &nodes[l];
            }
        }
    }

    return if (startNode) |node| node.getTotal() else 0;
}

pub fn main() !void {
    const res1 = try part1(data);
    print("Part 1 result: {d}\n", .{res1});

    const res2 = try part2(data);
    print("Part 2 result: {d}\n", .{res2});
}

test "part1" {
    const expected = 21;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 40;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
