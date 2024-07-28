const main = @import("../main.zig");
const SDL = main.SDL;
const std = main.std;

const display = main.display;
const devices = main.devices;
const event = main.event;

const p = main.p;

pub var chan_buff: [10]SDL.Event = undefined;
pub var chan: event.Channel(SDL.Event) = undefined;

pub fn pollEvents(window: *display.Window) !void {
    while (SDL.pollEvent()) |ev| {
        switch (ev) {
            .quit, .app_terminating => {
                display.Window.exit = true;
                break;
            },
            .window => {
                switch (ev.window.type) {
                    .resized => {
                        window.setRenderRect();
                        // p("Resized", .{});
                    },
                    else => {},
                }
            },
            else => {},
        }
        chan.put(ev);
    }
}

pub fn loop(eventFunc: fn (SDL.Event) main.Error!void) !void {
    chan.init(chan_buff[0..]);
    while (!display.Window.exit) {
        const ev = chan.get();
        try eventFunc(ev);
    }
}
