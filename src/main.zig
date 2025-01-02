const std = @import("std");

fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var size: usize = 8;
    while (true) {
        return reader.readUntilDelimiterAlloc(allocator, '\n', size) catch |err| {
            if (err == error.StreamTooLong) {
                std.debug.print("Old memory: {any}\n", .{size});
                size *= 2;
                std.debug.print("New memory: {any}\n", .{size});
                if (size > std.math.maxInt(usize) / 2) {
                    return error.StreamTooLong;
                }
                continue;
            }
            return err;
        };
    }
}

fn loop(args: [][:0]const u8, status: i32) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("MEMORY LEAK");
    }

    const stdin = std.io.getStdIn().reader();

    while (true) {
        std.debug.print("-> ", .{});
        const line = try readLine(stdin, allocator);
        defer allocator.free(line);

        std.debug.print("line: {any}\n", .{line});
        std.debug.print("args: {s}\n", .{args});
        if (status == 0) break;
    }
}

pub fn main() !void {
    var args = [_][:0]const u8{ "hello", "world" };
    const status = 0;
    try loop(&args, status);
}
