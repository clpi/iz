const std = @import("std");

pub fn main() !void {
    const log = std.log.scoped(.bench);
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    if (std.builtin.mode != .ReleaseSafe and std.builtin.mode != .ReleaseFast) {
        try stderr.print("Bench must be built as ReleaseSafe for performance\n", .{});
    }
    var ar = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer ar.deinit();
    const allctr = &ar.allocator;
}
