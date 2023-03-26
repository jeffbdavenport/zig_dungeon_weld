const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;

pub const pkgs = struct {
    pub const sdl = Pkg{
        .name = "sdl",
        .source = FileSource{
            .path = "libs/SDL.zig/src/sdl.zig",
        },
    };

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        artifact.addPackage(pkgs.sdl);
    }
};

pub const exports = struct {
    pub const dungeon_weld = Pkg{
        .name = "dungeon_weld",
        .source = FileSource{ .path = "src/main.zig" },
        .dependencies = &[_]Pkg{
            pkgs.sdl,
        },
    };
};
