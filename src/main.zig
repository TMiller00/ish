const std = @import("std");
const execute = @import("execute.zig").execute;
const readLine = @import("readLine.zig").readLine;
const splitLine = @import("splitLine.zig").splitLine;

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const cwd = try std.fs.cwd().realpath(".", &buf);

    const dirname = std.fs.path.basename(cwd);

    const result = try std.fmt.allocPrint(allocator, "-> {s} ", .{dirname});
    return result;
}

fn loop() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn().reader();

    var status: c_int = 1;

    while (true) {
        // Write prompt
        const prompt = try getPrompt(allocator);
        try std.io.getStdOut().writer().writeAll(prompt);

        const line = try readLine(stdin, allocator);
        const args = try splitLine(line, allocator);
        status = try execute(args, allocator);
        if (status == 0) break;
    }
}

pub fn main() !void {
    try loop();
}
