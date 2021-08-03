const std = @import("std");
const fs = std.fs;

pub const User = struct {
    name: []u8,
    email: []u8,
    display: []u8,

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
        return types.User {
            .name = "Chris",
            .email = "chris@devisa.io",
            .display = "clp"
        };
    }
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


