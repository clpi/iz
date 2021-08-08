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
    get, add, log, new
};


pub const Cmd = enum {
    add, help, version, new, log,

    pub fn exec(cmd: Cmd) void {
        switch (cmd) {
            Cmd.help => {
                std.debug.print("\nGOT HELP CMD\n", .{});
                help.print_help();
            },
            Cmd.add => {
                std.debug.print("\nGOT ADD CMD", .{});
            },
            Cmd.version => {
                std.debug.print("GOT VERSION CMD\n", .{});
                help.print_info();
            },
            Cmd.new => {
                std.debug.print("\nGOT CMD NEW", .{});
            },
            Cmd.log => {
                std.debug.print("\nGOT CMD Log", .{});
            },

        }
    }
};

pub fn match_cmd(gpa: *std.mem.Allocator) !Cmd {
    const args = try proc.argsAlloc(gpa);
    defer proc.argsFree(gpa, args);
    if (args.len == 1) { 
    }
    for (args) |arg, i| {
        if (i == 0) { continue; }
        std.debug.print("{}: {s}\n", .{i, arg});
        if (eql(u8, arg, "help") or eql(u8, arg, "h")) return Cmd.help
        else if (eql(u8, arg, "new") or eql(u8, arg, "n")) return Cmd.new
        else if (eql(u8, arg, "add") or eql(u8, arg, "a")) return Cmd.add
        else if (eql(u8, arg, "log") or eql(u8, arg, "l")) return Cmd.log
        else if (eql(u8, arg, "version") or eql(u8, arg, "v")) return Cmd.version
        else continue;
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
