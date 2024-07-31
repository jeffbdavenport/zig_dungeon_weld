const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const world = main.world;
const event = main.event;
const SpriteSheet = main.SpriteSheet;

const p = main.p;
const toI = main.toI;
const positionAdd = main.positionAdd;
const positionSub = main.positionSub;
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
pub var target_fps: u8 = 144;
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

pub var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);

geometry: display.Geometry = undefined,
prev_geometry: display.Geometry = undefined,
sdl: SDL.Renderer,
draw: bool = false,
size: Size(f32),
background: ?display.Background = null,
rect: SDL.Rectangle,
texture: SDL.Texture,
prep: bool = true,
// render_func: fn () main.Error!void = render,

pub fn cleanup(self: *@This()) void {
    arena.deinit();
    self.sdl.destroy();
}

// Main loop for handling when non-printing render logic should happen (Should not need to change)
pub fn renderLoop(self: *@This(), renderPrepFunc: fn () main.Error!world.Node.NodeType) !void {
    var render_sync = Timesync.new(std.time.ns_per_s / @as(u64, target_fps));
    var one_second = Timesync.new(std.time.ns_per_s);

    self.geometry = display.Geometry.new(&arena, &display.Window.texture);

    while (!display.Window.exit) {
        _elapsed_ns = nanotime();
        render_sync.sleepSync(_elapsed_ns);
        try self.renderPrep(renderPrepFunc);
        if (one_second.sync(_elapsed_ns)) {
            fps = frames;
            frames = 0;
            if (print_fps) {
                p("FPS: {}, TPS: {}, seconds elapsed: {}", .{ fps, event.PhysicsProcess.tps, elapsedS() });
            }
        }
    }
}

pub fn renderPrep(self: *@This(), renderPrepFunc: fn () main.Error!world.Node.NodeType) !void {
    if (!self.draw and !display.Window.exit) {
        // arena.deinit();
        // arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
        // self.geometry.deinit();

        // if (self.prep) {
        //     self.prev_geometry = self.geometry

        //     self.prep = false;
        // }
        //try self.render();
        try self.geometry.reset();
        const root = try renderPrepFunc();
        try self.processTree(root);
        self.draw = self.geometry.hasUpdated();

        // arena.deinit();
        // self.prev_geometry.deinit();
        // self.prev_geometry = self.geometry;
    }
}

pub fn processTree(self: *@This(), node: world.Node.NodeType) !void {
    switch (node) {
        .node => |n| for (n.nodes.items) |item| {
            try self.processTree(item);
        },
        .sprite => |s| {
            for (s.node.nodes.items) |item| {
                try self.processTree(item);
            }
            if (world.Camera.active) |camera| {
                try self.geometry.addTile(s.tile, positionAdd(camera.topLeft(), positionSub(s.node.globalPosition(), camera.node.globalPosition())));
            } else {
                try self.geometry.addTile(s.tile, s.node.position);
            }
        },
        .camera => |c| if (world.Camera.active == null) {
            for (c.node.nodes.items) |item| {
                try self.processTree(item);
            }
            world.Camera.active = c;
        },
    }
}

// try self.sdl.copy(texture, SDL.Rectangle{ .x = 0, .y = 0, .width = 1092, .height = 464 }, null);

// Main loop for actual drawing (Should not need to change)
pub fn drawFrame(self: *@This()) !void {
    if (!self.draw) return;
    self.draw = false;

    // Copy current Geometry to texture to maintain render_size
    try self.sdl.drawGeometry(self.geometry.texture.*, self.geometry.vertices.items, self.geometry.indices.items);

    // Begin rendereing to screen buffer
    try self.sdl.setTarget(null);

    if (self.background) |background| {
        try self.sdl.copy(&background.texture, self.rect, null);
    }
    // Copy texture created from Geometry to screen beffer with window size
    try self.sdl.copy(&self.texture, self.rect, null);

    self.sdl.present();
    // Clear the screen buffer
    try self.sdl.clear();
    // Set target to texture for next frame render() logic
    // We want to print to a texture to maintain render_size
    try self.sdl.setTarget(self.texture);
    // Clear our texture created from Geometry for next frame
    try self.sdl.clear();
    frames += 1;
}

fn render() !void {}
