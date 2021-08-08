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
    add, help, version, new, log, run, list, find, remove, shell,

    pub fn fromStr(arg: []const u8) ?Cmd {
        std.debug.warn("Trying to parse {s}", .{arg});
        if (eql(u8, arg, "help") or eql(u8, arg, "h")) return Cmd.help
        else if (eql(u8, arg, "new") or eql(u8, arg, "n")) return Cmd.new
        else if (eql(u8, arg, "add") or eql(u8, arg, "a")) return Cmd.add
        else if (eql(u8, arg, "log") or eql(u8, arg, "l")) return Cmd.log
        else if (eql(u8, arg, "run") or eql(u8, arg, "r")) return Cmd.run
        else if (eql(u8, arg, "list") or eql(u8, arg, "ls")) return Cmd.list
        else if (eql(u8, arg, "remove") or eql(u8, arg, "rm")) return Cmd.remove
        else if (eql(u8, arg, "version") or eql(u8, arg, "v")) return Cmd.version
        else if (eql(u8, arg, "find") or eql(u8, arg, "f")) return Cmd.version
        else if (eql(u8, arg, "shell") or eql(u8, arg, "sh")) return Cmd.version
        else return null;
    }

    pub fn toStr(cmd: Cmd) tuple([]const u8, []const u8) {
        switch (cmd) {
            .help => return .{"h", "help"},
            .version => return .{"v", "version"},
            .run => return .{"r", "run"},
            .list => return .{"ls", "list"},
            .find => return .{"f", "find"},
            .shell => return .{"sh", "shell"},
            .new => return .{"n", "new"},
            .init => return .{"i", "init"},
            .add => return .{"a", "add"},
            .log => return .{"l", "log"},
            .remove => return .{"rm", "remove"}
        }
        return .{"h", "help"};
    }

    pub fn matches(arg: []const u8, short: []const u8, long: []const u8) void {

    }

    pub fn exec(cmd: Cmd) void {
        switch (cmd) {
            Cmd.help => {
                std.debug.print("\nGOT HELP CMD\n", .{});
                help.print_help(null);
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
            Cmd.run => {
                std.debug.print("\nGOT CMD RUN", .{});
            },
            Cmd.log => {
                std.debug.print("\nGOT CMD Log", .{});
            },
            Cmd.list => {
                std.debug.print("\nGOT List cmd", .{});
            },
            Cmd.find => {
                std.debug.print("\nGOT find cmd", .{});
            },
            Cmd.shell => {
                std.debug.print("\nGOT shell cmd", .{});
            },
            Cmd.remove => {
                std.debug.print("\nGOT rm cmd", .{});
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
        switch (i) {
            0 => continue,
            1 => {
                if (Cmd.fromStr(arg)) |command| return command
                else  continue; 
            },
            else => {
                std.debug.warn("Command can't be given in position 2", .{});
            }
        }
        std.debug.print("{}: {s}\n", .{i, arg});
    }
    return Cmd.help;
}

fn arena_alloc() !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    a = &arena.allocator;
    defer arena.deinit;
}
