const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        // .preferred_optimize_mode = .ReleaseFast, // uncomment for release mode
    });

    const lib = b.addStaticLibrary(.{
        .name = "lib",
        .root_source_file = .{ .path = "neruda.zig" },
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "cli",
        .root_source_file = .{ .path = "cli.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(lib);

    b.installArtifact(lib);

    if (b.option(bool, "enable-demo", "install the demo too") orelse false) {
        b.installArtifact(exe);
    }
}
