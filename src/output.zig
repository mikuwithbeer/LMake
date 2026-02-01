const std = @import("std");

const BufferSize = 1024;

pub const OutputError = error{
    WriteFailed,
    FileCreateFailed,
};

pub const Output = struct {
    buffer: [BufferSize]u8,
    io: std.Io,

    pub fn writeStdout(self: *Output, comptime content: []const u8, args: anytype) OutputError!void {
        var stdout_writer = std.Io.File.stdout().writer(self.io, &self.buffer);
        var stdout_interface = &stdout_writer.interface;

        stdout_interface.print(content, args) catch return OutputError.WriteFailed;
        stdout_interface.flush() catch return OutputError.WriteFailed;
    }

    pub fn writeStderr(self: *Output, comptime content: []const u8, args: anytype) OutputError!void {
        var stderr_writer = std.Io.File.stderr().writer(self.io, &self.buffer);
        var stderr_interface = &stderr_writer.interface;

        stderr_interface.print(content, args) catch return OutputError.WriteFailed;
        stderr_interface.flush() catch return OutputError.WriteFailed;
    }

    pub fn writeFile(self: *Output, path: []const u8, content: []const u8) OutputError!void {
        const file = std.Io.Dir.cwd().createFile(self.io, path, .{ .truncate = true }) catch {
            return OutputError.FileCreateFailed;
        };
        defer file.close(self.io);

        var file_writer = file.writer(self.io, &self.buffer);
        var file_interface = &file_writer.interface;

        file_interface.writeAll(content) catch return OutputError.WriteFailed;
        file_interface.flush() catch return OutputError.WriteFailed;
    }
};
