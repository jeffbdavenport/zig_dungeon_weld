const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const Geometry = display.Geometry;
const Tile = main.SpriteSheet.Tile;
const toUSize = main.toUSize;

const render_size = @import("root").render_size;
const tile_size = @import("root").tile_size;
const cols = render_size.width / tile_size;
const rows = render_size.height / tile_size;

texture: SDL.Texture,

pub fn new(tile: Tile, renderer: *display.Renderer) !@This() {
    var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
    defer arena.deinit();
    var geometry = display.Geometry.new(&arena, tile.sprite_sheet.texture);
    defer geometry.deinit();

    var row: u16 = 0;
    while (row < rows) : (row += 1) {
        var col: u16 = 0;
        while (col < cols) : (col += 1) {
            try geometry.addTile(tile, tile.sprite_sheet.rowColPosition(row, col));
        }
    }

    const texture = try SDL.createTexture(renderer.sdl, SDL.PixelFormatEnum.rgba8888, SDL.Texture.Access.target, toUSize(renderer.size.width), toUSize(renderer.size.height));
    const prev = renderer.sdl.getTarget();
    try renderer.sdl.setTarget(texture);

    try renderer.sdl.drawGeometry(
        tile.sprite_sheet.texture.*,
        geometry.vertices.items,

        geometry.indices.items,
    );
    try renderer.sdl.setTarget(prev);

    return @This(){
        .texture = texture,
    };
}

pub fn deinit(self: *@This()) void {
    self.texture.destroy();
}
