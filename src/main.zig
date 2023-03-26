pub const std = @import("std");
pub const print = std.debug.print;
pub const SDL = @import("sdl");
pub const display = @import("display/mod.zig");
pub const devices = @import("devices/mod.zig");
pub const event = @import("event/mod.zig");
pub const world = @import("world/mod.zig");
pub const Timesync = @import("Timesync.zig");
pub const SpriteSheet = @import("SpriteSheet.zig");

pub fn p(comptime fmt: []const u8, args: anytype) void {
    return print(fmt ++ "\n", args);
}

var timer: ?std.time.Timer = null;

pub fn nanotime() u64 {
    const Base = struct {
        var start: u64 = 0;
    };
    if (Base.start == 0) {
        Base.start = getTime();
    }
    return getTime() - Base.start;
}

fn getTime() u64 {
    if (timer == null) {
        timer = std.time.Timer.start() catch unreachable;
    }
    return timer.?.read();
}

pub fn toF(int: anytype) f32 {
    return @intToFloat(f32, int);
}

pub fn toU(float: anytype) u16 {
    return @floatToInt(u16, float);
}

pub fn toU8(float: anytype) u8 {
    return @floatToInt(u8, float);
}

pub fn toI(float: anytype) i16 {
    return @floatToInt(i16, float);
}

pub fn toI8(float: anytype) i8 {
    return @floatToInt(i8, float);
}
