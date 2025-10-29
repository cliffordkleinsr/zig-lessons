const std = @import("std");

var stdout_buffer: [0x30]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

fn add_and_increment(a: u8, b: u8) u8 {
    var c = a + b;
    c += 1;
    return c;
}

pub fn main() !void {
    var n = add_and_increment(2, 3);
    n = add_and_increment(n, n);

    try stdout.print("Result: {d}!\n", .{n});
    try stdout.flush();
}
