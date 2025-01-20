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

fn exit(_: [][]const u8) u8 {
    return 0;
}

pub const builtin_str = [2][]const u8{ "cd", "exit" };
pub const builtin_fn = [2]CommandFn{ cd, exit };
