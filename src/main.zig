const std = @import("std");

fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var line = std.ArrayList(u8).init(allocator);
    errdefer line.deinit();

    while (true) {
        if (reader.readByte()) |result| {
            if (result == '\n') break;
            try line.append(result);
        } else |err| {
            if (err == error.EndOfStream) {
                if (line.items.len == 0) {
                    return err;
                }
                break;
            }
            return err;
        }
    }

    return line.toOwnedSlice();
}

fn splitLine(line: []u8, allocator: std.mem.Allocator) ![][]const u8 {
    var tokens = std.ArrayList([]const u8).init(allocator);
    errdefer tokens.deinit();

    var it = std.mem.tokenizeAny(u8, line, " ,\t,\r,\n");
    while (it.next()) |token| {
        try tokens.append(token);
    }

    return tokens.toOwnedSlice();
}

fn loop() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();

    const status = 1;

    while (true) {
        std.debug.print("-> ", .{});
        const line = try readLine(stdin, allocator);
        const args = try splitLine(line, allocator);

        std.debug.print("args: {any}\n", .{args});
        if (status == 0) break;
    }
}

pub fn main() !void {
    try loop();
}
