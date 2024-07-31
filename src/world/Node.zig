const main = @import("../main.zig");
const positionAdd = main.positionAdd;
const std = main.std;
const SDL = main.SDL;
const world = main.world;
const display = main.display;

pub var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

position: SDL.PointF = .{},
offset: SDL.PointF = .{},
nodes: std.ArrayList(*@This()) = std.ArrayList(*@This()).init(arena.allocator()),
holder: NodeType = undefined,
parent: *@This() = undefined,
is_root: bool = true,

pub const NodeType = union(enum) {
    sprite: world.Sprite,
    camera: world.Camera,
};

pub fn addNode(self: *@This(), node: *@This()) !void {
    try self.nodes.append(node);
    node.parent = self;
    node.is_root = false;
}
pub fn globalPosition(self: @This()) SDL.PointF {
    const holder_position = if (self.is_root) SDL.PointF{} else self.parent.globalPosition();
    return positionAdd(self.position, holder_position);
}

pub fn deinit(self: @This()) void {
    for (self.nodes.items) |node| {
        node.deinit();
    }
    self.nodes.deinit();
}
