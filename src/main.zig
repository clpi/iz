const std = @import("std");
const test_alloc = std.testing.allocator;
const types = @import("./types.zig");
const cmd = @import("./cmd.zig");

const alloc = std.testing.allocator_instance;
const proc = std.process;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

pub fn main() anyerror!void {
    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa= &gp_alloc.allocator;
    const sub_cmd = try cmd.match_cmd(gpa);

}
