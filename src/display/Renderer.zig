const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const world = main.world;
const SpriteSheet = main.SpriteSheet;

const p = main.p;
const nanotime = main.nanotime;
const Timesync = main.Timesync;

var _elapsed_ns: u64 = 0;
// Set this to change what the render FPS should be
pub var target_fps: u8 = 57;
// Print the actual FPS to the console
pub var print_fps = true;
// current FPS
pub var fps: u32 = 0;

pub fn elapsedNs() u64 {
    return _elapsed_ns;
}

pub fn elapsedS() u64 {
    return _elapsed_ns / std.time.ns_per_s;
}

sdl: SDL.Renderer,

pub fn cleanup(self: *@This()) void {
    self.sdl.destroy();
}

pub fn renderFrame(self: *@This(), texture: *SDL.Texture) !void {
    const sync = struct {
        var render: ?Timesync = null;
        var one_second: ?Timesync = null;
    };
    if (sync.render == null) {
        sync.render = Timesync.new(std.time.ns_per_s / @as(u64, target_fps));
        sync.one_second = Timesync.new(std.time.ns_per_s);
    }

    _elapsed_ns = nanotime();
    sync.render.?.sleepSync(_elapsed_ns);
    if (sync.one_second.?.sync(_elapsed_ns)) {
        fps = sync.render.?.getFrames();
        if (print_fps) {
            p("FPS: {}, TPS: {}, seconds elapsed: {}", .{ fps, world.PhysicsProcess.tps, elapsedS() });
        }
    }

    try self.render(texture);
}

fn render(self: *@This(), texture: *SDL.Texture) !void {
    // try self.sdl.copy(texture, SDL.Rectangle{ .x = 0, .y = 0, .width = 1092, .height = 464 }, null);
    const sprites = try SpriteSheet.new(texture, .{ .width = 40, .height = 40 }, 1, 4, .{});
    const tile = sprites.newTile(8, 4);

    // const color = SDL.Color.rgb(255, 255, 255);
    // _ = color;
    // const vertices = tile.vertices(.{});
    // for (vertices) |v| {
    //     p("{any}", .{v.tex_coord});
    // }
    // p("", .{});

    try self.sdl.drawGeometry(
        texture.*,
        &tile.vertices(.{}),
        // Tex
        // 0 1
        // 0 0
        // 1 0
        // 1 1

        // &[_]SDL.Vertex{
        //     .{
        //         .position = .{ .x = 0, .y = 464 },
        //         .tex_coord = .{ .x = 0, .y = 1 },
        //         .color = color,
        //     },
        //     .{
        //         .position = .{ .x = 0, .y = 0 },
        //         .tex_coord = .{ .x = 0, .y = 0 },
        //         .color = color,
        //     },
        //     .{
        //         .position = .{ .x = 1092, .y = 0 },
        //         .tex_coord = .{ .x = 1, .y = 0 },
        //         .color = color,
        //     },
        //     .{
        //         .position = .{ .x = 1092, .y = 464 },
        //         .tex_coord = .{ .x = 1, .y = 1 },
        //         .color = color,
        //     },
        // },
        // &[_]u32{ 0, 1, 2, 0, 2, 3 },
        &[_]u32{ 0, 1, 2, 0, 2, 3 },
    );

    self.sdl.present();
    try self.sdl.clear();
}
