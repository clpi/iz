const std = @import("std");
const ArrayList = std.ArrayList;
const EdgeIx = usize;
const NodeIx = usize;

pub const GraphKind = enum {
    directed, undirected
};

pub fn Graph(comptime N: type, comptime E: type) type {

    return struct {
        const Self = @This();

        allocator: *std.mem.Allocator,
        edges: ArrayList(E) = ArrayList(E) { },
        nodes: ArrayList(N) = ArrayList(T) { },
        directed: GraphKind,

        const Node = struct {
            const Self = @This();

            next_outgoing_edge: ?EdgeIx,
            next_incoming_edge: ?EdgeIx,
            weight: N,

            pub fn init(weight: N) Node {
                return Node{ 
                    .weight = weight,
                    .next_outgoing_edge = null,
                    .next_incoming_edge = null
                };
            }
            pub fn create(weight: N, next_inc: EdgeIx, next_out: EdgeIx) Node {
                return Node {
                    .weight = N ,
                    .next_incoming_edge = next_inc,
                    .next_outgoing_edge = next_out,
                };
            }

            pub fn next_edge(self: *Edge, dir: Dir) ?EdgeIx {
                switch (dir) {
                    .incoming => return self.next_incoming_edge,
                    .outgoing => return self.next_outgoing_edge,
                }
            }
        };

        const Dir = enum {
            incoming, outgoing
        };

        const Edge = struct {
            const Self = @This();

            src_node: NodeIx,
            dest_node: NodeIx,
            next_outgoing_edge: ?EdgeIx,
            next_incoming_edge: ?EdgeIx,
            weight: E,

            pub fn init(src: NodeIx, dest: NodeIx, weight: E) Edge {
                return Edge {
                    .weight = weight,
                    .src_node = src,
                    .dest_node = dest,
                    .next_outgoing_edge = null,
                    .next_incoming_edge = null
                };
            }

            pub fn create(src: NodeIx, dest: NodeIx, next_inc: EdgeIx, next_out: EdgeIx, weight: E) Edge {
                return Edge {
                    .weight = weight,
                    .src_node = src,
                    .dest_node = dest,
                    .next_outgoing_edge = next_out,
                    .next_incoming_edge = next_inc,
                };
            }

            pub fn next_edge(self: *Edge, dir: Dir) ?EdgeIx {
                switch (dir) {
                    .incoming => return self.next_incoming_edge,
                    .outgoing => return self.next_outgoing_edge,
                }
            }

            pub fn node(self: *Edge, dir: Dir) NodeIx {
                switch (dir) {
                    .incoming => return self.dest_node,
                    .outgoing => return self.src_node,
                }
            }
        };

        pub fn init(directed: GraphKind, allocator: *std.mem.Allocator) Graph(N, E) {
            return Graph(N, E) {
                .allocator = allocator,
                .directed = directed,
                .edges = ArrayList(E).init(allocator),
                .nodes = ArrayList(N).init(allocator),
            };
        }

        pub fn initCapacity(directed: GraphKind, allocator: *std.mem.Allocator, n: usize, e: usize) !Graph(N, E) {
            var nodes = try ArrayList(N).initCapacity(allocator, n);
            errdefer(nodes.deinit());
            var edges = try ArrayList(E).initCapacity(allocator, e);
            errdefer(edges.deinit());
            return Graph(N, E) {
                .allocator = allocator,
                .directed = directed,
                .edges = edges,
                .nodes = nodes,
            };
        }

        pub fn deinit(self: *Graph(N, E), allocator: *std.mem.Allocator) void {
            self.edges.deinit();
            self.nodes.deinit();
        }

        pub fn node(graph: *Graph(N, E), node: NodeIx) ?Node {
            if (node >= graph.nodes.items.len) return null;
            return graph.nodes.items[node];
        }

        pub fn nodeWeight(graph: *Graph(N, E), node: NodeIx) ?N {
            if (node >= graph.nodes.items.len) return null;
            return graph.nodes.items[node].weight;
        }

        pub fn edge(graph: *Graph(N, E), edge: EdgeIx) ?Edge {
            if (edge >= graph.edges.items.len) return null;
            return graph.edges.items[edge];

        }
        pub fn edgeWeight(graph: *Graph(N, E), edge: EdgeIx) ?E {
            if (edge >= graph.edges.items.len) return null;
            return graph.edges.items[edge].weight;

        }
    };

}

const testing = std.testing;
const expect = std.testing.expect;
const assert = std.debug.assert;

test "Graph init" {
    const graph = Graph([]const u8, usize).init(.directed, testing.allocator);
}

