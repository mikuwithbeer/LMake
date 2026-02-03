const std = @import("std");

const config = @import("config.zig");
const license = @import("license.zig");
const output = @import("output.zig");

const App = struct {
    name: []const u8 = "LMake",
    description: []const u8 = "Tiny and portable software license generator",
    source: []const u8 = "https://github.com/mikuwithbeer/LMake",
    version: []const u8 = "0.2.0",
};

pub fn main(init: std.process.Init) !void {
    const application = App{};

    const arena = init.arena;
    const allocator = arena.allocator();

    var writer = output.Output.init(init.io);
    writer.prepare();

    var configuration = config.Config.init(allocator);
    configuration.parse(&init.minimal.args) catch |err| {
        switch (err) {
            config.ConfigError.ShowHelp => {
                try writer.writeStdout(
                    \\usage:
                    \\* {s} <license>
                    \\* {s} <license> -f [file]
                    \\
                    \\options:
                    \\  -h, --help        Show this help message
                    \\  -i, --info        Show application information
                    \\  -l, --list        List available license identifiers
                    \\  -s, --stdout      Write license to standard output
                    \\  -f, --file FILE   Specify output file (default: {s})
                    \\
                , .{ application.name, application.name, configuration.file_name });
                std.process.exit(0);
            },
            config.ConfigError.ShowInfo => {
                try writer.writeStdout(
                    \\{s} - {s}
                    \\* version: {s}
                    \\* source: {s}
                    \\
                , .{ application.name, application.description, application.version, application.source });
                std.process.exit(0);
            },
            config.ConfigError.ListIdentifiers => {
                try writer.writeStdout("available license identifiers:\n\n", .{});

                for (license.LicenseTable.keys()) |table_key| {
                    if (license.LicenseTable.get(table_key)) |table_value| {
                        try writer.writeStdout("* {s}: {s}\n", .{ table_key, table_value.name });
                    }
                }

                std.process.exit(0);
            },
            config.ConfigError.LicenseUnknown => {
                try writer.writeStderr("error: unknown license identifier\n", .{});
                std.process.exit(1);
            },
            config.ConfigError.LicenseUndefined => {
                try writer.writeStderr("error: no license identifier provided\n", .{});
                std.process.exit(1);
            },
            config.ConfigError.OutOfMemory => {
                try writer.writeStderr("error: out of memory\n", .{});
                std.process.exit(1);
            },
            config.ConfigError.TooManyArguments => {
                try writer.writeStderr("error: too many arguments provided\n", .{});
                std.process.exit(1);
            },
        }
    };

    if (configuration.stdout) {
        try writer.writeStdout("{s}", .{configuration.license.text});
    } else {
        try writer.writeFile(configuration.file_name, configuration.license.text);
        try writer.writeStdout(
            \\successfully wrote license:
            \\* file: {s}
            \\* license: {s}
            \\
            \\keep in mind license templates may require additional information.
            \\
        , .{ configuration.file_name, configuration.license_identifier.? });
    }
}
