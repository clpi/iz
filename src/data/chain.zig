const std = @import("std");

pub fn AutoChainMap(
    comptime K: type, 
    comptime V: type, 
    comptime max_load_pct: comptime_int) 
    type 
{
    return HashMap(K, V, max_load_pct, std.hash_map.AutoContext(K));
}

pub fn ChainMap(
    comptime K: type, 
    comptime V: type, 
    comptime max_load_pct: comptime_int, 
    comptime Context: type
) type {
    return struct {

        links: [*]?*Link,
        nodes: [*]?*Link,
        len: usize = 0,
        shift: u6,

        pub const Link = struct {
            key: K = undefined,
            val: V = undefined,
            prev: ?*Link = null,
            next: ?*Link = null,
        };
        const Self = @This();
    };
}

pub fn Chain(comptime T: type) type {
    return struct {
        head: ?*Link, 
        tail: ?*Link,
        len: usize,
        allocator: *std.mem.Allocator,

        pub const Link = struct {
            prev: ?*Link,
            next: ?*Link,
            data: T,

            pub fn init(data: T) Link {
                return Link {
                    .prev = null,
                    .next = null,
                    .data = data
                };
            }
        };

        pub fn init(allocator: *std.mem.Allocator) Chain(T) {
            return Chain(T) {
                .head = null,
                .tail = null,
                .len = 0,
                .allocator = allocator
            };
        }

        pub fn deinit(self: *Chain(T)) void {
            if (self.head == null and self.tail == null) return;
            while (self.len > 0) {
                var prev = self.tail.?.prev;
                self.allocator.destroy(self.tail);
                self.tail = prev;
                self.len -= 1;
            }
            self.head = null;
        }

        pub fn prepend(self: *Chain(T), data: T) !void {
            var new_link = try self.allocator.create(Link);
            errdefer self.allocator.destroy(new_link);
            new_link.* = Link.init(data);
            if (self.head) |head| {
                new_link.next = head;
                head.prev = new_node;
            } else {
                self.tail = new_link;
            }
            self.head = new_link;
            self.len += 1;
        }

        pub fn push(self: *Chain(T), data: T) !void {
            var new_link = try self.allocator.create(Link);
            errdefer self.allocator.destroy(new_link);
            new_link.* = Link.init(data);
            if (self.tail) |tail| {
                new_link.prev = tail;
                tail.next = new_link;
            } else {
                self.head = new_link;
            }
            self.tail = new_link;
            self.len += 1;
        }

        pub fn contains(self: *Chain(T), data: T) bool {
            var iter = self.head;
            while (iter) |link| {
                if (link.data == data) return true;
                iter = link.next;
            } else { return false; }
        }
        
        pub fn pop(self: *Chain(T)) ?T {
            if (self.tail) |tail| {
                var data = tail.data;
                var prev = tail.prev;
                self.allocator.destroy(tail);
                self.len -= 1;
                self.tail = prev;
                if (prev == null) self.head = null;
                return data;
            } else { return null; }
        }

        pub fn map(self: *Chain(T), fun: fn(T) T) void {
            var it = self.head;
            while (iter) |link| {
                link.data = fun(link.data);
                it = link.next;
            }
        }
    };
}

test "Chain.init" {
    var chain = Chain(usize).init(std.testing.allocator);    
}

test "Chain.push" {
    var chain = Chain(usize).init(std.testing.allocator);
    try chain.push(3);
    try std.testing.expect(chain.len == 1);
}
