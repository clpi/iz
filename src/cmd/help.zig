const std = @import("std");
const ansi = @import("../terminal/ansi.zig");
const col = ansi.Color;
const green = color.green;
const yellow = color.yellow;
const fg = ansi.Color.fg;
const bold = ansi.Color.bold;
const bg = ansi.Color.bg;
const print = std.debug.print;
const printBold = ansi.printBold;
const printFg = ansi.Color.printFg;

pub fn print_help() void {
    print_welcome();
    print_info();
    print_usage();
    print_commands();
    print_opts();
    print_news();
}

pub fn print_welcome() void {
    printBold("INFO: ");
    printFg(.green, "\n\tThe ");
    printFg(.magenta, comptime bold("izle"));
    printFg(.green, " cli ");
    print("<{s}>\n\n", .{comptime col.yellow.fg("August 2021")});
}

pub fn print_info() void {
    print("\t- version: {s}-{s}\n", .{"0.1.0", "unstable.1"});
    print("\t- author:  {s} <{s}>\n", .{"Chris P", comptime col.yellow.fg("clp@clp.is")});
    print("\t- about:   {s}\n", .{"A CLI utility primarily aimed to create a structured logging workspace/environment, currently"});
    print("\t           {s}\n", .{"aimed to help log type 1 diabetic blood glucose info. Eventually will be expanded to work as"});
    print("\t           {s}\n", .{"a generalized CLI workspace automation framework prototype as a basis for other projects."});
    print("\t- note:    {s} {s}\n", .{"In very early development.", comptime col.yellow.fg("Use at your own risk\n")});
}

pub fn print_usage() void {
    printBold("USAGE\n");
    print_ex("<CMD>","<TARGET>", "<VALUE>", "<OPTS>");
    print("\nFor example:\n", .{});
    print_ex("log  ", "bg      ", "126    ", "--debug");
    print_ex("avg  ", "sleep   ", "week   ", "--verbose");
    print_ex("new  ", "field   ", "a1c    ", "--global");
    print_ex("init ", "log     ", "lift   ", "--default");
    print("\n        For help on individual commands, run {s}.\n", .{comptime col.green.fg("iz <cmd> help")});

}

pub fn print_ex(
    comptime cmd: []const u8, 
    comptime target: []const u8,
    comptime val: []const u8,
    comptime opts: []const u8) void 
{
    const iz: []const u8 = comptime bold(comptime fg(.magenta, "iz"));
    const scmd = comptime fg(.blue, cmd);
    const stgt =  comptime fg(.green, target);
    const sval =  comptime fg(.yellow, val);
    const sopts =  comptime fg(.red, opts);
    print("\t    {s}   {s} {s} {s} {s}\n", .{iz, scmd, stgt, sval, sopts});
}

pub fn print_commands() void {
    printBold("\nCOMMANDS\n");
    print_command("i", "init", "Initialize a new workspace");
    print_command("r", "run", "Run a saved automation");
    print_command("ls","list","List and search for resources");
    print_command("rm","remove","Remove a resource in current workspace");
    print_command("s","switch","Change to a new or existing workspace");
    print_command("sh","shell","Enter the iz shell for current workspace");
    print_command("h","help","Print help for the CLI or for a command");

}

pub fn print_command(comptime short: []const u8, comptime long: []const u8, desc: []const u8) void {
    const sshort = comptime col.bold(col.green.fg(short));
    const slong = comptime col.green.fg(long);
    if (short.len == 1) print("\t{s}    {s}\t\t{s}\n", .{sshort, slong, desc})
    else if (short.len == 2) print("\t{s}   {s}\t\t{s}\n", .{sshort, slong, desc})
    else print("\t{s}  {s}\t\t{s}\n", .{sshort, slong, desc});
}
pub fn print_opt(comptime short: []const u8, comptime long: []const u8, desc: []const u8) void {
    const sshort = comptime col.bold(col.blue.fg(short));
    const slong = comptime col.blue.fg(long);
    if (short.len == 1) print("\t-{s}   --{s}\t\t{s}\n", .{sshort, slong, desc})
    else if (short.len == 2) print("\t{s}  --{s}\t\t{s}\n", .{sshort, slong, desc})
    else print("\t{s}  --{s}\t\t{s}\n", .{sshort, slong, desc});
}
pub fn print_opts() void {
    printBold("\nOPTS\n");
    print_opt("d", "debug", "Print extra debug verbose msgs");
    print_opt("h", "help", "Print help for the current command");
    print_opt("v", "version", "Print the IZLE cli utility version info");
}

pub fn print_header() void {
    printFg(.green, "\nThe ");
    print("{s}", .{comptime bold(fg(.green, "izle"))});
    print("{s}\n", .{comptime fg(.green, " cli")});
}
pub fn print_news() void {
    printBold("\nNEWS\n");
    print("\t- {s} {s}\n", .{comptime col.green.fg("08/07/2021"), "Help message styling finished"});
    print("\t- {s} {s}\n", .{comptime col.green.fg("08/07/2021"), "New CLI parsing and styling features addded"});
}
