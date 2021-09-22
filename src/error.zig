const std = @import("std");

pub const GenericResult = packed enum(u32) {
    ok, invalid, exists
};

pub const Error = enum(u8) {
    cancelled,
};

pub fn fatal(comptime fmt_str: []const u8, args: anytype) noreturn {
    std.io.getStdErr().writer().print("Error: " ++ fmt_str ++ "\n", args) catch {};
    std.os.exit(1);
}
