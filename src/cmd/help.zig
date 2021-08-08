const std = @import("std");
const ansi = @import("../terminal/ansi.zig");
const Color = ansi.Color;
const green = color.green;
const yellow = color.yellow;
const fg = ansi.Color.fg;
const bold = ansi.Color.bold;
const bg = ansi.Color.bg;
const print = std.debug.print;
const printBold = ansi.printBold;
const printFg = ansi.Color.printFg;
const cmd = @import("../cmd.zig");
const Cmd = cmd.Cmd;
const CmdInfo = cmd.CmdInfo;
const OptInfo = cmd.OptInfo;

pub fn print_help(help_cmd: ?Cmd) void {
    if (help_cmd) |command| {
        print_usage(command);
        print_commands(command);
        print_opts(command);
    } else {
        print_welcome(); 
        print_info();
        print_usage(null);
        print_commands(null);
        print_opts(null);
        print_news();
    }
}

pub fn print_welcome() void {
    print_heading(.green, null, "INFO");
    printFg(.green, "  The ");
    printFg(.magenta, comptime ansi.Color.bold("iz"));
    printFg(.green, " cli ");
    print("<{s}>\n", .{comptime Color.yellow.fg("August 2021")});
}

pub fn print_info() void {
    print("  - {s}: {s}-{s}\n", .{comptime Color.green.fg("version"), "0.1.0", "unstable.1"});
    print("  - {s}:  {s} <{s}>\n", .{comptime Color.green.fg("author"), "Chris P", comptime Color.yellow.fg("clp@clp.is")});
    print("  - {s}:   {s}\n", .{
        comptime Color.green.fg("about"), 
        "A CLI utility primarily aimed to create a structured logging workspace/environment, currently"
    });
    print("             {s}\n", .{
        "aimed to help log type 1 diabetic blood glucose info. Eventually will be expanded to work as"
    });
    print("             {s}\n", .{"a generalized CLI workspace automation framework prototype as a basis for other projects."});
    print("  - {s}:    {s} {s}\n", .{
        comptime Color.green.fg("note"), "In very early development.", 
        comptime Color.yellow.fg("Use at your own risk")
    });
}

