const std = @import("std");

pub const Pool = struct {

};

pub const Message = struct {
    id: u128 = std.crypto.random.int(u128),
    user_from_id: u128,
    user_to_id: u128,
    buf: []u8,
    created_ts: u64 = 0,

    pub fn init(from: u128, to: u128, buf: []u8) !Message {
        return Message {
            .user_from_id = from,
            .user_to_id = to,
            .buf = buf,
        };
    }

    pub fn toString(self: Message) ![]const u8 {
        var buf: [100]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        var str = std.ArrayList(u8).init(&fba.allocator);
        try std.json.stringify(self, .{}, str.writer());
        return str.items;
    }

    pub fn toJson(self: Message, opts: std.json.StringifyOptions, writer: anytype) !void {
        try writer.writeAll("{");
        try std.fmt.format(writer, "\"id\":{},", .{ self.id });
        try std.fmt.format(writer, "\"created_ts\":{},", .{ self.created_ts });
        try writer.writeAll("}");
    }
};
