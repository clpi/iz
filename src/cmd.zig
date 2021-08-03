const std = @import("std");
const help = @import("cmd/help.zig");
const proc = std.process;
const fs = std.fs;
const wasi = std.fs.wasi;
const wasm = std.wasm;

var a: *std.mem.Allocator = undefined;

pub const Ops = enum {
    get, add, log
};


pub const Cmd = enum {
    new
};

pub fn match_cmd(gpa: *std.mem.Allocator) !Cmd {
    const args = try proc.argsAlloc(gpa);
    defer proc.argsFree(gpa, args);
    if (args.len == 1) { 
        help.print_help();
    }
    for (args) |arg, i| {
        if (i == 0) { continue; }
        std.debug.print("{}: {s}\n", .{i, arg});
    }
    return Cmd.new;

}

fn arena_alloc() !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    a = &arena.allocator;
    defer arena.deinit;
}
