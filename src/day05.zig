const std = @import("std");
const Allocator = std.mem.Allocator;

fn validateFresh(fresh: [][2]usize, ingredients: []usize) usize {
    var count: usize = 0;

    for (ingredients) |i| {
        for (fresh) |f| {
            if (i >= f[0] and i <= f[1]) {
                count += 1;
                break;
            }
        }
    }

    return count;
}

fn isBetween(number: usize, start: usize, end: usize) bool {
    return number >= start and number <= end;
}

fn countFresh(fresh: *std.ArrayList([2]usize)) usize {
    var i: usize = 0;
    var count: usize = 0;
    var reset: bool = false;

    while(i < fresh.*.items.len) : (i += 1) {
        var j: usize = 0;

        // Reset "i" when we use swapRemove (replaces removed with last element)
        if(reset) i -= 1;
        reset = false;

        while(j < fresh.*.items.len) : (j += 1) {
            if(i == j) continue;

            const start = isBetween(fresh.*.items[j][0], fresh.*.items[i][0], fresh.*.items[i][1]);  
            const end = isBetween(fresh.*.items[j][1], fresh.*.items[i][0], fresh.*.items[i][1]);
            const contains = isBetween(fresh.*.items[i][0], fresh.*.items[j][0], fresh.*.items[j][1]) and 
                             isBetween(fresh.*.items[i][1], fresh.*.items[j][0], fresh.*.items[j][1]);

            const overlap = (start or end) or contains;

            if(start and !end) {
                fresh.*.items[i][1] = fresh.*.items[j][1];
            } else if(!start and end){
                fresh.*.items[i][0] = fresh.*.items[j][0];
            } else if(contains) {
                fresh.*.items[i][0] = fresh.*.items[j][0];
                fresh.*.items[i][1] = fresh.*.items[j][1];
            } 

            if(overlap) {
                _ = fresh.*.swapRemove(j);
                j -= 1;
                reset = true; // last element moved, need to reset iteration
            }
        }
    }

    for (fresh.*.items) |range| {
        count += (range[1] - range[0]) + 1;
    }

    return count;
}

fn puzzle09_10(reader: *std.Io.Reader) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var fresh_list = try std.ArrayList([2]usize).initCapacity(allocator, 4);
    var ingredient_list = try std.ArrayList(usize).initCapacity(allocator, 4);

    defer fresh_list.deinit(allocator);
    defer ingredient_list.deinit(allocator);

    var parse_flag: bool = true;

    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        if (line.len == 0) {
            parse_flag = !parse_flag;
            reader.toss(1);
            continue;
        }

        if (parse_flag) {
            const index = std.mem.indexOfScalar(u8, line, '-').?;
            const start = try std.fmt.parseUnsigned(usize, line[0..index], 10);
            const end = try std.fmt.parseUnsigned(usize, line[(index + 1)..], 10);

            try fresh_list.append(allocator, .{ start, end });
        } else {
            const id = try std.fmt.parseUnsigned(usize, line, 10);
            try ingredient_list.append(allocator, id);
        }

        reader.toss(1);
    }

    const valid = validateFresh(fresh_list.items, ingredient_list.items);
    std.debug.print("Valid Fresh count: {d}\n", .{valid});

    const count = countFresh(&fresh_list);
    std.debug.print("Total Fresh count: {d}\n", .{count});
}

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day05", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle09_10(reader);
}
