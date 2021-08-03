const std = @import("std");

pub fn token(input: []const u8) !void {
    var it = std.input.tokenize(input, " ");
    while (it.next()) |item| {
        std.debug.print("{s}\n", .{item}) ;
    }
}
