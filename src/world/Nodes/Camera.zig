const main = @import("../../main.zig");
const SDL = main.SDL;
const world = main.world;
const SpriteSheet = main.SpriteSheet;

pub var active: ?*@This() = null;

node: world.Node = world.Node{},
size: main.Size(f32),

pub fn topLeft(self: *@This()) SDL.PointF {
    return .{
        .x = (self.size.width / 2) + self.node.offset.x,
        .y = (self.size.height / 2) + self.node.offset.y,
    };
}
