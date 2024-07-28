const main = @import("main.zig");
const Error = main.Error;
const SDL = main.SDL;
const ziglyph = main.ziglyph;
const std = main.std;
const Size = main.Size;
const display = main.display;
const Window = display.Window;
const Renderer = display.Renderer;

const p = main.p;

pub fn run() void {}

pub var server = false;

pub fn init(title: [:0]const u8, size: Size(f32), render_size: Size(f32), comptime game_function: fn (@This()) void, comptime client_function: fn (Window, *Renderer) Error!void, comptime server_function: fn () void) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
    const allocator = arena.allocator();
    var args = try std.process.argsWithAllocator(allocator);

    // Skip exe path
    _ = args.next();
    // if (args.next()) |arg| {
    //     const lower = try ziglyph.toLowerStr(allocator, arg);
    //     defer allocator.free(lower);
    //     if (std.mem.eql(u8, lower, "server")) {
    //         p("Starting {s} multiplayer server...", .{title});
    //         server = true;
    //     }
    // }
    // Done with args
    args.deinit();
    arena.deinit();

    const game = @This().new();
    game_function(game);

    if (server) {
        server_function();
    } else {
        var window = try Window.create(title, size, render_size);
        defer window.cleanup();
        try client_function(window, &window.renderer);
        try window.run();
    }
}

fn new() @This() {
    return @This(){};
}
