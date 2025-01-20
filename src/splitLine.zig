const std = @import("std");

pub fn splitLine(line: []u8, allocator: std.mem.Allocator) ![][]const u8 {
    var tokens = std.ArrayList([]const u8).init(allocator);
    errdefer tokens.deinit();

    var it = std.mem.tokenizeAny(u8, line, " \t\r\n");
    while (it.next()) |token| {
        try tokens.append(token);
    }

    return tokens.toOwnedSlice();
}
