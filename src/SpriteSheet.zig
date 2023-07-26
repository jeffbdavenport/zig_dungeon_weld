const main = @import("main.zig");
const SDL = main.SDL;
const p = main.p;
const toF = main.toF;
const Size = main.Size;

pub const Tile = @import("SpriteSheet/Tile.zig");

pub const Flip = struct {
    x: bool = false,
    y: bool = false,
};

texture: *SDL.Texture,
tile: Size(f32),
print: Size(f32),
size: Size(f32),
padding: f32,
spacing: Size(f32),
flip: Flip,

pub fn new(texture: *SDL.Texture, tile: Size(u8), padding: u8, scale: f32, flip: Flip) !@This() {
    const info = try texture.query();

    return @This(){ .flip = flip, .texture = texture, .tile = .{ .width = toF(tile.width), .height = toF(tile.height) }, .size = .{
        .width = toF(info.width),
        .height = toF(info.height),
    }, .padding = toF(padding), .spacing = .{
        .height = toF(tile.height) + toF(padding * 2),
        .width = toF(tile.width) + toF(padding * 2),
    }, .print = .{
        .width = toF(tile.width) * scale,
        .height = toF(tile.height) * scale,
    } };
}

pub fn rowColPosition(self: *const @This(), row: u16, col: u16) SDL.PointF {
    return .{ .x = self.toX(col), .y = self.toY(row) };
}

pub fn toX(self: *const @This(), col: u16) f32 {
    return toF(col) * self.tile.width;
}

pub fn toY(self: *const @This(), row: u16) f32 {
    return toF(row) * self.tile.height;
}

pub fn texToX(self: *const @This(), col: u16) f32 {
    return (toF(col) * self.spacing.width) + self.padding;
}

pub fn texToY(self: *const @This(), row: u16) f32 {
    return (toF(row) * self.spacing.height) + self.padding;
}

pub fn newTile(self: *const @This(), row: u16, col: u16) Tile {
    return Tile.new(self, row, col);
}
