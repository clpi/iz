const std = @import("std");
const eql = std.mem.eql;
const Color = @import("terminal/ansi.zig").Color;
// const eql = std.meta.eql;
const help = @import("./cmd/help.zig");
const err = @import("./error.zig");
const proc = std.process;
const fs = std.fs;
const wasi = std.fs.wasi;
const wasm = std.wasm;

var a: *std.mem.Allocator = undefined;

pub fn match_cmd(gpa: *std.mem.Allocator) !Cmd {
    const args = try proc.argsAlloc(gpa);
    defer proc.argsFree(gpa, args);
    if (args.len == 1) help.print_help(null);
    var cmd: ?Cmd = null;
    var opts = std.ArrayList(Opt.Pair).init(gpa);
    errdefer opts.deinit();

    for (args) |arg, i| {
        switch (i) {
            0 => continue,
            1 => {
                if (Cmd.fromStr(arg)) |command| {
                    std.debug.warn("Got cmd: [{s}]\n", .{command});
                    cmd = command;
                } else  continue; 
            },
            else => {
                if (Opt.Pair.fromStr(arg)) |kv| {
                    std.debug.warn("Got opt or arg: [k: {s}, v: {s}]\n", .{kv.key, kv.val});
                    try opts.append(kv);
                } else {
                    continue;
                }
            }
        }
    }
    // std.log.scoped(.cmd).info("OPTS: {}", .{opts});
    if (cmd) |c| return c;
    return Cmd.help;
}

pub const Ops = enum {
    get, add, log, new
};

