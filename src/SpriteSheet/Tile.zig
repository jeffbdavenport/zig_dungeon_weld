const main = @import("../main.zig");
const SDL = main.SDL;
const SpriteSheet = main.SpriteSheet;

pub const Coord = struct {
    start: f32,
    end: f32,
};

pub const Coords = struct {
    x: Coord,
    y: Coord,
};

sprite_sheet: *const SpriteSheet,
tex: Coords,

// vertices: [4]SDL.Vertex,

const full_color = SDL.Color.rgb(255, 255, 255);

pub fn new(sprite_sheet: *const SpriteSheet, row: u16, col: u16) @This() {
    const x_start = sprite_sheet.toX(col);
    const y_start = sprite_sheet.toY(row);
    const x_divide = sprite_sheet.size.width;
    const y_divide = sprite_sheet.size.height;

    return @This(){ .sprite_sheet = sprite_sheet, .tex = .{
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
    const x_other = position.x + self.sprite_sheet.print.width;
    const y_other = position.y + self.sprite_sheet.print.height;

    return Coords{ .x = .{
        .start = if (self.sprite_sheet.flip.x) x_other else position.x,
        .end = if (self.sprite_sheet.flip.x) position.x else x_other,
    }, .y = .{
        .start = if (self.sprite_sheet.flip.y) y_other else position.y,
        .end = if (self.sprite_sheet.flip.y) position.y else y_other,
    } };
}

pub fn vertices(self: *const @This(), to_position: SDL.PointF) [4]SDL.Vertex {
    const position = self.positionCoords(to_position);
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
