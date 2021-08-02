const std = @import("std");
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
        print_help();
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

fn print_help() void {
    const print = std.debug.print;
    print("USAGE\n", .{});
    print("izle\tversion 0.1.0-alpha.0\n\n", .{});
    print("COMMANDS\n", .{});
    print("\th  help\t\tPrint this help message\n", .{});
    print("\ti  init\t\tInitialize a new workspace\n", .{});
    print("\tr  run\t\tRun an automation\n", .{});
    print("\tl  list\t\tList all automations\n", .{});
    print("\n", .{});
    print("FlAGS\n", .{});
    print("\t-d  --debug\t\tPring extra debug messages\n", .{});
    print("\t-h  --help\t\tPrint this help message\n", .{});
}
