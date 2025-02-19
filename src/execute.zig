const std = @import("std");
const builtins = @import("builtins.zig");

fn launch(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
    var child = std.process.Child.init(args, allocator);

    // Debug prints to help us see what's being passed to grep
    std.debug.print("Launching command: {s} with {} arguments\n", .{ args[0], args.len });
    for (args, 0..) |arg, i| {
        std.debug.print("arg[{}] = {s}\n", .{ i, arg });
    }

    child.spawn() catch |err| {
        switch (err) {
            error.FileNotFound => {
                std.debug.print("ish: command not found: {s}\n", .{args[0]});
            },
            else => {
                std.debug.print("ish: error spawning process: {}\n", .{err});
            },
        }

        return 1;
    };

    const result = try child.wait();

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

pub fn execute(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
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
