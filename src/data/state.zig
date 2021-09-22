const std = @import("std");
const assert = std.debug.assert;
const session = @import("../types/session.zig");
const user = @import("../types/user.zig");
const message = @import("../types/message.zig");

usingnamespace @import("../main.zig");

pub const StateMn = struct {

    allctr: *std.mem.Allocator,
    updated_ts: u64,
    created_ts: u64,
    users: user.User,
    sessions: session.Session,
    messages: message.Message,

    pub fn init(
        allctr: *std.mem.Allocator,
        users_max: usize,
        messages_max: usize,
    ) !StateMn {
        return StateMn {
            .allctr = allctr,
            .users = user.User.new(),
            .sessions = session.Session.new(),
            .messages = message.Message.init(0, 0, ""),
        };
    }

    pub const Op = enum(u8) {
        init, register, new_user, new_session, new_msg, list,

        pub fn toJson(self: Op, opts: std.json.StringifyOptions, writer: anytype) !void {
            try std.fmt.format(writer, "\"{}\"", .{ @tagName(self) });
        }
    };
};
