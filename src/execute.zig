const std = @import("std");
const builtins = @import("builtins.zig");
const launch = @import("launch.zig").launch;

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
