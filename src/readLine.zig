const std = @import("std");

pub fn readLine(reader: std.fs.File.Reader, allocator: std.mem.Allocator) ![]u8 {
    var line = std.ArrayList(u8).init(allocator);
    errdefer line.deinit();

    var buf_reader = std.io.bufferedReader(reader);
    var r = buf_reader.reader();

    while (true) {
        if (r.readByte()) |result| {
            if (result == '\n') break;
            try line.append(result);
        } else |err| {
            if (err == error.EndOfStream) {
                if (line.items.len == 0) {
                    return err;
                }
                break;
            }
            return err;
        }
    }

    return line.toOwnedSlice();
}
