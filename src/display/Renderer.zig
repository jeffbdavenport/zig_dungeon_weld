const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const world = main.world;
const SpriteSheet = main.SpriteSheet;

const p = main.p;
const toI = main.toI;
const nanotime = main.nanotime;
const Timesync = main.Timesync;
const Size = main.Size;

const render_size = @import("root").render_size;
const tile_size = @import("root").tile_size;
const cols = render_size.width / tile_size;
const rows = render_size.height / tile_size;
// const vert_size = @floatToInt(usize, cols * rows) + 1;
// const b_vertices: [vert_size]SDL.Vertex = undefined;
// const b_indices: [vert_size * 4]u32 = undefined;

var _elapsed_ns: u64 = 0;
// Set this to change what the render FPS should be
pub var target_fps: u8 = 57;
// Print the actual FPS to the console
pub var print_fps = true;
// current FPS
pub var fps: u32 = 0;
var frames: u16 = 0;

pub fn elapsedNs() u64 {
    return _elapsed_ns;
}

pub fn elapsedS() u64 {
    return _elapsed_ns / std.time.ns_per_s;
}

var arena: std.heap.ArenaAllocator = undefined;
var geometry: display.Geometry = undefined;

sdl: SDL.Renderer,
draw: bool = false,
size: Size(f32),
background: ?display.Background = null,
rect: SDL.Rectangle,
texture: SDL.Texture,

pub fn cleanup(self: *@This()) void {
    self.sdl.destroy();
}

pub fn spawn(self: *@This(), window: *display.Window) !void {
    const thread = try std.Thread.spawn(.{}, renderLoop, .{ self, window });
    thread.detach();
}

pub fn renderLoop(self: *@This(), window: *display.Window) !void {
    _ = window;
    var render_sync = Timesync.new(std.time.ns_per_s / @as(u64, target_fps));
    var one_second = Timesync.new(std.time.ns_per_s);

    while (!display.Window.exit) {
        _elapsed_ns = nanotime();
        render_sync.sleepSync(_elapsed_ns);
        if (!self.draw and !display.Window.exit) {
            arena.deinit();
            geometry.deinit();
            arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
            geometry = display.Geometry.new(&arena, &display.Window.texture);

            try self.render();

            self.draw = true;
        }
        if (one_second.sync(_elapsed_ns)) {
            fps = frames;
            frames = 0;
            if (print_fps) {
                p("FPS: {}, TPS: {}, seconds elapsed: {}", .{ fps, world.PhysicsProcess.tps, elapsedS() });
            }
        }
    }
}
// try self.sdl.copy(texture, SDL.Rectangle{ .x = 0, .y = 0, .width = 1092, .height = 464 }, null);

pub fn drawFrame(self: *@This()) !void {
    if (!self.draw) return;
    self.draw = false;

    // Copy previous geometry target texture
    try self.sdl.drawGeometry(geometry.texture.*, geometry.vertices.items, geometry.indices.items);

    // Begin rendereing to screen buffer
    try self.sdl.setTarget(null);

    if (self.background) |background| {
        try self.sdl.copy(&background.texture, self.rect, null);
    }
    try self.sdl.copy(&self.texture, self.rect, null);

    self.sdl.present();
    // Clear our frame buffer
    try self.sdl.clear();
    // Set target to texture for next frame render() logic
    try self.sdl.setTarget(self.texture);
    // Clear our texture for next frame
    try self.sdl.clear();
    frames += 1;
}

pub fn render(self: *@This()) !void {
    _ = self;
    const Static = struct {
        var position: SDL.PointF = .{};
    };
    const sprites = try SpriteSheet.new(geometry.texture, .{ .width = 40, .height = 40 }, 1, 1, .{});

    const tile = sprites.newTile(8, 4);

    Static.position.x += 1;
    try geometry.addTile(tile, Static.position);
}
