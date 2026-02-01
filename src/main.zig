const std = @import("std");

const LicenseTable = @import("license.zig").LicenseTable;
const Output = @import("output.zig").Output;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena;
    const allocator = arena.allocator();

    var output = Output{
        .buffer = undefined,
        .io = init.io,
    };

    const args = try init.minimal.args.toSlice(allocator);
    try handleArgumentCount(args.len, &output);

    const license_identifier = args[1];
    try handleLicenseArgument(license_identifier, &output);

    const license_file: []const u8 = if (args.len == 3) args[2] else "LICENSE.txt";
    try handleLicenseWrite(license_identifier, license_file, &output);
}

fn handleArgumentCount(length: usize, output: *Output) !void {
    if (length != 2 and length != 3) {
        try output.writeStderr(
            \\usage:
            \\  {s} <license>
            \\  {s} <license> [file]
            \\
        , .{"LMake"} ** 2);

        std.process.exit(1);
    }
}

fn handleLicenseArgument(license_identifier: []const u8, output: *Output) !void {
    if (LicenseTable.get(license_identifier) == null) {
        try output.writeStderr("error: unknown license identifier, use following identifiers:\n\n", .{});

        // print available licenses
        for (LicenseTable.keys()) |table_key| {
            if (LicenseTable.get(table_key)) |table_value| {
                try output.writeStderr("* {s}: {s}\n", .{ table_key, table_value.name });
            }
        }

        std.process.exit(1);
    }
}

fn handleLicenseWrite(license_identifier: []const u8, license_file: []const u8, output: *Output) !void {
    if (LicenseTable.get(license_identifier)) |license| {
        try output.writeFile(license_file, license.text);
    }
}
