const std = @import("std");

const session = @import("../types/session.zig");
const user = @import("../types/user.zig");
const message = @import("../types/message.zig");

usingnamespace @import("../main.zig");

pub const Op = enum(u8) {
    init, 
    register, 
    user_new, 
    session_new, 
    message_new, 
    message_list,

    pub fn toJson(self: Op, opts: std.json.StringifyOptions, writer: anytype) !void {
        try std.fmt.format(writer, "\"{}\"", .{ @tagName(self) });
    }
};

pub fn Event(comptime op: Op) type {
    return switch (op) {
        .user_new => user.User,
        .message_new => message.Message,
        .session_new => session.Session,
        .message_list => u128,
        else => unreachable,
    };
}

