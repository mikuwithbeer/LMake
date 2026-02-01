const std = @import("std");

const BufferSize = 1024;

pub const OutputError = error{
    WriteFailed,
    FileCreateFailed,
};

pub const Output = struct {
    io: std.Io,
    writer_buffer: [BufferSize]u8,

    stdout_writer: std.Io.File.Writer,
    stdout_interface: *std.Io.Writer,

    stderr_writer: std.Io.File.Writer,
    stderr_interface: *std.Io.Writer,

    pub fn init(io: std.Io) Output {
        return Output{
            .io = io,
            .writer_buffer = undefined,

            .stdout_writer = undefined,
            .stdout_interface = undefined,

            .stderr_writer = undefined,
            .stderr_interface = undefined,
        };
    }

    pub fn prepare(self: *Output) void {
        self.stdout_writer = std.Io.File.stdout().writer(self.io, &self.writer_buffer);
        self.stdout_interface = &self.stdout_writer.interface;

        self.stderr_writer = std.Io.File.stderr().writer(self.io, &self.writer_buffer);
        self.stderr_interface = &self.stderr_writer.interface;
    }

    pub fn writeStdout(self: *Output, comptime content: []const u8, args: anytype) OutputError!void {
        self.stdout_interface.print(content, args) catch return OutputError.WriteFailed;
        self.stdout_interface.flush() catch return OutputError.WriteFailed;
    }

    pub fn writeStderr(self: *Output, comptime content: []const u8, args: anytype) OutputError!void {
        self.stderr_interface.print(content, args) catch return OutputError.WriteFailed;
        self.stderr_interface.flush() catch return OutputError.WriteFailed;
    }

    pub fn writeFile(self: *Output, path: []const u8, content: []const u8) OutputError!void {
        const file = std.Io.Dir.cwd().createFile(self.io, path, .{
            .truncate = true,
            .lock = .exclusive,
        }) catch return OutputError.FileCreateFailed;
        defer file.close(self.io);

        var file_writer = file.writer(self.io, &self.writer_buffer);
        var file_interface = &file_writer.interface;

        file_interface.writeAll(content) catch return OutputError.WriteFailed;
        file_interface.flush() catch return OutputError.WriteFailed;
    }
};
