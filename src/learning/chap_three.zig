const std = @import("std");

/// # 3  Memory and Allocators
/// In this chapter, we will talk about memory.
/// How does Zig control memory? What common tools are used? Are there any important aspects that make memory different/special in Zig?
/// You will find the answers here.
/// ## 3.1 3.1 Memory spaces
/// Every object that you create in your Zig source code needs to be stored somewhere, in your computer’s memory.
/// Depending on where and how you define your object, Zig will use a different “memory space”, or a different type of memory to store this object.
// Each type of memory normally serves for different purposes. In Zig, there are 3 types of memory (or 3 different memory spaces) that we care about. They are:
///
/// - Global data register (or the “global data section”)
/// - Stack
/// - Heap
/// ## 3.1.1 Compile-time known versus runtime known
/// When you write a program in Zig, the values of some of the objects that you write in your program are known at compile time.
/// Meaning that, when you compile your Zig source code, during the compilation process,
/// the zig compiler can figure out the exact value of a particular object that exists in your source code.
///
/// The zig compiler cares more about knowing the length (or the size) of a particular object,
/// than to know its actual value. But, if the zig compiler knows the value of the object, then,
/// it automatically knows the size of this object. Because it can simply calculate the size of the object by looking at the size of the value.
fn comptime_known() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const name = "Pedro";
    const array = [4]u8{ 1, 2, 3, 4 };

    try stdout.print("Len Pedro: {d}\n", .{name.len});
    try stdout.print("Len array: {d}\n", .{array.len});

    try stdout.flush();
}
pub fn main() !void {
    switch (@as(i32, 0x1)) {
        0x1 => try comptime_known(),
        else => unreachable,
    }
}
