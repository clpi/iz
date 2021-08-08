const std = @import("std");
const fs = std.fs;
const types = @import("./data/types.zig");
const User = types.User;

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

    pub fn defaultPath() []const u8 {
        return std.process.getCwd();
    }
};
