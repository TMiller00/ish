const std = @import("std");

fn launch(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
    const pid = std.c.fork();

    if (pid == 0) {
        const err = std.process.execv(allocator, args);
        std.debug.print("shell: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    } else if (pid < 0) {
        std.debug.print("Error forking the process: {any}\n", .{pid});
    } else {
        var status: c_int = undefined;
        _ = std.c.waitpid(pid, &status, 0);
    }

    return 1;
}

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
        _ = try launch(args, allocator);
        if (status == 0) break;
    }
}

pub fn main() !void {
    try loop();
}
