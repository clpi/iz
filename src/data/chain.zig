const std = @import("std");

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
    
}
