const main = @import("../main.zig");
const std = main.std;
const SDL = main.SDL;
const world = main.world;

pub var arena: std.heap.ArenaAllocator = undefined; // = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

position: SDL.PointF = .{},
nodes: std.ArrayList(NodeType) = std.ArrayList(NodeType).init(arena.allocator()),
holder: NodeType = undefined,
is_root: bool = true,

pub const NodeType = union(enum) {
    node: *world.Node,
    sprite: *world.Sprite,

    pub fn addNode(self: @This(), node: NodeType) !void {
        try switch (self) {
            .node => |n| n.nodes.append(node),
            .sprite => |s| s.node.nodes.append(node),
        };
        switch (node) {
            .node => |n| {
                n.holder = self;
                n.is_root = false;
            },
            .sprite => |s| {
                s.node.holder = self;
                s.node.is_root = false;
            },
        }
    }
};

pub fn deinit(self: *@This()) void {
    self.nodes.deinit();
}
