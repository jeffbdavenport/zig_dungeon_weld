pub const std = @import("std");
pub const SDL = @import("SDL");
pub const ziglyph = @import("ziglyph");
pub const print = std.debug.print;
pub const Game = @import("Game.zig");
pub const display = @import("display/mod.zig");
pub const devices = @import("devices/mod.zig");
pub const world = @import("world/mod.zig");
pub const event = @import("event/mod.zig");
pub const Timesync = @import("Timesync.zig");
pub const SpriteSheet = @import("SpriteSheet.zig");

// pub const imgui = @import("imgui");
// pub const c = @cImport({
// @cInclude("cimgui.h");
// @cInclude("cimgui_impl.h");
// });
pub const c = @cImport({
    // C Imgui
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", {});
    @cDefine("CIMGUI_USE_OPENGL3", {});
    @cDefine("CIMGUI_USE_GLFW", {});
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("cimgui.h");
    @cInclude("cimgui_impl.h");

    // @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("GLFW/glfw3.h");
    // @cInclude("vulkan/vulkan.h");
    @cInclude("GL/gl.h");
});

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
    return @as(f32, @floatFromInt(int));
}

pub fn toU(float: anytype) u16 {
    return @as(u16, @intFromFloat(float));
}
pub fn toUSize(float: anytype) usize {
    return @as(usize, @intFromFloat(float));
}

pub fn toU8(float: anytype) u8 {
    return @as(u8, @intFromFloat(float));
}

pub fn toI(float: anytype) i16 {
    return @as(i16, @intFromFloat(float));
}

pub fn toI8(float: anytype) i8 {
    return @as(i8, @intFromFloat(float));
}

pub fn positionAdd(first: SDL.PointF, second: SDL.PointF) SDL.PointF {
    return SDL.PointF{ .x = first.x + second.x, .y = first.y + second.y };
}

pub fn positionSub(first: SDL.PointF, second: SDL.PointF) SDL.PointF {
    return SDL.PointF{ .x = first.x - second.x, .y = first.y - second.y };
}

pub fn Size(comptime T: type) type {
    return struct {
        width: T,
        height: T,
    };
}

pub const Error = SDL.Error || display.Geometry.Error || std.mem.Allocator.Error || std.Thread.SpawnError;
