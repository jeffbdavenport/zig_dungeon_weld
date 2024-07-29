const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;
const SpriteSheet = main.SpriteSheet;

vertices: std.ArrayList(SDL.Vertex), // .init(allocator),
indices: std.ArrayList(u32),
texture: *SDL.Texture,
updated: bool = false,

pub const Error = error{TileNotInTexture};

pub fn eq(self: @This(), other: @This()) bool {
    for (self.vertices.items, 0..) |item, i| {
        const o_item = other.vertices.items[i];
        if (item.position.x != o_item.position.x or
            item.position.y != o_item.position.y or
            item.tex_coord.x != o_item.tex_coord.x or
            item.tex_coord.y != o_item.tex_coord.y)
        {
            return false;
        }
    }
    return std.mem.eql(u32, self.indices.items, other.indices.items);
}

pub fn reset(self: *@This()) !void {
    try self.vertices.resize(0);
    try self.indices.resize(0);
}

pub fn hasUpdated(self: *@This()) bool {
    const u = self.updated;
    self.updated = false;
    return u;
}

pub fn new(arena: *std.heap.ArenaAllocator, texture: *SDL.Texture) @This() {
    const allocator = arena.allocator();

    return @This(){
        .vertices = std.ArrayList(SDL.Vertex).init(allocator),
        .indices = std.ArrayList(u32).init(allocator),
        .texture = texture,
    };
}

pub fn addTile(self: *@This(), tile: SpriteSheet.Tile, position: SDL.PointF) !void {
    if (tile.sprite_sheet.texture != self.texture)
        return Error.TileNotInTexture;

    const add_index: u32 = @as(u32, @intCast(self.vertices.items.len));
    try self.vertices.appendSlice(&tile.vertices(position));
    try self.indices.appendSlice(&.{ 0 + add_index, 1 + add_index, 2 + add_index, 0 + add_index, 2 + add_index, 3 + add_index });
    self.updated = true;
}

pub fn deinit(self: *@This()) void {
    self.vertices.deinit();
    self.indices.deinit();
}

pub fn import(self: *@This(), other: @This()) !void {
    const add_index: u32 = @as(u32, @intCast(self.vertices.items.len));

    try self.vertices.appendSlice(other.vertices.items);

    if (add_index == 0) {
        try self.indices.appendSlice(other.indices.items);
    } else {
        for (other.indices.items) |i| {
            // Scoot new indices over to the last vertex index
            try self.indices.append(i + add_index);
        }
    }
}
