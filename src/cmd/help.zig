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
    printFg(.blue, comptime bold("izle"));
    printFg(.green, " cli ");
    print("<{s}>\n", .{comptime col.yellow.fg("August 2021")});
}

pub fn print_info() void {
    print("\t  - version: {s}-{s}\n", .{"0.1.0", "unstable.1"});
    print("\t  - author:  {s} <{s}>\n", .{"Chris P", comptime col.yellow.fg("clp@clp.is")});
    print("\t  - about:   {s}\n", .{"A CLI utility primarily aimed to create a structured logging workspace/environment, currently"});
    print("\t            {s}\n", .{"aimed to help log type 1 diabetic blood glucose info. Eventually will be expanded to work as"});
    print("\t            {s}\n", .{"a generalized CLI workspace automation framework prototype as a basis for other projects."});
    print("\t  - note:    {s} {s}\n", .{"In very early development.", comptime col.yellow.fg("Use at your own risk\n")});
}

pub fn print_usage() void {
    printBold("USAGE\n");
    print("\t    {s} {s} {s} {s} {s}\n", .{comptime bold("iz"), comptime fg(.blue, "<CMD>"), comptime fg(.green, "<TARGET>"), comptime fg(.yellow, "<VALUE>"), comptime col.red.fg("<OPTS>")});
    print("\tex. {s} {s} {s} {s} {s}\n", .{comptime bold("iz"), comptime fg(.blue, "log  "), comptime fg(.green, "bg      "), comptime fg(.yellow, "126    "), comptime fg(.red, "--debug")});
    print("\tex. {s} {s} {s} {s} {s}\n", .{comptime bold("iz"), comptime fg(.blue, "avg  "), comptime fg(.green, "sleep   "), comptime fg(.yellow, "week   "), comptime fg(.red, "--verbose")});
    print("\tex. {s} {s} {s} {s} {s}\n", .{comptime bold("iz"), comptime fg(.blue, "new  "), comptime fg(.green, "field   "), comptime fg(.yellow, "a1c    "), comptime fg(.red, "--global")});
    print("\tex. {s} {s} {s} {s} {s}\n", .{comptime bold("iz"), comptime fg(.blue, "init "), comptime fg(.green, "log     "), comptime fg(.yellow, "lifting"), comptime fg(.red, "--default")});
    print("\n        For help on individual commands, run {s}.\n", .{comptime col.green.fg("iz <cmd> help")});

}

pub fn print_commands() void {
    printBold("\nCOMMANDS\n");
    print("\t{s}    {s}\t\tPrint this help message\n", .{"h", "help"});
    print("\t{s}    {s}\t\tInitialize a new workspace\n", .{"i", "init"});
    print("\ti    init\t\tInitialize a new workspace\n", .{});
    print("\tr    run\t\tRun an automation\n", .{});
    print("\tls   list\t\tList all automations\n", .{});

}
pub fn print_opts() void {
    printBold("\nOPTS\n");
    print("\t-d  --debug\t\tPring extra debug messages\n", .{});
    print("\t-h  --help\t\tPrint this help message\n", .{});
}

pub fn print_header() void {
    printFg(.green, "\nThe ");
    print("{s}", .{comptime bold(fg(.green, "izle"))});
    print("{s}\n", .{comptime fg(.green, " cli")});
}
pub fn print_news() void {
    printBold("NEWS\n");
    print("- 08/07/21 New CLI parsing and styling features addded.", .{});
}
