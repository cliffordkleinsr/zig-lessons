const std = @import("std");
/// Helper: read a file into heap-allocated memory
pub fn read_file(allocater: std.mem.Allocator, path: []const u8) ![]u8 {
    // Temporary stack buffer for the file reader
    var read_buffer: [1024]u8 = undefined;

    // Allocate heap memory for up to 1024 bytes of file contents
    var file_buffer = try allocater.alloc(u8, 1024);

    // Initialize memory to zero (safety: avoids garbage data)
    @memset(file_buffer[0..], 0);

    // Open the file from the current working directory
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    // Create a reader using our temporary stack buffer
    var reader = file.reader(read_buffer[0..]);

    // Read up to 1024 bytes into file_buffer
    const n_bytes = try reader.read(file_buffer[0..]);

    // Return a slice representing only the bytes actually read
    return file_buffer[0..n_bytes];
}

/// Stdout is for the actual output of your application, for example if you
/// are implementing gzip, then only the compressed bytes should be sent to
/// stdout, not any debugging messages.
pub fn println(comptime fmt: []const u8, args: anytype) !void {
    var std_buffer: [64]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    try stdout.print(fmt, args);
    try stdout.flush(); //Dont forget to flush
}
