const std = @import("std");

fn launch(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
    var child = std.process.Child.init(args, allocator);
    try child.spawn();

    const result = child.wait() catch {
        std.debug.print("ish: command not found: {s}\n", .{args[0]});
        return 1;
    };

    switch (result) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.print("Process exited with code {}\n", .{code});
            }
        },
        .Signal => |signal| {
            std.debug.print("Process terminated with signal {}\n", .{signal});
        },
        .Stopped => |code| {
            std.debug.print("Process stopped with signal {}\n", .{code});
        },
        .Unknown => |code| {
            std.debug.print("Process terminated with unknown {}\n", .{code});
        },
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
        std.debug.print("$ ", .{});
        const line = try readLine(stdin, allocator);
        const args = try splitLine(line, allocator);
        _ = try launch(args, allocator);
        if (status == 0) break;
    }
}

pub fn main() !void {
    try loop();
}
