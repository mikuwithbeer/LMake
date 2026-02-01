const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buffer: [1024]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(io, &buffer);
    var stdout_writer = &stdout.interface;

    try stdout_writer.print("Hello, World!\n", .{});
    try stdout_writer.flush();
}
