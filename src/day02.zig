const std = @import("std");

const ParsingError = error{ InvalidRange };

fn isDoubleSequence(number: usize) bool {
    const f32_number: f32 = @as(f32, @floatFromInt(number));
    const f32_digit_count: f32 = @floor(@log10(f32_number)) + 1;
    const digit_count: usize = @as(usize, @intFromFloat(f32_digit_count));

    if(digit_count % 2 != 0) return false;

    const base = std.math.pow(usize, 10, (digit_count / 2));
    const first_half = number / base;
    const second_half = number % base;

    return first_half == second_half;
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

        //std.debug.print("\n{s}-{s}: ", .{start, end});
        
        while(i <= end_num) : (i += 1) {
            if(isDoubleSequence(i)) {
                sum += i;
                //std.debug.print("{d} | ", .{i});
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
}

