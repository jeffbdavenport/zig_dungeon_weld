const main = @import("../main.zig");
const positionAdd = main.positionAdd;
const std = main.std;
const SDL = main.SDL;
const world = main.world;
const display = main.display;

pub var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

position: SDL.PointF = .{},
offset: SDL.PointF = .{},
nodes: std.ArrayList(NodeType) = std.ArrayList(NodeType).init(display.Renderer.arena.allocator()),
holder: NodeType = undefined,
is_root: bool = true,

pub const NodeType = union(enum) {
    node: *world.Node,
    sprite: *world.Sprite,
    camera: *world.Camera,

    pub fn addNode(self: @This(), node: NodeType) !void {
        try switch (self) {
            .node => |n| n.nodes.append(node),
            .sprite => |s| s.node.nodes.append(node),
            .camera => |c| c.node.nodes.append(node),
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
            .camera => |c| {
                c.node.holder = self;
                c.node.is_root = false;
            },
        }
    }
};

pub fn globalPosition(self: *@This()) SDL.PointF {
    const holder_position = if (self.is_root) SDL.PointF{} else switch (self.holder) {
        .node => |n| n.*,
        .sprite => |s| s.node,
        .camera => |c| c.node,
    }.globalPosition();
    return positionAdd(self.position, holder_position);
}

pub fn deinit(self: *@This()) void {
    for (self.nodes.items) |node| {
        switch (node) {
            .node => |n| n.deinit(),
            .sprite => |s| s.node.deinit(),
            .camera => |c| c.node.deinit(),
        }
    }
    self.nodes.deinit();
}