pub const CmdResult = struct {
    cmd: Cmd,
    opts: anytype,

    pub fn parse(gpa: *std.mem.Allocator) !CmdResult {
        const args = try proc.argsAlloc(gpa);
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer proc.argsFree(gpa, args);
        if (args.len == 1) help.print_help(null);

        var cmd: ?Cmd = null;
        var opts = std.ArrayList(Opt.Pair).init(gpa);
        errdefer opts.deinit();

        for (args) |arg, i| {
            switch (i) {
                0 => continue,
                1 => {
                    if (Cmd.fromStr(arg)) |command| {
                        std.debug.warn("Got cmd: [{s}]\n", .{command});
                        cmd = command;
                    } else  continue; 
                },
                else => {
                    if (Opt.Pair.fromStr(arg)) |kv| {
                        std.debug.warn("Got opt or arg: [k: {s}, v: {s}]\n", .{kv.key, kv.val});
                        try opts.append(kv);
                    } else continue;
                }
            }

            // std.log.scoped(.cmd).info("{}: {s}\n", .{i, arg});
        }
        std.log.scoped(.cmd).info("OPTS: {}", .{opts});
        cmd_result.opts = opts;
        if (cmd) |c| cmd_result.cmd = c
        else cmd_result.cmd = Cmd.help;
        return cmd_result;
    }

    pub fn deinit(self: CmdResult, gpa: *std.mem.Allocator) void {
        gpa.free(self.cmd);
    }

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


pub fn parse_opts(arg: []const u8) ?[]const u8 {
    return null;
}

pub const Opt = enum {
    dir,

    pub fn OptPair(comptime V: ?type) type {
        return struct {
            key: []const u8, 
            val: V,
        };
    }

    pub const OptType = enum(u8) {
        short, long,

        pub fn fromStr(arg: []const u8) ?OptType {
            if (std.mem.startsWith(u8, arg, "--")) {
                if (!std.mem.eql(u8, arg, "--"))  {
                    return .long;
                }
            } else if (std.mem.startsWith(u8, arg, "-")) {
                return .short;
            }
            return null;
        }

        pub fn remainder(self: OptType, opt: []const u8) []const u8 {
            switch (self) {
                .long => return opt[2..],
                .short => return opt[1..],
            }
        }
    };

    const Pair = struct {
        key: []const u8,
        val: ?[]const u8,

        pub fn fromStr(arg: []const u8) ?Pair {
            // std.log.scoped(.cmd).info("Trying to parse to opt:   {s}\n", .{arg});
            if (OptType.fromStr(arg)) |ot| {
                const rem = ot.remainder(arg);
                if (std.mem.indexOf(u8, rem, "=")) |ix| {
                    return Pair { .key = rem[0..ix], .val = rem[ix+1..] };
                } else {
                    return Pair { .key = rem, .val = null };
                }
            }
            return null;
        }
    };

};

pub const Cmd = enum {
    add, help,  new, log, run, list, find, remove, shell, init, sim, inbox,

    pub fn fromStr(arg: []const u8) ?Cmd {
        // std.log.scoped(.cmd).info("Trying to parse to cmd:   {s}\n", .{arg});
        if (eql(u8, arg, "help") or eql(u8, arg, "h")) return Cmd.help
        else if (eql(u8, arg, "init") or eql(u8, arg, "i")) return Cmd.init
        else if (eql(u8, arg, "inbox") or eql(u8, arg, "in")) return Cmd.inbox
        else if (eql(u8, arg, "new") or eql(u8, arg, "n")) return Cmd.new
        else if (eql(u8, arg, "add") or eql(u8, arg, "a")) return Cmd.add
        else if (eql(u8, arg, "log") or eql(u8, arg, "l")) return Cmd.log
        else if (eql(u8, arg, "run") or eql(u8, arg, "r")) return Cmd.run
        else if (eql(u8, arg, "list") or eql(u8, arg, "ls")) return Cmd.list
        else if (eql(u8, arg, "remove") or eql(u8, arg, "rm")) return Cmd.remove
        else if (eql(u8, arg, "find") or eql(u8, arg, "f")) return Cmd.find
        else if (eql(u8, arg, "shell") or eql(u8, arg, "sh")) return Cmd.shell
        else if (eql(u8, arg, "sim") or eql(u8, arg, "s")) return Cmd.sim
        else return null;
    }

    pub fn info(cmd: Cmd) CmdInfo {
        switch (cmd) {
            .help => return CmdInfo.init("h", "help", "Print help for the CLI or for a command"),
            .inbox => return CmdInfo.init("in", "inbox", "Check messages in inbox"),
            .run => return CmdInfo.init("r", "run", "Run an automation in the current workspace"),
            .list => return CmdInfo.init("ls", "list", "List resources in the current workspace"),
            .find => return CmdInfo.init("f", "find", "Find resources in or across workspaces"),
            .shell => return CmdInfo.init("sh", "shell", "Start a shell environment in this workspace"),
            .new => return CmdInfo.init("n", "new", "Create a new resource or workspace"),
            .init => return CmdInfo.init("i", "init", "Initialize/bootstrap the current directory"),
            .add => return CmdInfo.init("a", "add", "Add or import a new resource into the workspace"),
            .log => return CmdInfo.init("l", "log", "Create a new entry in this workspace's log"),
            .remove => return CmdInfo.init("rm", "remove", "Remove a resource in the workspace"),
            .sim => return CmdInfo.init("s", "sim", "Simulate a network of users + interactions")
        }
        return CmdInfo.init("h", "help", "Print the help for base subcommands or a provided command");
    }

    pub fn matches(arg: []const u8, short: []const u8, long: []const u8) void {

    }

    pub fn exec(cmd: Cmd) void {
        switch (cmd) {
            Cmd.help => {
                help.print_help(null);
            },
            Cmd.init => {
                help.print_help(Cmd.init);
            },
            Cmd.inbox => {
                help.print_help(Cmd.inbox);
            },
            Cmd.add => {
                help.print_help(Cmd.add);
            },
            Cmd.new => {
                help.print_help(Cmd.new);
            },
            Cmd.run => {
                help.print_help(Cmd.run);
            },
            Cmd.log => {
                help.print_help(Cmd.log);
            },
            Cmd.list => {
                help.print_help(Cmd.list);
            },
            Cmd.find => {
                help.print_help(Cmd.find);
            },
            Cmd.shell => {
                help.print_help(Cmd.shell);
            },
            Cmd.remove => {
                help.print_help(Cmd.remove);
            },
            Cmd.sim => {
                help.print_help(Cmd.sim);
            }

        }
    }
};


pub fn parse_opt(comptime opt: []const u8, arg: [:0]const u8) [:0]const u8 {
    const val = arg[opt.len];
    if (val.len < 2)
        fatal("Option {s} must be passed value", .{ opt });
    if (val[0] != '=') {
        err.fatal("Expected '=' after {s} but found '{c}'", .{ opt, val[0] });
    }
    return val[1..];
}

fn arena_alloc() !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    a = &arena.allocator;
    defer arena.deinit;
}
