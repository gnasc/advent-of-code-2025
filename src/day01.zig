const std = @import("std");

const Dial = struct {
    position: u8 = 0,
    count: usize = 0,

    fn moveLeft(self: *Dial, amount: usize) void {
        var cycles = amount / 100;
        const amount_u8: u8 = @as(u8, @intCast(amount % 100));

        if(self.position != 0 and self.position <= amount_u8) cycles += 1;
        self.position -%= amount_u8;

        self.position %= 156;
        self.count += cycles;
    }

    fn moveRight(self: *Dial, amount: usize) void {
        var cycles = @as(u8, @intCast(amount / 100));
        const amount_u8: u8 = @as(u8, @intCast(amount % 100));

        self.position +%= amount_u8;
        if(self.position % 100 != self.position) cycles += 1;

        self.position %= 100;
        self.count += cycles;
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

    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        const number: usize = try std.fmt.parseUnsigned(usize, line[1..], 10);

        switch (line[0]) {
            'L' => dial.moveLeft(number),
            'R' => dial.moveRight(number),
            else => unreachable,
        }

        //std.debug.print("Move: {s} Position: {d} Count: {d}\n", .{line, dial.position, dial.count});

        reader.toss(1);
    }

    std.debug.print("Password is: {d}\n", .{dial.count});
}
