const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "day01",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/day01.zig"),
            .target = b.graph.host,
        }),
    });

    b.installArtifact(exe);
}
