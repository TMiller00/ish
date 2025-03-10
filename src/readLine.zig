const std = @import("std");

pub fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var buf_reader = std.io.bufferedReader(reader);
    var r = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    errdefer line.deinit();

    r.streamUntilDelimiter(line.writer(), '\n', null) catch |err| {
        // If we encounter EOF with no data, return EOF error
        // Otherwise, treat EOF as end of line and return what we have
        if (err == error.EndOfStream and line.items.len == 0) {
            return err;
        }
        // For any other error, propagate it
        if (err != error.EndOfStream) {
            return err;
        }
    };

    return line.toOwnedSlice();
}
