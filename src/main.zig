const std = @import("std");
const wasm = std.wasm;
const chain = @import("data/chain.zig");
const tree = @import("data/tree.zig");
const test_alloc = std.testing.allocator;
const types = @import("data/types.zig");
const cmd = @import("cmd.zig");
const config = @import("config.zig");
const ansi = @import("terminal/ansi.zig");

const alloc = std.testing.allocator_instance;
const proc = std.process;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

pub fn main() anyerror!void {
    var gp_alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa= &gp_alloc.allocator;
    const sub_cmd = try cmd.match_cmd(gpa);
    var conf = config.Config.init();
    sub_cmd.exec();
    var ch = chain.Chain(usize).init(std.testing.allocator);
    try ch.push(3);
}

test "main" {
    try main();
}
