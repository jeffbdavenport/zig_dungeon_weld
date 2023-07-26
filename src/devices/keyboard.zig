const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const devices = main.devices;

const p = main.p;

pub var Keyboard: Impl = undefined;

pub fn initKeyboard(window: *display.Window) void {
    Keyboard = Impl{ .window = window };
}

const Impl = struct {
    window: *display.Window,

    pub fn pollEvents(self: *Impl) !void {
        while (SDL.pollEvent()) |ev| {
            switch (ev) {
                .quit, .app_terminating => {
                    display.Window.exit = true;
                    break;
                },
                .window => {
                    switch (ev.window.type) {
                        .resized => {
                            self.window.setRenderRect();
                            // p("Resized", .{});
                        },
                        else => {},
                    }
                },
                .key_down => |key| {
                    switch (key.scancode) {
                        .q => {
                            display.Window.exit = true;
                            break;
                        },
                        else => p("Pressed key: {}", .{key.scancode}),
                    }
                },
                else => {},
            }
        }
    }
};
