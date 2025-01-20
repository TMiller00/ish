const std = @import("std");

pub fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var buf_reader = std.io.bufferedReader(reader);
    var r = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    errdefer line.deinit();

    try r.streamUntilDelimiter(line.writer(), '\n', null);

    return line.toOwnedSlice();
}
