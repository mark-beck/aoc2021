const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    if (std.os.argv.len != 2) {
        std.debug.print("missing argument\n", .{});
        std.os.exit(1);
    }
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();
    var args = std.process.args();

    _ = args.next(alloc);
    const filepath = try args.next(alloc).?;

    const file = try std.fs.cwd().openFile(filepath, .{});

    const reader = file.reader();
    var buffer: [500]u8 = undefined;

    var numberlist = std.ArrayList([]bool).init(alloc);

    while (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var sublist = std.ArrayList(bool).init(alloc);
        for (line) |c| {
            if (c == '1') {
                try sublist.append(true);
            } else if (c == '0') {
                try sublist.append(false);
            } else {
                print("unkown symbol", .{});
                std.os.exit(1);
            }
        }
        try numberlist.append(sublist.items);
    }

    
    var counts = std.ArrayList(i32).init(alloc);

    for (numberlist.items[0]) |_| {
        try counts.append(0);
    }

    for (numberlist.items) |line| {
        for (line) |c, i| {
            if (c) {
                counts.items[i] += 1;
            } else {
                counts.items[i] -= 1;
            }
        }
    }
    
    const number = reduceArray(counts.items);
    print("result 1 number = {}\n", .{number});

    const oxygen_row = try solveOxygen(alloc, numberlist.items);
    const co2_row = try solveCO2(alloc, numberlist.items);
    const oxygen = boolArrayToNumber(oxygen_row);
    const co2 = boolArrayToNumber(co2_row);
    print("### Result 2 ###\n", .{});
    printRow(bool, oxygen_row);
    print("Oxygen = {}\n", .{oxygen});
    printRow(bool, co2_row);
    print("CO2    = {}\n", .{co2});
    print("{}\n", .{oxygen * co2});
}

fn arrayToNumber(array: []i32) u64 {
    var number: u64 = 0;

    var i: usize = 0;
    while (i < array.len) : (i += 1) {
        number += @intCast(u64, array[array.len - i - 1]) * (@intCast(u64, 1) << @intCast(u5, i));
    }
    return number;
}

fn boolArrayToNumber(array: []bool) u64 {
    var number: u64 = 0;

    var i: usize = 0;
    while (i < array.len) : (i += 1) {
        
        number += @intCast(u64, @boolToInt(array[array.len - i - 1])) * (@intCast(u64, 1) << @intCast(u5, i));
    }
    return number;
}

fn reduceArray(array: []i32) u64 {
    var i: usize = 0;
    while (i < array.len) : (i += 1) {
        if (array[i] > 0) {
            array[i] = 1;
        } else if (array[i] < 0) {
            array[i] = 0;
        } else {
            print("Error", .{});
            std.os.exit(1);
        }
    }

    const num1 = arrayToNumber(array);

    i = 0;
    while (i < array.len) : (i += 1) {
        if (array[i] == 1) {
            array[i] = 0;
        } else {
            array[i] = 1;
        }
    }

    const num2 = arrayToNumber(array);
    return num1 * num2;
}

fn reduceRow(array: [][]bool, index: usize) ?bool {
    var trues: u64 = 0;
    var falses: u64 = 0;
    for (array) |e| {
        if (e[index]) {
            trues += 1;
        } else {
            falses += 1;
        }
    }
    if (trues == falses) {
        print("found same at pos {}", .{index});
        return null;
    }
    return trues > falses;
}

fn filterOxygenArray(alloc: std.mem.Allocator, comptime T: type, array: []T, index: usize, target: ?bool) ![]T {
    var new_array = std.ArrayList(T).init(alloc);
    for (array) |e| {
        if (e[index] == target orelse true) {
            try new_array.append(e);
        }
    }
    return new_array.items;
}

fn filterCO2Array(alloc: std.mem.Allocator, comptime T: type, array: []T, index: usize, target: ?bool) ![]T {
    var new_array = std.ArrayList(T).init(alloc);
    for (array) |e| {
        if (e[index] != target orelse true) {
            try new_array.append(e);
        }
    }
    return new_array.items;
}



fn solveOxygen(alloc: std.mem.Allocator, array: [][]bool) ![]bool {
    var i: usize = 0;
    var newarray = array;
    while (i < array[0].len) : (i += 1) {
        const target = reduceRow(newarray, i);

        // print("index = {}", .{i});
        // print("target = {}", .{target});
        // printMatrix(bool, newarray);

        newarray = try filterOxygenArray(alloc, []bool, newarray, i, target);
        if (newarray.len == 1) {
            return newarray[0];
        }
        if (newarray.len == 0) {
            return error.noelement;
        }

    }
    return error.toomany;
}

fn solveCO2(alloc: std.mem.Allocator, array: [][]bool) ![]bool {
    var i: usize = 0;
    var newarray = array;
    while (i < array[0].len) : (i += 1) {
        const target = reduceRow(newarray, i);

        // print("index = {}", .{i});
        // print("target = {}", .{target});
        // printMatrix(bool, newarray);

        newarray = try filterCO2Array(alloc, []bool, newarray, i, target);
        if (newarray.len == 1) {
            return newarray[0];
        }
        if (newarray.len == 0) {
            return error.noelement;
        }

    }
    return error.toomany;
}

fn printRow(comptime T: type, array: []T) void {
    print("[", .{});
    for (array) |e| {
        print("{},", .{e});
    }
    print("]\n", .{});
}

fn printMatrix(comptime T: type, array: [][]T) void {
    print("###\n", .{});
    for (array) |row| {
        printRow(T, row);
    }
    print("###\n\n", .{});
}