pub fn print_usage(help_cmd: ?Cmd) void {
    if (help_cmd) |command| {
        print_heading(.magenta, command.info().long, "USAGE");
        switch (command) {
            Cmd.new => {
                print_ex("new","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.log => {
                print_ex("log","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.run => {
                print_ex("run","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.init => {
                print_ex("init","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.help => {
                print_ex("help","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.find => {
                print_ex("find","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.list => {
                print_ex("list","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.shell => {
                print_ex("shell","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.add => {
                print_ex("add","<TARGET>", "<VALUE>", "<OPTS>");
            },
            Cmd.remove => {
                print_ex("remove","<TARGET>", "<VALUE>", "<OPTS>");
            },
        }
    } else {
        print_base_usage();
    }
}
pub fn print_base_usage() void {
    print_heading(.magenta, null, "USAGE");
    print_ex("<CMD>","<TARGET>", "<VALUE>", "<OPTS>");
    print("\n\tFor example:\n", .{});
    print_ex("log  ", "bg      ", "126    ", "--debug");
    print_ex("avg  ", "sleep   ", "week   ", "--verbose");
    print_ex("new  ", "field   ", "a1c    ", "--global");
    print_ex("init ", "log     ", "lift   ", "--default");
    print("\n        For help on individual commands, run {s} {s} {s}.\n", .{
        comptime Color.magenta.fg("iz"),
        comptime Color.blue.fg("<CMD>"),
        comptime Color.yellow.fg("help")
    });

}

pub fn print_ex(
    comptime excmd: []const u8, 
    comptime target: []const u8,
    comptime val: []const u8,
    comptime opts: []const u8) void 
{
    const iz: []const u8 = comptime bold(comptime fg(.magenta, "iz"));
    const scmd = comptime fg(.blue, excmd);
    const stgt =  comptime fg(.green, target);
    const sval =  comptime fg(.yellow, val);
    const sopts =  comptime fg(.red, opts);
    std.debug.print("    {s}  {s} {s} {s} {s}\n", .{iz, scmd, stgt, sval, sopts});
}

pub fn print_commands(help_cmd: ?Cmd) void {
    if (help_cmd) |command| {
        print_heading(.green, command.info().long, "COMMANDS");
        switch (command) {
            Cmd.help => print_base_commands(),
            Cmd.new => {
                print_command("l", "log", "Create a new log chain");
                print_command("r", "rel", "Create a new relation between two items in the log net");
                print_command("w", "workspace", "jreate a new empty workspace");
                print_command("f", "field", "Create a new field for an item");
                print_command("e", "entry", "Create a new entry in the log chain ");
                print_command("n", "node", "Create a new node in the log net ");
                print_command("a", "auto", "Create a new data automation");
            },
            Cmd.shell => print("No shell help yet", .{}),
            Cmd.log => print("No log help yet", .{}),
            Cmd.find => print("No find help yet", .{}),
            else => print("No help yet for that command", .{})
        }
    } else print_base_commands();
}

pub fn print_base_commands() void {
    var init_cmd = CmdInfo.create("i", "init", "initialize a new workspace", &[_]OptInfo {});
    print_heading(.green, null, "COMMANDS");
    print_command("i", "init", "Initialize a new workspace");
    print_command("r", "run", "Run a saved automation");
    print_command("ls","list","List and search for resources");
    print_command("rm","remove","Remove a resource in current workspace");
    print_command("f","find","Look for/filter resources in and across workspaces");
    print_command("s","switch","Change to a new or existing workspace");
    print_command("sh","shell","Enter the iz shell for current workspace");
    print_command("n","new","Create a new workspace/environment");
    print_command("h","help","Print help for the CLI or for a command");
}
pub fn print_heading(comptime color: ?Color, cmd_str: ?[]const u8, comptime head_str: []const u8) void {
    var cmds: []const u8 = cmd_str orelse "";
    print("\n", .{});
    if (color) |col|  {
        if (cmd_str) |cmdstr|
            print("{s} - ({s})\n", .{comptime Color.bold(Color.fg(col, head_str)), cmds})
        else
            print("{s}\n", .{comptime Color.bold(Color.fg(col, head_str))});
    } else  {
        if (cmd_str)  |cmdstr|
            print("{s} - ({s})\n", .{comptime Color.bold(comptime head_str), cmds})
        else
            print("{s}\n", .{comptime Color.bold(comptime head_str)});
    }
    
}
pub fn print_command(comptime short: []const u8, comptime long: []const u8, desc: []const u8) void {
    const sshort = comptime Color.bold(Color.green.fg(short));
    const slong = comptime Color.green.fg(long);
    if (short.len == 1) print("    {s}   or {s}  \t     {s}\n", .{sshort, slong, desc})
    else if (short.len == 2) print("    {s}  or {s} \t     {s}\n", .{sshort, slong, desc})
    else print("    {s}  {s}\t\t{s}\n", .{sshort, slong, desc});
}
pub fn print_opt(comptime short: []const u8, comptime long: []const u8, desc: []const u8) void {
    const sshort = comptime Color.bold(Color.blue.fg(short));
    const slong = comptime Color.blue.fg(long);
    const hyph1 = comptime Color.magenta.fg("-");
    const hyph2 = comptime Color.magenta.fg("--");
    if (short.len == 1) print("    {s}{s}  or {s}{s}  \t     {s}\n", .{hyph1, sshort, hyph2, slong, desc})
    else if (short.len == 2) print("    {s} or --{s}  \t      {s}\n", .{sshort, slong, desc})
    else print("    {s}  --{s}\t{s}\n", .{sshort, slong, desc});
}
pub fn print_opts(help_cmd: ?Cmd) void {
    if (help_cmd) |command| {
        print_heading(.blue, command.info().long, "OPTS");
        switch (command) {
            Cmd.help => {},
            Cmd.new => {
            },
            else => {}
        }
    } else {
        print_base_opts();
    }
}
pub fn print_base_opts() void {
    print_heading(.blue, null, "OPTS");
    print_opt("d", "debug", "Print extra debug verbose msgs");
    print_opt("h", "help", "Print help for the current command");
    print_opt("v", "version", "Print the IZLE cli utility version info");
}

pub fn print_news() void {
    print_heading(.yellow,null,  "NEWS");
    print("    - {s}: {s}\n", .{comptime Color.yellow.fg("08/07/2021"), "Help message styling finished"});
    print("    - {s}: {s}\n", .{comptime Color.yellow.fg("08/07/2021"), "New CLI parsing and styling features addded"});
    print("\n", .{});
}
