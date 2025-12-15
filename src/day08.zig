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
const pow = std.math.pow;
const sqrt = std.math.sqrt;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const data_ex = @embedFile("data/day08_ex.txt");

fn absDiff(a: usize, b: usize) usize {
    return if (a > b) a - b else b - a;
}

const Pos = struct {
    x: usize,
    y: usize,
    z: usize,
    fn distance(self: Pos, pos: Pos) usize {
        const x = pow(usize, absDiff(self.x, pos.x), 2);
        const y = pow(usize, absDiff(self.y, pos.y), 2);
        const z = pow(usize, absDiff(self.z, pos.z), 2);
        return sqrt(x + y + z);
    }
    fn eql(self: Pos, pos: Pos) bool {
        return self.x == pos.x and self.y == pos.y and self.z == pos.z;
    }
};

const Pair = struct {
    first: Pos,
    second: Pos,
    distance: usize,
};

fn ascDistance(context: void, a: Pair, b: Pair) std.math.Order {
    _ = context;
    return std.math.order(a.distance, b.distance);
}

const PairsPQ = PriorityQueue(
    Pair,
    void,
    ascDistance,
);

fn getClosestPairs(pairs: *PairsPQ, boxes: []Pos) !void {
    for (0..boxes.len) |i| {
        for (i + 1..boxes.len) |j| {
            const distance = boxes[i].distance(boxes[j]);
            try pairs.add(.{
                .first = boxes[i],
                .second = boxes[j],
                .distance = distance,
            });
        }
    }
}

const Circuit = struct {
    boxes: List(Pos) = .empty,
    fn contains(self: Circuit, pair: Pair) bool {
        for (self.boxes.items) |box| {
            if (box.eql(pair.first) or box.eql(pair.second)) return true;
        }
        return false;
    }
    fn add(self: *Circuit, alloc: Allocator, pair: Pair) !void {
        var addFirst = true;
        var addSecond = true;
        for (self.boxes.items) |box| {
            if (box.eql(pair.first)) addFirst = false;
            if (box.eql(pair.second)) addSecond = false;
        }
        if (addFirst) try self.boxes.append(alloc, pair.first);
        if (addSecond) try self.boxes.append(alloc, pair.second);
    }
    fn merge(self: *Circuit, alloc: Allocator, circuit: *Circuit) !void {
        for (circuit.boxes.items) |item| {
            for (self.boxes.items) |selfItem| {
                if (selfItem.eql(item)) break;
            } else {
                try self.boxes.append(alloc, item);
            }
        }
    }
};

fn greaterThan(context: void, a: usize, b: usize) std.math.Order {
    _ = context; // autofix
    return std.math.order(a, b).invert();
}

const PQgt = PriorityQueue(usize, void, greaterThan);

fn part1(buffer: []const u8, maxPairs: usize) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    var boxes = List(Pos).empty;
    defer boxes.deinit(gpa);
    var circuits = List(Circuit).empty;
    defer {
        for (circuits.items) |*c| c.boxes.deinit(gpa);
        circuits.deinit(gpa);
    }

    while (lineIterator.next()) |line| {
        var posIterator = splitSca(u8, line, ',');
        try boxes.append(gpa, .{
            .x = try parseInt(usize, posIterator.next().?, 10),
            .y = try parseInt(usize, posIterator.next().?, 10),
            .z = try parseInt(usize, posIterator.next().?, 10),
        });
    }

    // Build distance for all possible pairs
    var pairs = PairsPQ.init(gpa, {});
    defer pairs.deinit();
    try getClosestPairs(&pairs, boxes.items);

    // Take half of the boxes length pairs by lower distance
    for (0..maxPairs) |_| {
        const pair = pairs.remove();
        // print("pair: {any}\n", .{pair});

        // Merge pairs in circuits
        var added: ?*Circuit = null;
        var i: usize = circuits.items.len;
        while (i > 0) {
            i -= 1;
            var circuit = &circuits.items[i];
            if (circuit.contains(pair)) {
                if (added) |addedCircuit| {
                    try addedCircuit.merge(gpa, circuit);
                    _ = circuits.swapRemove(i);
                } else {
                    try circuit.add(gpa, pair);
                    added = circuit;
                }
            }
        }
        if (added == null) {
            var circuit: Circuit = .{};
            try circuit.add(gpa, pair);
            try circuits.append(gpa, circuit);
        }
    }

    // Take the 3 biggest circuits
    // Multiply the size of the 3 circuits
    var orderedSizes = PQgt.init(gpa, {});
    defer orderedSizes.deinit();
    for (circuits.items) |circuit| {
        try orderedSizes.add(circuit.boxes.items.len);
        // print("circuit: {d} {any}\n", .{ circuit.boxes.items.len, circuit.boxes.items });
    }

    const sizes: [3]usize = .{ orderedSizes.remove(), orderedSizes.remove(), orderedSizes.remove() };
    // print("sizes: {any}\n", .{sizes});

    return sizes[0] * sizes[1] * sizes[2];
}

fn part2(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    var boxes = List(Pos).empty;
    defer boxes.deinit(gpa);
    var circuits = List(Circuit).empty;
    defer {
        for (circuits.items) |*c| c.boxes.deinit(gpa);
        circuits.deinit(gpa);
    }

    while (lineIterator.next()) |line| {
        var posIterator = splitSca(u8, line, ',');
        try boxes.append(gpa, .{
            .x = try parseInt(usize, posIterator.next().?, 10),
            .y = try parseInt(usize, posIterator.next().?, 10),
            .z = try parseInt(usize, posIterator.next().?, 10),
        });
    }

    // Build distance for all possible pairs
    var pairs = PairsPQ.init(gpa, {});
    defer pairs.deinit();
    try getClosestPairs(&pairs, boxes.items);

    // Merge all pairs into a single circuit
    var latestPair: ?Pair = null;
    while (pairs.count() > 0) {
        const pair = pairs.remove();
        // print("pair: {any}\n", .{pair});

        var added: ?*Circuit = null;
        var i: usize = circuits.items.len;
        while (i > 0) {
            i -= 1;
            var circuit = &circuits.items[i];
            if (circuit.contains(pair)) {
                if (added) |addedCircuit| {
                    try addedCircuit.merge(gpa, circuit);
                    _ = circuits.swapRemove(i);
                    if (latestPair == null and circuits.items.len == 1 and circuits.items[0].boxes.items.len == boxes.items.len) {
                        latestPair = pair;
                    }
                } else {
                    try circuit.add(gpa, pair);
                    added = circuit;
                    if (latestPair == null and circuits.items.len == 1 and circuits.items[0].boxes.items.len == boxes.items.len) {
                        latestPair = pair;
                    }
                }
            }
        }
        if (added == null) {
            var circuit: Circuit = .{};
            try circuit.add(gpa, pair);
            try circuits.append(gpa, circuit);
        }
    }

    // Take the latest pair making a single circuit
    // Multiply the x pos of the last pair
    return if (latestPair) |p| p.first.x * p.second.x else 0;
}

pub fn main() !void {
    const res1 = try part1(data, 1000);
    print("Part 1 result: {d}\n", .{res1});

    const res2 = try part2(data);
    print("Part 2 result: {d}\n", .{res2});
}

test "part1" {
    const expected = 40;
    const actual = try part1(data_ex, 10);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 25272;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
