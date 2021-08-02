const std = @import("std");
const types = @import("./types.zig");

pub const Config = struct {
    user: User,
    api_key: []const u8,
    debug: bool,

    pub fn init() !Config {
        return Config{ 
            .user = User{ .display= "d", .email= "e", .name= "n"},
            .debug = false,
            .api_key = ""
        };
    }
};
