// based on btree by github.com/rvcas/zata
const std = @import("std");
const testing = std.testing;

pub fn BTree(comptime T: type) type {
    return struct {
        root: usize = 1,
        items: []?Node,
        count: usize = 0,
        capacity: usize = 0,
        allocator: *std.mem.Allocator,

        const Node = struct {
            ix: usize,
            left: usize,
            right: usize,
            data: T,

            pub fn init(data: T, ix: usize) Node {
                return Node {
                    .ix = ix,
                    .left = 2 * ix,
                    .right = (2 * ix) + 1,
                    .data = data
                };
            }

        };

        pub const SearchResult = union(enum) {
            found: Found,
            not_found,

            pub const Found = struct {
                ix: usize,
                data: T
            };

            pub fn found(node: Node) SearchResult {
                return SearchResult {
                    .found { Found { .ix = node.ix, .data = node.data } }
                };
            }
        };


        pub fn init(allocator: *std.mem.Allocator) BTree(T) {
            return BTree(T) {
                .items = &[_]?Node{},
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *BTree(T)) void {
            self.allocator.free(self.items.ptr[0..self.capacity]);
        }

        pub fn validateCapacity(self: *BTree(T), capacity: usize) !void {
            var new_cap = self.capacity;
            if (new_cap >= capacity) return;

            while (true) {
                new_cap += capacity / 2 + 8;
                if (new_cap >= capacity) break;
            }
            const mem_alloc = self.items.ptr[0..self.capacity];
            const new_mem = try self.allocator.realloc(mem_alloc, new_cap);
            self.items.ptr = new_mem.ptr;
            self.capacity = new_mem.len;
            self.items.len = self.capacity;
        }

        pub fn insert(self: *BTree(T), data: T) !void {
            var iter: usize = 1;
            while (true) {
                try self.validateCapacity(iter);
                if (self.items[iter]) |node| {
                    if (data == node.data) break
                    else if (data > node.data) iter = node.right
                    else iter= node.left;
                } else {
                    self.items[iter] = Node.init(data, iter);
                    self.count += 1;
                    break;
                }
            }
        }

        pub fn find(self: *BTree(T), data: T) SearchResult {
            var iter: usize = 1;
            while (true) {
                if (iter > self.capacity) return .not_found;
                if (self.items[iter]) |node| {
                    if (data == node.data) return found(node)
                    else if (data > node.data) iter = node.right
                    else iter = node.left;
                } else { return .not_found; }
            }
        }

        pub fn map(self: *BTree(T), fun: fn (T) T) void {
            for (self.items) |*item| {
                if (item.*) |node| item.*.?.data = fun(node.data);
            }
        }

        pub fn remove(self: *BTree(T), data: T) void {
            switch (self.search(data)) {
                .found => |found| {
                    var temp = self.items[result.ix];
                    self.items[found.ix] = null;
                    self.count -= 1;
                },
                .not_found => {},
            }
        }
    };
}

test "btree_init" {
    var btree = BTree(usize).init(std.testing.allocator);
}

test "btree_insert" {
    var btree = BTree(usize).init(std.testing.allocator);
    try btree.insert(3);
    try btree.insert(6);
    try std.testing.expect(btree.count == 2);
}
