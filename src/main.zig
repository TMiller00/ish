const std = @import("std");

const CommandFn = *const fn (args: [][]const u8) u8;

fn cd(args: [][]const u8) u8 {
    if (args.len == 1) {
        std.debug.print("ish: expected argument to \"cd\"\n", .{});
        return 1;
    }

    if (args.len > 2) {
        std.debug.print("cd: too many arguments\n", .{});
        return 1;
    }

    _ = std.posix.chdir(args[1]) catch {
        std.debug.print("cd: no such file or directory {s}\n", .{args[1]});
    };

    return 1;
}

const builtin_str = [1][]const u8{"cd"};
const builtin_fn = [1]CommandFn{cd};

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

fn execute(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
    if (args.len == 0) {
        return 1;
    }

    for (builtin_str) |builtin| {
        if (std.mem.eql(u8, builtin, args[0])) {
            return builtin_fn[0](args);
        }
    }

    return launch(args, allocator);
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

    var status: c_int = 1;

    while (true) {
        std.debug.print("$ ", .{});
        const line = try readLine(stdin, allocator);
        const args = try splitLine(line, allocator);
        status = try execute(args, allocator);
        if (status == 0) break;
    }
}

pub fn main() !void {
    try loop();
}
