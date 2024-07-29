const main = @import("../main.zig");
const std = main.std;

const display = main.display;

const p = main.p;
const nanotime = main.nanotime;
const Timesync = main.Timesync;

var _elapsed_ns: u64 = 0;
var ticks: u64 = 0;
pub var target_tps: u8 = 60;
pub var tps: u32 = 0;

pub fn getTicks() u64 {
    return ticks;
}

pub fn elapsedNs() u64 {
    return _elapsed_ns;
}

pub fn elapsedS() u64 {
    return _elapsed_ns / std.time.ns_per_s;
}

window: *display.Window,

pub fn create(self: *display.Window) @This() {
    return @This(){ .window = self };
}

pub fn loop(self: *@This(), physics_func: fn () main.Error!void) !void {
    _ = self;
    var sync = Timesync.new(std.time.ns_per_s / @as(u64, target_tps));
    var one_second_sync = Timesync.new(std.time.ns_per_s);
    while (!display.Window.exit) {
        _elapsed_ns = nanotime();
        sync.sleepSync(_elapsed_ns);
        ticks += 1;
        if (one_second_sync.sync(_elapsed_ns)) {
            tps = sync.getFrames();
        }

        try physics_func();
    }
}
