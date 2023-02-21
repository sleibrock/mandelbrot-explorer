const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("mandelbrot-explorer", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    const build_opts = b.addOptions();
    // Sets whether to build targeting float-128 or not
    //build_opts.addOption(bool, "f128", false);
    // Sets whether or not gnu/mp is used
    //build_opts.addOption(bool, "gmp", false);

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
