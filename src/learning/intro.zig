const std = @import("std");
const module = @import("utils/utils.zig");
const builtin = @import("builtin");
const print = std.debug.print;
/// Variable Basics
fn variables() void {
    // mutable variab;es
    var num: u8 = 0;
    // immutable variables
    const age: u8 = 20;
    // discareded variable
    _ = age;
    // var kimiki = "I am kimiki"; //mutable variables must be used
    num = 30;
    print("My num is {d}\n", .{num});
}

/// Array Basics
fn arrays_basics() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const ns = [4]u8{ 48, 24, 64, 96 }; //you assert array size
    const ls = [_]f64{ 0.05, 0.800, 55.9 }; //compiler asserts array size
    const sl = ls[1..];
    const unar = [2]i32{ 2, 6 };
    _ = unar; //discareded array

    print("My Array = {any}\n", .{ns});
    print("My Float Array = {any}\n", .{ls});
    try stdout.print("Selected Element = {d}\n", .{ns[0]}); //index selection
    try stdout.print("Sliced Elements = {any}\n", .{ns[0..2]}); //range selection
    try stdout.print("Sliced Elements by length = {any}\n", .{ns[0..ns.len]}); // range selection by length
    try stdout.print("Slicing From the beginning without end = {any}\n", .{ns[1..]}); // range selection without end
    try stdout.print("Sliced Length = {d}\n", .{sl.len}); //get pointer array length
    try stdout.flush(); //Dont forget to flush
}

/// Array operators (++) & (**)
fn array_ops() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const fas = [3]u8{ 10, 20, 30 };
    const sec = [4]i32{ -22, 11, -44, 55 };

    const las = fas ++ sec;
    const ori = [3]i32{ 2, 4, 7 };
    const rep = ori ** 3;

    try stdout.print("Concatenated Array = {any}\n", .{las}); // concatenates as long as they are of integer type despite bitwise length (best use case is to concat strings)
    try stdout.print("Type interface for new array: {any}\n", .{@TypeOf(las)}); // Highest bit depth takes precedence

    try stdout.print("Repeated Array = {any}\n", .{rep}); //creates a new array which contains the elements of the array ori repeated 3 times.
    try stdout.flush(); //Dont forget to flush
}

/// Demonstrates runtime versus compile-time known length in slices
fn run_vs_comp() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    // --- Allocator setup ---
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocater = gpa.allocator();

    // --- Compile-time known slice ---
    const arr1 = [10]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    // This slice has a compile-time known range:
    // `1..4` is fixed and known during compilation.
    // That means the compiler can reason about its size = 3 elements.
    const known_slice = arr1[1..4];
    _ = known_slice; // (just to avoid "unused variable" warning)

    // Path to a file we will read at runtime
    const path = "./assets/file-io/shop-list.txt";

    // --- Runtime known slice ---
    // Reads the entire file contents into heap-allocated memory.
    const file_contents = try module.read_file(allocater, path);

    // Here we form a slice using runtime information:
    // file_contents.len is not known until the file is actually read.
    // So the slice length can only be determined *at runtime*.
    const unkown_slice = file_contents[0..file_contents.len];

    // Print the runtime slice (will dump bytes in debug form).
    try stdout.print("{s}\n", .{unkown_slice});

    try stdout.flush(); // Don't forget to flush buffered writer
}

/// You can create blocks within blocks, with multiple levels of nesting.
/// You can also (if you want to) give a label to a particular block, with the colon character `(:)`.
/// Just write `label:` before you open the pair of curly braces that delimits your block.
/// When you label a block in Zig, you can use the break keyword to return a value from this block, like as if it was a function’s body.
/// You just write the break keyword, followed by the block label in the format `:label`, and the expression that defines the value that you want to return.
fn block_scope() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var y: i32 = 120;
    const x = add_one: { //label to this particular block
        y += 1;
        break :add_one y;
    };
    if (x == 121 and y == 121) {
        try stdout.print("Hey!", .{});
        try stdout.flush();
    }
}
/// in zig a string is essentially an array of bytes
/// To achieve this same kind of safety in C,
/// you have to do a lot of work that kind of seems pointless.
/// as an example see & run  `./src/learning/csource/lenchars.c`.
/// You don’t have this kind of work in Zig.
/// Because the length of the string is always present and
/// accessible in the string value itself.
fn strings_basics() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const array = "An example of string in Zig";
    //  “Hello”. In UTF-8,
    // is represented by the sequence of decimal numbers 72, 101, 108, 108, 111.
    // In hexadecimal, this sequence is 0x48, 0x65, 0x6C, 0x6C, 0x6F.
    const bytes = [5]u8{ 0x48, 0x65, 0x6C, 0x6C, 0x6F };
    try stdout.print("Number of elements in the array: {d}\n", .{array.len});
    try stdout.print("{s}\n", .{bytes});
    try stdout.flush(); //Dont forget to flush
}
/// This is a string value being
/// interpreted as a slice.
fn string_slices() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const str: []const u8 = "A string value";
    try stdout.print("{any}\n", .{@TypeOf(str)});

    try stdout.flush(); // Dont forget to flush
}

