const std = @import("std");
const chain = @import("./data/chain.zig");
const tree = @import("./data/tree.zig");
const state = @import("./data/state.zig");

const cmd = @import("./cmd.zig");
const config = @import("./config.zig");
const err = @import("./error.zig");
const ansi = @import("./terminal/ansi.zig");
const http = @import("./http.zig");
const sim = @import("./sim.zig");

const alloc = std.testing.allocator_instance;
const test_alloc = std.testing.allocator;
const proc = std.process;
const wasm = std.wasm;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

pub fn main() anyerror!void {
    const log = std.log.scoped(.main);
    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var gpa= &gp_alloc.allocator;
    const sub_cmd = try cmd.match_cmd(gpa);
    log.info("Got command {}", .{sub_cmd});
    var conf = config.Config.init();
    sub_cmd.exec();
    var ch = chain.Chain(usize).init(std.testing.allocator);
    try ch.push(3);
}

test "main" {
    try main();
}
