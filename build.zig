const std = @import("std");
const pkgs = @import("deps.zig").pkgs;
// const deps = @import("./deps.zig");
// const Sdk = @import(".zigmod/deps/git/github.com/MasterQ32/SDL.zig/Sdk.zig");

pub fn build(b: *std.build.Builder) void {
    // const sdk = Sdk.init(b, null);
    // const target = b.standardTargetOptions(.{});
    // const sdl_linkage = b.option(std.Build.LibExeObjStep.Linkage, "link", "Defines how to link SDL2 when building with mingw32") orelse .dynamic;

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    // const target = b.standardTargetOptions(.{});
    const lib = b.addStaticLibrary("dungeon_weld", "src/main.zig");
    // const lib = b.addExecutable("dungeon_weld", "src/main.zig");
    lib.setBuildMode(mode);

    lib.addIncludePath("/usr/include/x86_64-linux-gnu");
    lib.addIncludePath("/usr/include");
    lib.addLibraryPath("/usr/lib/x86_64-linux-gnu");
    lib.addLibraryPath("/usr/local/lib");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2.a");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2main.a");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2_image.a");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2_ttf.a");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2_mixer.a");
    lib.addObjectFile("/usr/lib/x86_64-linux-gnu/libSDL2_net.a");
    // lib.linkSystemLibrary("SDL2");
    // lib.linkSystemLibrary("SDL2_image");
    // lib.linkSystemLibrary("SDL2main");
    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("png16");
    // lib.linkSystemLibrary("jpeg");
    lib.linkSystemLibrary("SDL2");
    lib.linkSystemLibrary("asound");
    lib.linkSystemLibrary("m");
    lib.linkSystemLibrary("pulse");
    lib.linkSystemLibrary("Xss");
    lib.linkSystemLibrary("Xxf86vm");
    lib.linkSystemLibrary("drm");
    lib.linkSystemLibrary("gbm");
    lib.linkSystemLibrary("Xi");
    lib.linkSystemLibrary("Xrandr");
    lib.linkSystemLibrary("Xfixes");
    lib.linkSystemLibrary("Xinerama");
    lib.linkSystemLibrary("Xcursor");
    lib.linkSystemLibrary("xkbcommon");
    lib.linkSystemLibrary("wayland-egl");
    lib.linkSystemLibrary("tiff");
    lib.linkSystemLibrary("webp");
    lib.linkSystemLibrary("zstd");
    lib.linkSystemLibrary("lzma");
    lib.linkSystemLibrary("jbig");
    lib.linkSystemLibrary("jpeg");
    lib.linkSystemLibrary("deflate");
    lib.linkSystemLibrary("z");
    lib.linkSystemLibrary("Xext");
    lib.linkSystemLibrary("xcb");
    lib.linkSystemLibrary("Xau");
    lib.linkSystemLibrary("Xdmcp");
    lib.linkSystemLibrary("wayland-cursor");
    lib.linkSystemLibrary("decor-0");
    lib.linkSystemLibrary("Xrender");

    pkgs.addAllTo(lib);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
