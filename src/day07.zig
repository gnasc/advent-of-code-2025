const std = @import("std");

fn puzzle13(reader: *std.Io.Reader) !void {
    var timer = try std.time.Timer.start();
    var count: usize = 0;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var pos = std.AutoHashMap(usize, void).init(allocator);
    defer pos.deinit();

    while(true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;

        for(line, 0..) |c, i| {
            switch(c) {
                'S' => try pos.put(i, {}),
                '^' => {
                    if(pos.contains(i)) {
                        _ = pos.remove(i);
                        try pos.put(i - 1, {});
                        try pos.put(i + 1, {});
                        count += 1;
                    }
                },
                else => continue,
            }
        }
        reader.toss(1); 
    }

    const t = timer.read();
    std.debug.print("{d} - {any}\n\n", .{count, t / std.time.ns_per_ms});
}

const State = struct {
    size: usize,
    ray: usize,
};

fn countPaths(grid: []u8, ray: usize, len: usize, cache: *std.AutoHashMap(State, usize)) !usize {
    var count: usize = 0;
    var i: usize = 0;
    const s: State = .{ .size = grid.len, .ray = ray};

    if(cache.*.get(s)) |result| {
        return result;
    }

    while(i < len) : (i += 1) {
        switch(grid[i]) {
            '^' => {
                if(ray == i) {
                    var left: usize = undefined;
                    var right: usize = undefined; 

                    if(grid.len >= (len + 1) * 3) {
                        left = try countPaths(grid[(len+1)*2..], ray-1, len, cache);
                        right = try countPaths(grid[(len+1)*2..], ray+1, len, cache); 
                    } else {
                        left = 1;
                        right = 1;
                    }

                    count += left + right;
                }
            },
            '.' => {
                if(ray == i){
                    if(grid.len < (len + 1) * 3) {
                        count += 1;
                    } else {
                        count += try countPaths(grid[(len+1)*2..], ray, len, cache);
                    }
                }
            },
            else => continue,
        }
    }

    try cache.put(s, count); 

    return count;
}

fn puzzle14(reader: *std.Io.Reader, size: usize) !void {
    var timer = try std.time.Timer.start();

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    
    const grid = try reader.readAlloc(allocator, size);
    defer allocator.free(grid);

    var cache = std.AutoHashMap(State, usize).init(allocator);
    defer cache.deinit();

    var ray: usize = undefined;
    var len: usize = undefined; 

    for(grid, 0..) |c, i| {
        switch(c) {
            'S' => ray = i,
            '\n' => {
                len = i;
                break;
            },
            else => continue,
        }
    }

    const count: usize = try countPaths(grid[(len+1)*2..], ray, len, &cache);

    const t = timer.read();
    std.debug.print("{d} - {any}\n", .{count, t / std.time.ns_per_ms});
}

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day07", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);
    const data_size = try data_reader.getSize();

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle13(reader);
    try data_reader.seekTo(0);
    try puzzle14(reader, data_size);
}
