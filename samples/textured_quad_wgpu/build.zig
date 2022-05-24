const std = @import("std");
const glfw = @import("../../libs/mach-glfw/build.zig");
const zgpu = @import("../../libs/zgpu/build.zig");
const zmath = @import("../../libs/zmath/build.zig");

const Options = @import("../../build.zig").Options;
const content_dir = "textured_quad_wgpu_content/";

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const exe_options = b.addOptions();
    exe_options.addOption([]const u8, "content_dir", content_dir);

    const exe = b.addExecutable("textured_quad_wgpu", thisDir() ++ "/src/textured_quad_wgpu.zig");
    exe.addOptions("build_options", exe_options);

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = thisDir() ++ "/" ++ content_dir,
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    exe.setBuildMode(options.build_mode);
    exe.setTarget(options.target);

    const zgpu_pkg = zgpu.getPkg(&.{glfw.pkg});

    exe.addPackage(glfw.pkg);
    exe.addPackage(zgpu_pkg);
    exe.addPackage(zmath.pkg);

    zgpu.link(exe, .{
        .glfw_options = .{},
        .gpu_dawn_options = .{ .from_source = options.dawn_from_source },
    });

    return exe;
}

fn thisDir() []const u8 {
    comptime {
        return std.fs.path.dirname(@src().file) orelse ".";
    }
}
