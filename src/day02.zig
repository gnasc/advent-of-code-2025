const std = @import("std");

const ParsingError = error{ InvalidRange };

fn isDoubleSequenceString(number: usize) bool {
    var str_buffer: [1024]u8 = undefined;

    const number_str: []u8 = std.fmt.bufPrint(&str_buffer, "{d}", .{number}) catch {
        return false;
    };

    if(number_str.len % 2 != 0) return false;

    const half = number_str.len / 2;
    
    return std.mem.eql(u8, number_str[0..half], number_str[half..]);
}

fn isRepeatedSequence(number: usize) bool {
    var str_buffer: [1024]u8 = undefined;

    const number_str: []u8 = std.fmt.bufPrint(&str_buffer, "{d}", .{number}) catch {
        return false;
    };

    if(number_str.len <= 1) return false;

    var current: []u8 = undefined;
    var next: []u8 = undefined;

    var offset: usize = 1;
    var length: usize = 1;

    while(offset + length <= number_str.len) {
        current = number_str[0..length];
        next = number_str[offset..(offset + length)];

//        std.debug.print("n: {d} - c: {s} - n: {s} - o: {d} - l: {d}\n", .{number, current, next, offset, length});

        if(std.mem.eql(u8, current, next)) {
            if(offset + length == number_str.len) return true;
            offset += length; 
        } else {
            length += 1;
            offset = length;
        }
    }

    return false;
}

fn puzzle03(reader: *std.Io.Reader) !void{
    const line = try reader.takeDelimiterExclusive('\n');
    var ranges_iterator = std.mem.tokenizeAny(u8, line, "-,");
    var sum: usize = 0;
    
    while(ranges_iterator.next()) |start| {
        const end = ranges_iterator.next() orelse {
            return ParsingError.InvalidRange; 
        };

        const start_num = try std.fmt.parseUnsigned(usize, start, 10);
        const end_num = try std.fmt.parseUnsigned(usize, end, 10);
        var i: usize = start_num;

//        std.debug.print("\n{s}-{s}: ", .{start, end});
        
        while(i <= end_num) : (i += 1) {
            if(isDoubleSequenceString(i)) {
                sum += i;
//                std.debug.print("{d} | ", .{i});
            }
        }
    }

    std.debug.print("Sum is: {d}\n", .{sum});
}

fn puzzle04(reader: *std.Io.Reader) !void{
    const line = try reader.takeDelimiterExclusive('\n');
    var ranges_iterator = std.mem.tokenizeAny(u8, line, "-,");
    var sum: usize = 0;
    
    while(ranges_iterator.next()) |start| {
        const end = ranges_iterator.next() orelse {
            return ParsingError.InvalidRange; 
        };

        const start_num = try std.fmt.parseUnsigned(usize, start, 10);
        const end_num = try std.fmt.parseUnsigned(usize, end, 10);
        var i: usize = start_num;

//       std.debug.print("\n{s}-{s}: ", .{start, end});
        
        while(i <= end_num) : (i += 1) {
            if(isRepeatedSequence(i)) {
                sum += i;
//                std.debug.print("{d} | ", .{i});
            }
        }
    }

    std.debug.print("Sum is: {d}\n", .{sum});
}

pub fn main() !void {    
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day02", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle03(reader);
    try data_reader.seekTo(0);
    try puzzle04(reader);
}

