const std = @import("std");

const Dial = struct{
    position: u8 = 0,

    fn moveLeft(self: *Dial, amount: usize) void {
        const amount_u8: u8 = @as(u8, @intCast(amount % 100));
    
        self.position -%= amount_u8;
        self.position %= 156;
    }

    fn moveRight(self: *Dial, amount: usize) void {
        const amount_u8: u8 = @as(u8, @intCast(amount % 100));

        self.position +%= amount_u8;
        self.position %= 100;
    }
};

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day01", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);
    
    const reader: *std.Io.Reader = &data_reader.interface;

    var dial: Dial = Dial{ .position = 50 };
    var count: usize = 0;

    while(true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        const number: usize = try std.fmt.parseUnsigned(usize, line[1..], 10);

        switch(line[0]) {
            'L' => dial.moveLeft(number),
            'R' => dial.moveRight(number),
            else => unreachable,
        }
        
        if(dial.position == 0) count += 1;

//        std.debug.print("The dial is rotated {s} to point at {d}\n", .{line, dial.position});
        reader.toss(1);
    }

    std.debug.print("Password is: {d}\n", .{count});
}