fn string_indexing() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [64]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const string_object: []const u8 = "This is an example";
    try stdout.print("Bytes that represents the string object: ", .{});
    for (string_object) |byte| {
        try stdout.print("{x} ", .{byte});
    }
    try stdout.flush(); // Dont forget to flush
}

/// To check the type of any object in Zig, you can use the @TypeOf() function.
fn inspect_objects() void {
    const simple_array = [4]i32{ 1, 2, 3, 4 };
    const str_obj: []const u8 = "A string Object";

    print("Type of simple_array {}\n", .{@TypeOf(simple_array)});
    print("Type of simple_obj {}\n", .{@TypeOf(str_obj)});
    print("Type of pointer to simple_array {}\n", .{@TypeOf(&simple_array)});
}

/// All english letters (or ASCII letters if you prefer) can be
/// represented by a single byte in UTF-8.
/// if your string contains other types of letters… for example,
/// you might be working with text data that contains, chinese, japanese or latin letters,
/// then, the number of bytes necessary to represent your UTF-8 string will
/// likely be much higher than the number of characters in that string.
fn unicode_chars_basics() void {
    const char: []const u8 = "Ⱥ";
    // the Latin Capital Letter A With Stroke (Ⱥ) is represented by the number 570
    // which  is higher than the maximum number stored inside a single byte, which is 255.
    // That is why, the unicode point 570 is actually stored inside the computer’s memory as the bytes C8 BA.
    print("Hex upper value of char:  ", .{});
    for (char) |byte| {
        print("{X} ", .{byte});
    }
    // if your UTF-8 string contains only english letters (or ASCII letters),
    // then, you are lucky. Because the number of bytes will be equal to
    // the number of characters in that string.
    // In other words, in this specific situation,
    // the relationship between bytes and unicode points is 1 to 1.
}
// If you need to iterate through the characters of a string,
// instead of its bytes, then, you can use the `std.unicode.Utf8View`
// struct to create an iterator that iterates through the unicode points
// of your string.
fn complex_unicode_chars() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var russian_chars = try std.unicode.Utf8View.init("Люблю тебя, мама.");
    var iterator = russian_chars.iterator();
    // A while loop is used to repeatedly execute an expression until some condition is no longer true
    // heres how it works in this case:
    // Call iterator.nextCodepointSlice().
    // If it returns null, the loop ends.
    // If it returns a slice, bind it to codepoint and run the body.
    while (iterator.nextCodepointSlice()) |codepoint| {
        try stdout.print("got codepoint {x} \n", .{codepoint});
    }

    try stdout.flush(); //Dont forget to flush
}

/// Useful functions for strings
fn useful_string_operations() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    // --- Allocator setup ---
    var alloc_buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buffer);
    const allocator = fba.allocator();

    const instance: []const u8 = "Pedro";
    const second: []const u8 = "Pascal";
    const sequence: []const u8 = "Sequence|Char";

    const slices = [3][]const u8{ instance, " ", second };
    const concat = try std.mem.concat(allocator, u8, &slices);

    var repl_buffer: [5]u8 = undefined;
    const new_rep = std.mem.replace(u8, instance, "ed", "34", &repl_buffer);
    const split_chars = std.mem.splitSequence(u8, sequence, "|");

    // compare if two strings are equal
    try stdout.print("Does instance equal 'Pedro': {}\n", .{std.mem.eql(u8, instance, "Pedro")});
    // check if string starts with substring.
    try stdout.print("Does Instance start with 'P': {}\n", .{std.mem.startsWith(u8, instance, "P")});
    // check if string ends with substring.
    try stdout.print("Does Instance end with 'o': {}\n", .{std.mem.endsWith(u8, instance, "o")});
    // concatenate strings together.
    try stdout.print("Concatenated string: '{s}'\n", .{concat});
    // count the occurrences of substring
    try stdout.print("Occurences of 'P' in concat = {d}\n", .{std.mem.count(u8, concat, "P")});
    // replace the occurrences of substring in the string.
    try stdout.print("New string: {s}\n", .{repl_buffer});
    try stdout.print("Number of replacements: {d}\n", .{new_rep});
    // split a string into an array of substrings given a substring delimiter.
    try stdout.print("Split {s}\n", .{split_chars.buffer});
    try stdout.flush(); //Dont forget to flush
}
pub fn main() !void {
    switch (@as(i32, 1)) {
        0x1 => variables(),
        0x2 => try arrays_basics(),
        0x3 => try array_ops(),
        0x4 => try run_vs_comp(),
        0x5 => try block_scope(),
        0x6 => try strings_basics(),
        0x7 => try string_slices(),
        0x8 => try string_indexing(),
        0x9 => inspect_objects(),
        0xA => unicode_chars_basics(),
        0xB => try complex_unicode_chars(),
        0xC => try useful_string_operations(),
        else => unreachable,
    }
}
