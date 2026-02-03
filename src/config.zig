const std = @import("std");

const license = @import("license.zig");

pub const ConfigError = error{
    ShowHelp,
    ShowInfo,
    ListIdentifiers,
    LicenseUnknown,
    LicenseUndefined,
    OutOfMemory,
    TooManyArguments,
};

pub const Config = struct {
    allocator: std.mem.Allocator,

    stdout: bool,
    file_name: []const u8,
    license_identifier: ?[]const u8,

    license: license.License,

    pub fn init(allocator: std.mem.Allocator) Config {
        return Config{
            .allocator = allocator,

            .stdout = false,
            .file_name = "LICENSE.txt",
            .license_identifier = null,

            .license = undefined,
        };
    }

    pub fn parse(self: *Config, arguments: *const std.process.Args) ConfigError!void {
        var iterator = try arguments.*.iterateAllocator(self.allocator);
        _ = iterator.next(); // skip program name

        defer iterator.deinit();

        while (iterator.next()) |argument| {
            if (std.mem.eql(u8, argument, "--help") or std.mem.eql(u8, argument, "-h")) {
                return ConfigError.ShowHelp;
            } else if (std.mem.eql(u8, argument, "--info") or std.mem.eql(u8, argument, "-i")) {
                return ConfigError.ShowInfo;
            } else if (std.mem.eql(u8, argument, "--list") or std.mem.eql(u8, argument, "-l")) {
                return ConfigError.ListIdentifiers;
            } else if (std.mem.eql(u8, argument, "--stdout") or std.mem.eql(u8, argument, "-s")) {
                self.stdout = true;
            } else if (std.mem.eql(u8, argument, "--file") or std.mem.eql(u8, argument, "-f")) {
                const file_name = iterator.next() orelse return ConfigError.TooManyArguments;
                self.file_name = file_name;
            } else {
                if (self.license_identifier != null) {
                    return ConfigError.TooManyArguments;
                }

                self.license_identifier = argument;
            }
        }

        if (self.license_identifier) |license_identifier| {
            if (license.LicenseTable.get(license_identifier)) |license_value| {
                self.license = license_value;
            } else {
                return ConfigError.LicenseUnknown;
            }
        } else {
            return ConfigError.LicenseUndefined;
        }
    }
};
