const std = @import("std");
const eql = std.mem.eql;
const Color = @import("terminal/ansi.zig").Color;
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

pub const CmdInfo = struct {
    short: []const u8,
    long: []const u8,
    opts: []OptInfo,
    desc: []const u8,

    pub fn init(short: []const u8, long: []const u8, desc: []const u8) CmdInfo {
        return CmdInfo {
            .short = short,
            .long = long,
            .desc = desc,
            .opts = &[_]OptInfo {},
        };
    }

    pub fn create(short: []const u8, long: []const u8, desc: []const u8, opts: []OptInfo) CmdInfo {
        return CmdInfo {
            .short = short,
            .long = long,
            .desc = desc,
            .opts = opts
        };
    }

    pub fn printHelp(cmd_info: CmdInfo) void {
        var sh = cmd_info.short;
        const short = comptime Color.bold(comptime Color.green.fg(sh));
        const long = comptime Color.green.fg(cmd_info.long);
        if (short.len == 1) print("    {s}   or {s}  \t     {s}\n", .{short, long, cmd_info.desc})
        else if (short.len == 2) print("    {s}  or {s} \t     {s}\n", .{short, long, cmd_info.desc})
        else print("    {s}  {s}\t\t{s}\n", .{short, long, cmd_info.desc});
    }
};

pub const OptInfo = struct {
    short: []const u8,
    long: []const u8,
    desc: []const u8,
    takes_value: bool,
    value_hint: ?[]const u8,

    pub fn init(short: []const u8, long: []const u8, desc: []const u8, takes_val: bool, hint: ?[]const u8) OptInfo {
        return CmdInfo {
            .short = short,
            .long = long,
            .desc = desc,
            .takes_value = takes_val,
            .value_hint = hint
        };
    }
};

pub const Cmd = enum {
    add, help,  new, log, run, list, find, remove, shell, init,

    pub fn fromStr(arg: []const u8) ?Cmd {
        std.debug.warn("Trying to parse {s}", .{arg});
        if (eql(u8, arg, "help") or eql(u8, arg, "h")) return Cmd.help
        else if (eql(u8, arg, "init") or eql(u8, arg, "i")) return Cmd.init
        else if (eql(u8, arg, "new") or eql(u8, arg, "n")) return Cmd.new
        else if (eql(u8, arg, "add") or eql(u8, arg, "a")) return Cmd.add
        else if (eql(u8, arg, "log") or eql(u8, arg, "l")) return Cmd.log
        else if (eql(u8, arg, "run") or eql(u8, arg, "r")) return Cmd.run
        else if (eql(u8, arg, "list") or eql(u8, arg, "ls")) return Cmd.list
        else if (eql(u8, arg, "remove") or eql(u8, arg, "rm")) return Cmd.remove
        else if (eql(u8, arg, "find") or eql(u8, arg, "f")) return Cmd.find
        else if (eql(u8, arg, "shell") or eql(u8, arg, "sh")) return Cmd.shell
        else return null;
    }

    pub fn info(cmd: Cmd) CmdInfo {
        switch (cmd) {
            .help => return CmdInfo.init("h", "help", "Print help for the CLI or for a command"),
            .run => return CmdInfo.init("r", "run", "Run an automation in the current workspace"),
            .list => return CmdInfo.init("ls", "list", "List resources in the current workspace"),
            .find => return CmdInfo.init("f", "find", "Find resources in or across workspaces"),
            .shell => return CmdInfo.init("sh", "shell", "Start a shell environment in this workspace"),
            .new => return CmdInfo.init("n", "new", "Create a new resource or workspace"),
            .init => return CmdInfo.init("i", "init", "Initialize/bootstrap the current directory"),
            .add => return CmdInfo.init("a", "add", "Add or import a new resource into the workspace"),
            .log => return CmdInfo.init("l", "log", "Create a new entry in this workspace's log"),
            .remove => return CmdInfo.init("rm", "remove", "Remove a resource in the workspace")
        }
        return CmdInfo.init("h", "help", "Print the help for base subcommands or a provided command");
    }

    pub fn matches(arg: []const u8, short: []const u8, long: []const u8) void {

    }

    pub fn exec(cmd: Cmd) void {
        switch (cmd) {
            Cmd.help => {
                std.debug.print("\nGOT HELP CMD\n", .{});
                help.print_help(null);
            },
            Cmd.init => {
                std.debug.print("\nGOT init CMD\n", .{});
                help.print_help(Cmd.init);
            },
            Cmd.add => {
                std.debug.print("\nGOT ADD CMD", .{});
                help.print_help(Cmd.add);
            },
            Cmd.new => {
                std.debug.print("\nGOT CMD NEW", .{});
                help.print_help(Cmd.new);
            },
            Cmd.run => {
                std.debug.print("\nGOT CMD RUN", .{});
                help.print_help(Cmd.run);
            },
            Cmd.log => {
                std.debug.print("\nGOT CMD Log", .{});
                help.print_help(Cmd.log);
            },
            Cmd.list => {
                std.debug.print("\nGOT List cmd", .{});
                help.print_help(Cmd.list);
            },
            Cmd.find => {
                std.debug.print("\nGOT find cmd", .{});
                help.print_help(Cmd.find);
            },
            Cmd.shell => {
                std.debug.print("\nGOT shell cmd", .{});
                help.print_help(Cmd.shell);
            },
            Cmd.remove => {
                std.debug.print("\nGOT rm cmd", .{});
                help.print_help(Cmd.remove);
            },

        }
    }
};

pub fn match_cmd(gpa: *std.mem.Allocator) !Cmd {
    const args = try proc.argsAlloc(gpa);
    defer proc.argsFree(gpa, args);
    if (args.len == 1) { 
        help.print_help(null);
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
