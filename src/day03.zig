const std = @import("std");

fn getLargestJoltage2digit(bank: []u8) u8 {
    var largest: u8 = 0;
    var second_largest: u8 = 0;
    var index: usize = undefined;

    for(bank, 0..) |battery, i| {
        if(battery > largest and i != bank.len - 1) {
            largest = battery;
            index = i;
        } 
    }

    for(bank, 0..) |battery, i| {
        if(i > index and battery > second_largest) {
            second_largest = battery;
        } 
    }

    return ((largest - '0') * 10) + (second_largest - '0');
}

fn getLargestJoltage12digit(bank: []u8) usize {
    var digit_count: u8 = 0;
    var index: usize = 0;
    var max_range: usize = 0;
    var jolts: usize = 0;

    while(digit_count < 12) {
        digit_count += 1;
        max_range = bank.len - (12 - digit_count);

        const temp_bank = bank[index..max_range];
        const pos = std.mem.indexOfMax(u8, temp_bank);

        jolts += (temp_bank[pos] - '0') * std.math.pow(usize, 10, (12 - digit_count));
        index += pos + 1;
    }

    return jolts;
}

fn puzzle05(reader: *std.Io.Reader) !void {
    var sum: usize = 0;

    while(true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        const jolt = getLargestJoltage2digit(line);    
        sum += @as(usize, jolt);
//        std.debug.print("line: {s} - jolt: {d}\n\n", .{line, jolt});

        reader.toss(1);
    }

    std.debug.print("Max joltage is: {d}\n", .{sum});
}

fn puzzle06(reader: *std.Io.Reader) !void {
    var sum: usize = 0;

    while(true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        const jolt = getLargestJoltage12digit(line);    
        sum += @as(usize, jolt);
//        std.debug.print("line: {s} - jolt: {d}\n\n", .{line, jolt});
        reader.toss(1);
    }

    std.debug.print("Max joltage is: {d}\n", .{sum});
}

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day03", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle05(reader);
    try data_reader.seekTo(0);
    try puzzle06(reader);
}
