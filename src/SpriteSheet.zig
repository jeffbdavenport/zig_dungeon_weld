const main = @import("main.zig");
const SDL = main.SDL;
const Tile = @import("SpriteSheet/Tile.zig");
const p = main.p;
const toF = main.toF;

pub fn Size(comptime T: type) type {
    return struct {
        width: T,
        height: T,
    };
}

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

pub fn new(texture: *SDL.Texture, tile: Size(u8), padding: u8, scale: u8, flip: Flip) !@This() {
    const info = try texture.query();
    const scale_f = toF(scale);

    return @This(){ .flip = flip, .texture = texture, .tile = .{ .width = toF(tile.width), .height = toF(tile.height) }, .size = .{
        .width = toF(info.width),
        .height = toF(info.height),
    }, .padding = toF(padding), .spacing = .{
        .height = toF(tile.height) + toF(padding * 2),
        .width = toF(tile.width) + toF(padding * 2),
    }, .print = .{
        .width = toF(tile.width) * scale_f,
        .height = toF(tile.height) * scale_f,
    } };
}

pub fn toX(self: *const @This(), col: u16) f32 {
    return (toF(col) * self.spacing.width) + self.padding;
}

pub fn toY(self: *const @This(), row: u16) f32 {
    const minus = (toF(row) * self.spacing.height) + self.padding;
    // return self.size.height - minus;
    return minus;
}

pub fn newTile(self: *const @This(), row: u16, col: u16) Tile {
    return Tile.new(self, row, col);
}
