const std = @import("std");

pub fn print_help() void {
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
