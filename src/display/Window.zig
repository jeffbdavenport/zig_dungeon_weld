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
// pub const io_mode = .evented;

sdl: SDL.Window,
renderer: Renderer,
exit: bool = false,

pub fn run(self: *@This(), texture: *SDL.Texture) !void {
    devices.initKeyboard(self);
    var physics = world.PhysicsProcess.create(self);
    try physics.spawn();

    while (!self.exit) {
        try devices.Keyboard.pollEvents();
        try self.renderer.renderFrame(texture);
    }
}

pub fn cleanup(self: *@This()) void {
    self.renderer.cleanup();
    self.sdl.destroy();
    SDL.image.quit();
    SDL.quit();
}

pub fn create(title: [:0]const u8, width: usize, height: usize) !@This() {
    try SDL.init(.{
        .video = true,
        .audio = true,
    });
    try SDL.image.init(.{ .png = true });
    var sdl = try SDL.createWindow(
        title,
        .{ .centered = {} },
        .{ .centered = {} },
        width,
        height,
        .{ .vis = .shown },
    );
    var renderer = try createRenderer(&sdl);
    return @This(){
        .sdl = sdl,
        .renderer = renderer,
    };
}

fn createRenderer(window: *SDL.Window) !Renderer {
    // const sdl = try SDL.createRenderer(window, null, .{ .accelerated = true });
    // try sdl.setColorRGB(0xF7, 0xA4, 0x1D);
    return Renderer{
        .sdl = try SDL.createRenderer(window, null, .{ .accelerated = true }),
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
