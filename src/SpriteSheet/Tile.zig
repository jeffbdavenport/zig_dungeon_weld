const main = @import("../main.zig");
const SDL = main.SDL;
const SpriteSheet = main.SpriteSheet;
const p = main.p;

pub const Coord = struct {
    start: f32 = 0,
    end: f32 = 0,
};

pub const Coords = struct {
    x: Coord = .{},
    y: Coord = .{},
};

// sprite_sheet: *const SpriteSheet,
size: main.Size(f32),
flip: SpriteSheet.Flip,
tex: Coords,

// vertices: [4]SDL.Vertex,

const full_color = SDL.Color.rgb(255, 255, 255);

pub fn new(sprite_sheet: *const SpriteSheet, col: u16, row: u16) @This() {
    const x_start = sprite_sheet.texToX(col);
    const y_start = sprite_sheet.texToY(row);
    const x_divide = sprite_sheet.size.width;
    const y_divide = sprite_sheet.size.height;

    return @This(){ .size = sprite_sheet.print, .flip = sprite_sheet.flip, .tex = .{
        .x = .{
            .start = x_start / x_divide,
            .end = (x_start + sprite_sheet.tile.width) / x_divide,
        },
        .y = .{
            .start = y_start / y_divide,
            .end = (y_start + sprite_sheet.tile.height) / y_divide,
        },
    } };
}

pub fn positionCoords(self: *const @This(), position: SDL.PointF) Coords {
    const x_other = position.x + self.size.width;
    const y_other = position.y + self.size.height;

    return Coords{ .x = .{
        .start = if (self.flip.x) x_other else position.x,
        .end = if (self.flip.x) position.x else x_other,
    }, .y = .{
        .start = if (self.flip.y) y_other else position.y,
        .end = if (self.flip.y) position.y else y_other,
    } };
}

pub fn vertices(self: *const @This(), to_position: SDL.PointF) [4]SDL.Vertex {
    // Tex
    // 0 1
    // 0 0
    // 1 0
    // 1 1
    // Full Image
    // .position = .{ .x = 0, .y = img_height },
    // .tex_coord = .{ .x = 0, .y = 1 },
    //
    // .position = .{ .x = 0, .y = 0 },
    // .tex_coord = .{ .x = 0, .y = 0 },
    //
    // .position = .{ .x = img_width, .y = 0 },
    // .tex_coord = .{ .x = 1, .y = 0 },
    //
    // .position = .{ .x = img_width, .y = img_height },
    // .tex_coord = .{ .x = 1, .y = 1 },
    //
    // &[_]u32{ 0, 1, 2, 0, 2, 3 },
    // p("Pos {}", .{to_position});
    const position = self.positionCoords(to_position);
    // const position = Coords{};
    return [4]SDL.Vertex{
        .{
            .position = .{ .x = position.x.start, .y = position.y.end },
            .tex_coord = .{ .x = self.tex.x.start, .y = self.tex.y.end },
            .color = full_color,
        },
        .{
            .position = .{ .x = position.x.start, .y = position.y.start },
            .tex_coord = .{ .x = self.tex.x.start, .y = self.tex.y.start },
            .color = full_color,
        },
        .{
            .position = .{ .x = position.x.end, .y = position.y.start },
            .tex_coord = .{ .x = self.tex.x.end, .y = self.tex.y.start },
            .color = full_color,
        },
        .{
            .position = .{ .x = position.x.end, .y = position.y.end },
            .tex_coord = .{ .x = self.tex.x.end, .y = self.tex.y.end },
            .color = full_color,
        },
    };
}
