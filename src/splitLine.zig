const std = @import("std");

fn cleanToken(token: []const u8) []const u8 {
    // If token starts and ends with quotes, strip them
    if (token.len >= 2 and token[0] == '"' and token[token.len - 1] == '"') {
        return token[1 .. token.len - 1];
    }
    return token;
}

pub fn splitLine(line: []u8, allocator: std.mem.Allocator) ![][]const u8 {
    var tokens = std.ArrayList([]const u8).init(allocator);
    errdefer tokens.deinit();

    var it = std.mem.tokenizeAny(u8, line, " \t\r\n");
    while (it.next()) |token| {
        try tokens.append(cleanToken(token));
    }

    return tokens.toOwnedSlice();
}
