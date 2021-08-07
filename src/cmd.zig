const std = @import("std");
const eql = std.mem.eql;
// const eql = std.meta.eql;
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
    add, help, version,

    pub fn exec(cmd: Cmd) void {
        switch (cmd) {
            Cmd.help => std.debug.print("\nGOT HELP CMD", .{}),
            Cmd.add => std.debug.print("\nGOT ADD CMD", .{}),
            Cmd.version => std.debug.print("GOT VERSION CMD", .{})
        }
    }
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
        // if (eql([]const u8, arg, "h") or eql([]const u8, arg, "help"))  
        //     return Cmd.help
        // else if (eql([]const u8, arg, "v") or eql([]const u8, arg, "version")) 
        //     return Cmd.version
        // else if (eql([]const u8, arg, "a") or eql([]const u8, arg, "add")) 
        //     return Cmd.add
        // else
        //     return Cmd.help;
    }
    return Cmd.help;
}

fn arena_alloc() !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    a = &arena.allocator;
    defer arena.deinit;
}
