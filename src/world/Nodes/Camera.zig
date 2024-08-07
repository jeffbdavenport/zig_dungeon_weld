const main = @import("../../main.zig");
const p = main.p;
const SDL = main.SDL;
const world = main.world;
const SpriteSheet = main.SpriteSheet;

pub var active: ?*world.Node = undefined;

size: main.Size(f32),

pub fn topLeft(self: *@This()) SDL.PointF {
    return .{
        .x = (self.size.width / 2),
        .y = (self.size.height / 2),
    };
}
