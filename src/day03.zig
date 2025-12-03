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

const data = @embedFile("data/day03.txt");
const data_ex = @embedFile("data/day03_ex.txt");

fn part1(buffer: []const u8) !usize {
    var bankIterator = tokenizeAny(u8, buffer, "\r\n");

    var total: usize = 0;
    while (bankIterator.next()) |bank| {
        var firstBattery: u8 = 0;
        var secondBattery: u8 = 0;
        for (bank[0 .. bank.len - 1]) |battery| {
            const value = try std.fmt.charToDigit(battery, 10);
            if (value > firstBattery) {
                firstBattery = value;
                secondBattery = 0;
            } else if (value > secondBattery) {
                secondBattery = value;
            }
        }
        const value = try std.fmt.charToDigit(bank[bank.len - 1], 10);
        if (value > secondBattery) {
            secondBattery = value;
        }

        total += firstBattery * 10 + secondBattery;

        // print("bank: {s} | firstBattery: {d} | secondBattery: {d} | total: {d}\n", .{ bank, firstBattery, secondBattery, total });
    }

    return total;
}

fn part2(buffer: []const u8) !usize {
    var bankIterator = tokenizeAny(u8, buffer, "\r\n");

    var total: usize = 0;
    while (bankIterator.next()) |bank| {
        var activeBatteries = [_]u8{0} ** 12;
        var bankStart: usize = 0;
        var activePos: usize = 0;
        while (activePos < activeBatteries.len) : (activePos += 1) {
            const remaining = activeBatteries.len - 1 - activePos;
            const bankEnd = bank.len - remaining;
            const bankVue = bank[bankStart..bankEnd];
            for (bankVue, bankStart..) |battery, bankPos| {
                const value = try std.fmt.charToDigit(battery, 10);
                if (value > activeBatteries[activePos]) {
                    activeBatteries[activePos] = value;
                    for (activePos + 1..activeBatteries.len) |j| {
                        activeBatteries[j] = 0;
                    }
                    bankStart = bankPos + 1;
                }
                // print("value: {d} | bankStart: {d} | bankEnd: {d} | activeStart: {d} | remaining: {d} | activeBatteries: {any} | bank vue: {s} \n", .{ value, bankStart, bankEnd, activeStart, remaining, activeBatteries, bankVue });
            }
        }

        var bankJoltage: usize = 0;
        for (0..activeBatteries.len) |i| {
            const pos = activeBatteries.len - 1 - i;
            if (activeBatteries[pos] == 0) {
                print("incomplete bank, couldn't find 12 active batteries\n", .{});
                break;
            }
            bankJoltage += activeBatteries[pos] * std.math.pow(usize, 10, i);
        }

        total += bankJoltage;

        // print("bank: {s} | activeBatteries: {any} | bankJoltage: {d} | total: {d}\n", .{ bank, activeBatteries, bankJoltage, total });
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
    const expected = 357;
    const actual = try part1(data_ex);
    try std.testing.expectEqual(expected, actual);
}

test "part2" {
    const expected = 3121910778619;
    const actual = try part2(data_ex);
    try std.testing.expectEqual(expected, actual);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
