const std = @import("std");
const Allocator = std.mem.Allocator;

const Operator = enum { Add, Mul };

fn calc(height: usize, width: usize, numbers: []usize, operators: []Operator) usize {
    var sum: usize = 0;
    var result: usize = 0;

    for (0..width) |c| {
        const op: Operator = operators[c];
        result = @intFromEnum(op);

        for (0..height) |r| {
            switch (op) {
                .Add => result += numbers[r * width + c],
                .Mul => result *= numbers[r * width + c],
            }
        }

        sum += result;
    }

    return sum;
}

fn puzzle11(reader: *std.Io.Reader, size: usize) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const table_str: []u8 = try reader.readAlloc(allocator, size);
    defer allocator.free(table_str);

    var timer = try std.time.Timer.start();

    var height: usize = 0;
    var width: usize = 0;

    for (table_str) |c| {
        if (c == '\n') height += 1;
        if (c == '+' or c == '*') width += 1;
    }

    const table = try allocator.alloc(usize, width * (height - 1));
    const op = try allocator.alloc(Operator, width);

    defer allocator.free(table);
    defer allocator.free(op);

    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    var start: usize = 0;
    var end: usize = 0;

    while (i < table_str.len) : (i += 1) {
        switch (table_str[i]) {
            '+', '*' => {
                op[k] = if (table_str[i] == '+') .Add else .Mul;
                k += 1;
            },
            ' ', '\n' => {
                if (start == end) continue;
                const num = try std.fmt.parseUnsigned(usize, table_str[start..end], 10);
                table[j] = num;

                start = end;
                j += 1;
            },
            else => {
                if (start == end) start = i;
                end = i + 1;
            },
        }
    }

    const t = timer.read();
    const sum = calc(height - 1, width, table, op);
    std.debug.print("Sum: {d} time: {any}\n", .{ sum, t });
}

fn puzzle12(reader: *std.Io.Reader, size: usize) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const table_str: []u8 = try reader.readAlloc(allocator, size);
    defer allocator.free(table_str);

    var timer = try std.time.Timer.start();

    var newline = try std.ArrayList(usize).initCapacity(allocator, 4);
    var operators = try std.ArrayList(Operator).initCapacity(allocator, 200);

    defer newline.deinit(allocator);
    defer operators.deinit(allocator);

    for (table_str, 0..) |c, i| {
        switch (c) {
            '\n' => try newline.append(allocator, i),
            '+', '*' => try operators.append(allocator, if (c == '+') .Add else .Mul),
            else => continue,
        }
    }

    operators.shrinkAndFree(allocator, operators.items.len);

    var r: usize = newline.items.len;
    var c: usize = 0;
    var o: usize = 0;

    var sum: usize = 0;
    var result: ?usize = null;

    while (c <= newline.items[0]) : (c += 1){
        const op: Operator = operators.items[o];
        var num: usize = 0;
        var digit_count: usize = 0;
        if(result == null) result = @intFromEnum(op);

        while (r > 0) : (r -= 1) {
            const index = (r - 1) * (newline.items[0] + 1) + c;
            const digit = std.fmt.charToDigit(table_str[index], 10) catch continue;

            num += digit * std.math.pow(usize, 10, digit_count);
            digit_count += 1;
        }

        if(num != 0) {
            switch(op) {
                .Add => result.? += num,
                .Mul => result.? *= num,
            }
        } else {
            sum += result.?;
            result = null;
            o += 1;
        }
        
        digit_count = 0;
        r = newline.items.len - 1;
    }


    const t = timer.read();
    std.debug.print("Sum: {d} time: {any}\n", .{ sum, t });
}

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day06", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);
    const data_size = try data_reader.getSize();

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle11(reader, data_size);
    try data_reader.seekTo(0);
    try puzzle12(reader, data_size);
}
