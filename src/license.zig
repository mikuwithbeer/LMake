const std = @import("std");

pub const License = struct {
    name: []const u8,
    text: []const u8,
};

pub const LicenseTable = std.StaticStringMap(License).initComptime(.{
    .{ "agpl-3.0", License{
        .name = "GNU Affero General Public License v3.0",
        .text = @embedFile("./license/AGPL-3.0.txt"),
    } },
    .{ "apache-2.0", License{
        .name = "Apache License, Version 2.0",
        .text = @embedFile("./license/APACHE-2.0.txt"),
    } },
    .{ "bsd-2-clause", License{
        .name = "BSD 2-Clause \"Simplified\" License",
        .text = @embedFile("./license/BSD-2-CLAUSE.txt"),
    } },
    .{ "bsd-3-clause", License{
        .name = "BSD 3-Clause \"New\" or \"Revised\" License",
        .text = @embedFile("./license/BSD-3-CLAUSE.txt"),
    } },
    .{ "bsl-1.0", License{
        .name = "Boost Software License, Version 1.0",
        .text = @embedFile("./license/BSL-1.0.txt"),
    } },
    .{ "cc0-1.0", License{
        .name = "Creative Commons Zero v1.0 Universal",
        .text = @embedFile("./license/CC0-1.0.txt"),
    } },
    .{ "gpl-3.0", License{
        .name = "GNU General Public License v3.0",
        .text = @embedFile("./license/GPL-3.0.txt"),
    } },
    .{ "lgpl-3.0", License{
        .name = "GNU Lesser General Public License v3.0",
        .text = @embedFile("./license/LGPL-3.0.txt"),
    } },
    .{ "mit", License{
        .name = "MIT License",
        .text = @embedFile("./license/MIT.txt"),
    } },
    .{ "mpl-2.0", License{
        .name = "Mozilla Public License 2.0",
        .text = @embedFile("./license/MPL-2.0.txt"),
    } },
    .{ "unlicense", License{
        .name = "The Unlicense",
        .text = @embedFile("./license/UNLICENSE.txt"),
    } },
});
