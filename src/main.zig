const std = @import("std");
const execute = @import("execute.zig").execute;
const readLine = @import("readLine.zig").readLine;
const splitLine = @import("splitLine.zig").splitLine;

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
