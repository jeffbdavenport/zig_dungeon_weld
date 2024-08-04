const main = @import("../main.zig");
const positionAdd = main.positionAdd;
const std = main.std;
const SDL = main.SDL;
const world = main.world;
const display = main.display;

pub var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

position: SDL.PointF = .{},
offset: SDL.PointF = .{},
nodes: std.ArrayList(@This()) = std.ArrayList(@This()).init(arena.allocator()),
holder: ?NodeType = null,
parent: ?*@This() = null,

pub const NodeType = union(enum) {
    sprite: world.Sprite,
    camera: world.Camera,
};

pub fn addNodeGetPtr(self: *@This(), node: @This()) !*@This() {
    var ref: *@This() = try self.nodes.addOne();
    ref.* = node;
    ref.parent = self;
    return ref;
}

pub fn addNode(self: *@This(), node: @This()) !void {
    _ = try self.addNodeGetPtr(node);
}
pub fn globalPosition(self: *@This()) SDL.PointF {
    const holder_position = if (self.parent) |p| p.globalPosition() else SDL.PointF{};
    return positionAdd(self.position, holder_position);
}

pub fn deinit(self: @This()) void {
    for (self.nodes.items) |node| {
        node.deinit();
    }
    self.nodes.deinit();
}
