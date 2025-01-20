const std = @import("std");
const builtins = @import("builtins.zig");
const launch = @import("launch.zig").launch;
const splitLine = @import("splitLine.zig").splitLine;

fn execute(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
    if (args.len == 0) {
        return 1;
    }

    for (builtins.builtin_str, 0..) |builtin, index| {
        if (std.mem.eql(u8, builtin, args[0])) {
            return builtins.builtin_fn[index](args);
        }
    }

    return launch(args, allocator);
}

fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var line = std.ArrayList(u8).init(allocator);
    errdefer line.deinit();

    var buf_reader = std.io.bufferedReader(reader);
    var r = buf_reader.reader();

    while (true) {
        if (r.readByte()) |result| {
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
