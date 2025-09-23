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
