const std = @import("std");
const fs = std.fs;

pub const User = struct {
    id: u128,
    name: []const u8,
    email: []const u8,
    display: []const u8,
    created_ts: u64 = 0,
    updated_ts: u64 = 0,

    pub fn toString(self: User) ![]const u8 {
        var buf: [100]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        var str = std.ArrayList(u8).init(&fba.allocator);
        try std.json.stringify(self, .{}, str.writer());
        return str.items;
    }

    pub fn log(self: User) !void {
        std.log.info("{s}", .{self.toString()});
    }

    pub fn new() !User {
        return User {
            .id = std.crypto.random.int(u128),
            .name = "Chris",
            .email = "chris@devisa.io",
            .display = "clp"
        };
    }

    pub fn toJson(self: User, opts: std.json.StringifyOptions, writer: anytype) !void {
        try writer.writeAll("{");
        try std.fmt.format(writer, "\"id\":{},", .{ self.id });
        try std.fmt.format(writer, "\"created_ts\":{},", .{ self.created_ts });
        try writer.writeAll("}");
    }
};

pub const Account = struct {
    name: []const u8,
};

fn log_file() !void {
    const msg = "Hello there!";
    const file = try fs.cwd()
        .createFile("log.idle", .{ .read = true });
    defer file.close();
    try file.writeAll(msg);
    try file.seekTo(0);
    const cont = try file.reader().readAllAlloc(alloc, msg.len);
    defer alloc.free(cont);
    while(true) {
        std.time.sleep(1 * std.time.ns_per_s);
        tick += @as(isize, step);
    }
}


