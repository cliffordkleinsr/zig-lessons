const std = @import("std");

pub const User = struct {
    id: i32,
    name: []const u8,
    email: []const u8,

    pub fn init(id: i32, name: []const u8, email: []const u8) User {
        return User{ .id = id, .name = name, .email = email };
    }

    pub fn print_name(self: User, stdout: *std.Io.Writer) !void {
        try stdout.print("{s}\n", .{self.name});
        try stdout.flush();
    }
};
