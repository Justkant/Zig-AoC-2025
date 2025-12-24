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

const data = @embedFile("data/day10.txt");
const data_ex = @embedFile("data/day10_ex.txt");

const Machine = struct {
    indicatorLightDiagram: []const u8 = &.{},
    buttonWiringSchematics: List(List(usize)) = .empty,
    joltageRequirements: List(usize) = .empty,
};

fn part1(buffer: []const u8) !usize {
    const lineSep = "\r\n";
    var lineIterator = tokenizeAny(u8, buffer, lineSep);
    var machines = List(Machine).empty;

    while (lineIterator.next()) |line| {
        var machineIterator = splitSca(u8, line, ' ');
        var machine: Machine = .{};
        while (machineIterator.next()) |machineData| {
            switch (machineData[0]) {
                '[' => {
                    machine.indicatorLightDiagram = machineData[1 .. machineData.len - 1];
                },
                '(' => {
                    var buttonIterator = splitSca(u8, machineData[1 .. machineData.len - 1], ',');
                    var buttonLights = List(usize).empty;
                    while (buttonIterator.next()) |button| {
                        try buttonLights.append(gpa, try parseInt(usize, button, 10));
                    }
                    try machine.buttonWiringSchematics.append(gpa, buttonLights);
                },
                '{' => {
                    var joltageIterator = splitSca(u8, machineData[1 .. machineData.len - 1], ',');
                    while (joltageIterator.next()) |joltage| {
                        try machine.joltageRequirements.append(gpa, try parseInt(usize, joltage, 10));
                    }
                },
                else => {},
            }
        }
        try machines.append(gpa, machine);
    }

    for (machines.items, 0..) |machine, i| {
        print("\r\nmachine: {d}\n", .{i});
        print("lights: {s}\n", .{machine.indicatorLightDiagram});
        print("buttons: {d}\n", .{machine.buttonWiringSchematics.items.len});
        for (machine.buttonWiringSchematics.items, 1..) |button, j| {
            print("  button {d}: {any}\n", .{ j, button.items });
        }
        print("joltages: {any}\n", .{machine.joltageRequirements.items});
    }

    return 0;
}

fn part2(buffer: []const u8) !usize {
    _ = buffer; // autofix
    return 0;
}

pub fn main() !void {
    const res1 = try part1(data);
    print("Part 1 result: {d}\n", .{res1});

    const res2 = try part2(data);
    print("Part 2 result: {d}\n", .{res2});
}

test "part1" {
    const expected = 7;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 0;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
