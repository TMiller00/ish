const std = @import("std");
const execute = @import("execute.zig").execute;
const readLine = @import("readLine.zig").readLine;
const splitLine = @import("splitLine.zig").splitLine;

fn getCurrentGitBranch(allocator: std.mem.Allocator) !?[]const u8 {
    var cwd = std.fs.cwd();

    cwd.access(".git", .{}) catch |err| {
        if (err == error.FileNotFound) return null;
        return err;
    };

    const head_contents = cwd.readFileAlloc(allocator, ".git/HEAD", 1024) catch |err| {
        if (err == error.FileNotFound) return null;
        return err;
    };
    defer allocator.free(head_contents);

    if (std.mem.indexOf(u8, head_contents, "ref: refs/heads/")) |index| {
        const branch_name = std.mem.trim(u8, head_contents[index + "ref: refs/heads/".len ..], "\n\r");
        return try allocator.dupe(u8, branch_name);
    }

    if (head_contents.len >= 7) {
        return try allocator.dupe(u8, head_contents[0..7]);
    }

    return null;
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const cwd = try std.fs.cwd().realpath(".", &buf);
    const dirname = std.fs.path.basename(cwd);

    const maybe_branch = try getCurrentGitBranch(allocator);
    defer if (maybe_branch) |branch| allocator.free(branch);

    if (maybe_branch) |branch| {
        return try std.fmt.allocPrint(allocator, "-> {s} git:({s}) ", .{ dirname, branch });
    }

    return try std.fmt.allocPrint(allocator, "-> {s} ", .{dirname});
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
