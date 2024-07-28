const std = @import("std");
//const pkgs = @import("deps.zig").pkgs;
// const deps = @import("./deps.zig");
// const Sdk = @import(".zigmod/deps/git/github.com/MasterQ32/SDL.zig/Sdk.zig");

//zig11 pub fn build(b: *std.build.Builder) void {
pub fn build(b: *std.Build) void {
    // const sdk = Sdk.init(b, null);
    // const target = b.standardTargetOptions(.{});
    // const sdl_linkage = b.option(std.Build.LibExeObjStep.Linkage, "link", "Defines how to link SDL2 when building with mingw32") orelse .dynamic;

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    //const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const target = b.standardTargetOptions(.{});
    const lib = b.addStaticLibrary(.{ .name = "dungeon_weld", .root_source_file = b.path("src/main.zig"), .optimize = optimize, .target = target });
    // const lib = b.addExecutable("dungeon_weld", "src/main.zig");
    //lib.setBuildMode(target);
    // lib.addIncludePath(b.path("/usr/include/x86_64-linux-gnu"));
    // lib.addIncludePath(b.path("/usr/include"));
    // lib.addLibraryPath(b.path("/usr/lib/x86_64-linux-gnu"));
    // lib.addLibraryPath(b.path("/usr/local/lib"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2.a"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2main.a"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2_image.a"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2_ttf.a"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2_mixer.a"));
    // lib.addObjectFile(b.path("/usr/lib/x86_64-linux-gnu/libSDL2_net.a"));
    // lib.linkSystemLibrary("SDL2");
    // lib.linkSystemLibrary("SDL2_image");
    // lib.linkSystemLibrary("SDL2main");

    lib.linkSystemLibrary("SDL2");
    lib.linkSystemLibrary("SDL2_image");
    lib.linkSystemLibrary("SDL2main");

    lib.linkSystemLibrary("c");
    // lib.linkSystemLibrary("png16");
    // // lib.linkSystemLibrary("jpeg");
    // lib.linkSystemLibrary("SDL2");
    // lib.linkSystemLibrary("asound");
    // lib.linkSystemLibrary("m");
    // lib.linkSystemLibrary("pulse");
    // lib.linkSystemLibrary("Xss");
    // lib.linkSystemLibrary("Xxf86vm");
    // lib.linkSystemLibrary("drm");
    // lib.linkSystemLibrary("gbm");
    // lib.linkSystemLibrary("Xi");
    // lib.linkSystemLibrary("Xrandr");
    // lib.linkSystemLibrary("Xfixes");
    // lib.linkSystemLibrary("Xinerama");
    // lib.linkSystemLibrary("Xcursor");
    // lib.linkSystemLibrary("xkbcommon");
    // lib.linkSystemLibrary("wayland-egl");
    // lib.linkSystemLibrary("tiff");
    // lib.linkSystemLibrary("webp");
    // lib.linkSystemLibrary("zstd");
    // lib.linkSystemLibrary("lzma");
    // lib.linkSystemLibrary("jbig");
    // lib.linkSystemLibrary("jpeg");
    // lib.linkSystemLibrary("deflate");
    // lib.linkSystemLibrary("z");
    // lib.linkSystemLibrary("Xext");
    // lib.linkSystemLibrary("xcb");
    // lib.linkSystemLibrary("Xau");
    // lib.linkSystemLibrary("Xdmcp");
    // lib.linkSystemLibrary("wayland-cursor");
    // lib.linkSystemLibrary("decor-0");
    // lib.linkSystemLibrary("Xrender");

    var dungeonweld = b.addModule("dungeon_weld", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    //pkgs.addAllTo(lib);
    //lib.install();

    // load the "zig-speak" dependency from build.zig.zon
    const package = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    // load the "speak" module from the package
    const sdl_module = package.module("SDL");
    dungeonweld.addImport("SDL", sdl_module);
    // make the module usable as @import("speak")
    addDependencies(b, lib, sdl_module);

    b.installArtifact(lib);

    const run_cmd = b.addRunArtifact(lib);

    // const main_tests = b.addTest("src/main.zig");
    // main_tests.setBuildMode(target);

    // const test_step = b.step("test", "Run library tests");
    // test_step.dependOn(&main_tests.step);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    addDependencies(b, lib_unit_tests, sdl_module);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    addDependencies(b, exe_unit_tests, sdl_module);
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

fn addDependencies(b: *std.Build, compile: *std.Build.Step.Compile, dep_module: *std.Build.Module) void {
    compile.addIncludePath(b.path("../../../Users/Jeff/include"));
    compile.addLibraryPath(b.path("../../../Users/Jeff/lib"));
    compile.linkLibC();
    compile.root_module.addImport("SDL", dep_module);
}
