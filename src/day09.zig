const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const PriorityQueue = std.PriorityQueue;
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

const data = @embedFile("data/day09.txt");
const data_ex = @embedFile("data/day09_ex.txt");

fn absDiff(a: usize, b: usize) usize {
    return if (a > b) a - b else b - a;
}

const Pos = struct {
    x: usize,
    y: usize,
    fn square(self: Pos, pos: Pos) usize {
        return (absDiff(self.x, pos.x) + 1) * (absDiff(self.y, pos.y) + 1);
    }
    fn eql(self: Pos, pos: Pos) bool {
        return self.x == pos.x and self.y == pos.y;
    }
};

const Square = struct {
    firstCorner: Pos,
    secondCorner: Pos,
    area: usize,
};

fn descArea(context: void, a: Square, b: Square) std.math.Order {
    _ = context;
    return std.math.order(b.area, a.area);
}

const SquaresPQ = PriorityQueue(
    Square,
    void,
    descArea,
);

fn getSquares(squares: *SquaresPQ, tiles: []Pos) !void {
    for (0..tiles.len) |i| {
        for (i + 1..tiles.len) |j| {
            const area = tiles[i].square(tiles[j]);
            try squares.add(.{
                .firstCorner = tiles[i],
                .secondCorner = tiles[j],
                .area = area,
            });
        }
    }
}

fn part1(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    var tiles = List(Pos).empty;
    defer tiles.deinit(gpa);

    while (lineIterator.next()) |line| {
        var posIterator = splitSca(u8, line, ',');
        try tiles.append(gpa, .{
            .x = try parseInt(usize, posIterator.next().?, 10),
            .y = try parseInt(usize, posIterator.next().?, 10),
        });
    }

    var squares = SquaresPQ.init(gpa, {});
    defer squares.deinit();
    try getSquares(&squares, tiles.items);

    // print("tiles: {any}\n", .{tiles.items});
    const biggestSquare = squares.remove();
    // print("biggest square: {any}\n", .{biggestSquare});

    return biggestSquare.area;
}

fn isSquareInTiles(square: Square, tiles: List(Pos)) bool {
    const leftCol = @min(square.firstCorner.x, square.secondCorner.x);
    const rightCol = @max(square.firstCorner.x, square.secondCorner.x);
    const topRow = @min(square.firstCorner.y, square.secondCorner.y);
    const bottomRow = @max(square.firstCorner.y, square.secondCorner.y);

    var i: usize = 0;
    var j: usize = tiles.items.len - 1;
    while (i < tiles.items.len) : ({
        j = i;
        i += 1;
    }) {
        const a = tiles.items[i];
        const b = tiles.items[j];

        if (a.x == b.x) {
            // vertical edge
            const col = a.x;
            // check vertical edge is within the cols of the current rectangle
            if (col <= leftCol or col >= rightCol) continue;

            const topEdge = @min(a.y, b.y);
            const bottomEdge = @max(a.y, b.y);
            if (topEdge <= topRow and bottomEdge > topRow) return false;
            if (topEdge < bottomRow and bottomEdge >= bottomRow) return false;
        } else {
            // horizontal edge
            const row = a.y;
            // check horizontal edge is within the rows of the current rectangle
            if (row <= topRow or row >= bottomRow) continue;

            const leftEdge = @min(a.x, b.x);
            const rightEdge = @max(a.x, b.x);
            if (leftEdge <= leftCol and rightEdge > leftCol) return false;
            if (leftEdge < rightCol and rightEdge >= rightCol) return false;
        }
    }
    return true;
}

fn part2(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    var tiles = List(Pos).empty;
    defer tiles.deinit(gpa);

    while (lineIterator.next()) |line| {
        var posIterator = splitSca(u8, line, ',');
        try tiles.append(gpa, .{
            .x = try parseInt(usize, posIterator.next().?, 10),
            .y = try parseInt(usize, posIterator.next().?, 10),
        });
    }

    var squares = SquaresPQ.init(gpa, {});
    defer squares.deinit();
    try getSquares(&squares, tiles.items);

    for (0..squares.items.len) |_| {
        const square = squares.remove();
        if (isSquareInTiles(square, tiles)) {
            return square.area;
        }
    }

    return 0;
}

pub fn main() !void {
    const res1 = try part1(data);
    print("Part 1 result: {d}\n", .{res1});

    const res2 = try part2(data);
    print("Part 2 result: {d}\n", .{res2});
}

test "part1" {
    const expected = 50;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 24;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
