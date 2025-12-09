const std = @import("std");
const Allocator =  std.mem.Allocator;

fn solveGrid(allocator: Allocator, grid: []u8, width: usize, height: usize) !struct{ usize, []usize } {
    var count: usize = 0;
    var positions = try std.ArrayList(usize).initCapacity(allocator, height);
    errdefer positions.deinit(allocator);

    const adjacent: [8][2]isize = .{ 
        .{-1, -1}, .{-1, 0}, .{-1, 1}, //top
        .{0, -1},            .{0, 1},  //middle
        .{1, -1},  .{1, 0},  .{1, 1},  //bottom
    };

    for(grid, 0..) |roll, i| {
        if(roll == '@') {
            var sum: usize = 0;
            const row: isize = @as(isize, @intCast(i / (width + 1)));
            const col: isize = @as(isize, @intCast(i % (width + 1)));

            for(adjacent) |a| {  
                if(row + a[0] < 0 or row + a[0] >= height) continue;
                if(col + a[1] < 0 or col + a[1] >= width) continue;

                const r = @as(usize, @intCast(row + a[0]));
                const c = @as(usize, @intCast(col + a[1]));
                
                if(grid[r * (width + 1) + c] == '@') sum += 1;
                if(sum > 3) break;
            }
             
            if(sum <= 3) {
                count += 1;
                try positions.append(allocator, i);
            }
        }
    }

    return .{ count, try positions.toOwnedSlice(allocator) };
}

fn removeRolls(grid: []u8, positions: []usize) void {
    for(positions) |pos| {
        grid[pos] = '.';
    }
}

fn puzzle07(reader: *std.Io.Reader, size: usize) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer if(gpa.deinit() == .leak) @panic("Leak detected!");

    const allocator = gpa.allocator();
    const grid: []u8 = try reader.readAlloc(allocator, size);
    defer allocator.free(grid);

    const width: usize = std.mem.indexOfScalar(u8, grid, '\n').?;
    const last: usize =  std.mem.lastIndexOfScalar(u8, grid, '\n').?;
    const height: usize = (last + 1) / (width + 1);

    const result = try solveGrid(allocator, grid, width, height);
    defer allocator.free(result[1]);   

    std.debug.print("PaperRoll count: {any}\n", .{result[0]});
}

fn puzzle08(reader: *std.Io.Reader, size: usize) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer if(gpa.deinit() == .leak) @panic("Leak detected!");

    const allocator = gpa.allocator();
    const grid: []u8 = try reader.readAlloc(allocator, size);
    defer allocator.free(grid);

    const width: usize = std.mem.indexOfScalar(u8, grid, '\n').?;
    const last: usize =  std.mem.lastIndexOfScalar(u8, grid, '\n').?;
    const height: usize = (last + 1) / (width + 1);

    var removed_sum: usize = 0;

    while(true) {
        const result = try solveGrid(allocator, grid, width, height);
        defer allocator.free(result[1]);  
        
        removeRolls(grid, result[1]);
        if(removed_sum + result[0] == removed_sum) break;
        removed_sum += result[0];
    }
    
    std.debug.print("PaperRoll count: {any}\n", .{removed_sum});
}

pub fn main() !void {
    var path_buffer: [4096]u8 = undefined;
    const path = try std.fs.realpath("../data/day04", &path_buffer);

    var reader_buffer: [4096]u8 = undefined;
    var data_file = try std.fs.openFileAbsolute(path, .{});
    var data_reader = data_file.reader(&reader_buffer);
    const data_size = try data_reader.getSize();

    const reader: *std.Io.Reader = &data_reader.interface;
    try puzzle07(reader, data_size);
    try data_reader.seekTo(0);
    try puzzle08(reader, data_size);
}
