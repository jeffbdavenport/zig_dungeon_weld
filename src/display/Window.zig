const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const event = main.event;
const devices = main.devices;
const display = main.display;
const Renderer = display.Renderer;
const world = main.world;

const p = main.p;
const nanotime = main.nanotime;
const Timesync = main.Timesync;
const Size = main.Size;
const toUSize = main.toUSize;
const toF = main.toF;
const toI = main.toI;
// pub const io_mode = .evented;

pub var exit = false;
pub var texture: SDL.Texture = undefined;

sdl: SDL.Window,
renderer: Renderer,

pub fn run(self: *@This()) !void {
    devices.initKeyboard(self);
    try self.renderer.spawn(self);
    var physics = world.PhysicsProcess.create(self);
    try physics.spawn();

    while (!exit) {
        try devices.Keyboard.pollEvents();
        try self.renderer.drawFrame();
        std.time.sleep(50 * std.time.ns_per_us);
    }
}

pub fn cleanup(self: *@This()) void {
    self.renderer.cleanup();
    self.sdl.destroy();
    SDL.image.quit();
    SDL.quit();
}

pub fn create(title: [:0]const u8, size: Size(f32), render_size: Size(f32)) !@This() {
    try SDL.init(.{
        .video = true,
        .audio = true,
    });
    try SDL.image.init(.{ .png = true });
    var sdl = try SDL.createWindow(
        title,
        .{ .centered = {} },
        .{ .centered = {} },
        toUSize(size.width),
        toUSize(size.height),
        .{ .vis = .shown, .resizable = true },
    );

    const render_rect = .{ .x = 0, .y = 0, .width = toI(size.width), .height = toI(size.height) };
    var window = @This(){
        .sdl = sdl,
        .renderer = try createRenderer(&sdl, render_size, render_rect),
    };
    window.setRenderRect();

    return window;
}

fn createRenderer(window: *SDL.Window, size: Size(f32), rect: SDL.Rectangle) !display.Renderer {
    const sdl = try SDL.createRenderer(window, null, .{ .accelerated = true });
    var r_texture = try SDL.createTexture(sdl, SDL.PixelFormatEnum.rgba8888, SDL.Texture.Access.target, toUSize(size.width), toUSize(size.height));
    try r_texture.setBlendMode(SDL.BlendMode.blend);
    try sdl.setTarget(r_texture);
    texture = r_texture;

    return display.Renderer{
        .sdl = sdl,
        .rect = rect,
        .size = size,
        .texture = r_texture,
    };
}

pub fn setRenderRect(self: *@This()) void {
    self.renderer.rect = self.getRenderRect();
}

pub fn getRenderRect(self: *@This()) SDL.Rectangle {
    const size = self.sdl.getWindowSize();

    const ratio = toF(size.width) / toF(size.height);
    const render_ratio = self.renderer.size.width / self.renderer.size.height;
    var x: c_int = 0;
    var y: c_int = 0;

    const height = if (ratio < render_ratio)
        toI(toF(size.width) / render_ratio)
    else
        size.height;

    const width = if (ratio < render_ratio)
        size.width
    else
        toI(toF(size.height) * render_ratio);

    if (ratio > render_ratio) {
        x = toI(toF(size.width - width) / 2);
    } else {
        y = toI(toF(size.height - height) / 2);
    }

    return SDL.Rectangle{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

// var buf: [1]u8 = undefined;
// var fba = std.heap.FixedBufferAllocator.init(&buf);
// const allocator = fba.threadSafeAllocator();
// _ = try allocator.alloc(u8, 1);
// self.exit_channel.init(&buf);
// defer self.exit_channel.deinit();

// var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
// const allocator2 = arena.allocator();
// const ptr = try allocator2.create(devices.Keyboard);
// _ = try allocator2.alloc(devices.Keyboard, 1);
// ptr.* = keyboard;
