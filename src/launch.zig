const std = @import("std");

pub fn launch(args: [][]const u8, allocator: std.mem.Allocator) !c_int {
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
