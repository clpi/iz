const std = @import("std");

pub const Session = packed struct {
    id: u128 = std.crypto.random.int(u128),
    created_ts: u64 = 0,
    updated_ts: u64 = 0,

    pub fn new() !Session {
        return Session {
            .id = std.crypto.random.int(u128),
        };
    }

    pub fn toString(self: Session) ![]const u8 {
        var buf: [100]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        var str = std.ArrayList(u8).init(&fba.allocator);
        try std.json.stringify(self, .{}, str.writer());
        return str.items;
    }

    pub fn toJson(self: Session, opts: std.json.StringifyOptions, writer: anytype) !void {
        try writer.writeAll("{");
        try std.fmt.format(writer, "\"id\":{},", .{ self.id });
        try std.fmt.format(writer, "\"created_ts\":{},", .{ self.created_ts });
        try writer.writeAll("}");
    }
};
