const std = @import("std");
const read_file = @import("utils/utils.zig").read_file;
const print = std.debug.print;

/// # 1 Introduction to Zig
/// In this chapter, I want to introduce you to the world of Zig. Zig is a very young language that is being actively developed.
/// As a consequence, its world is still very wild and to be explored.
/// This book is my attempt to help you on your personal journey for understanding and exploring the exciting world of Zig.
///
/// ## 1.1 What is Zig?
/// Zig is a modern, low-level, and general-purpose programming language. Some programmers think of Zig as a modern and better version of C.
/// In the author’s personal interpretation, Zig is tightly focused with “less is more”.
/// Instead of trying to become a modern language by adding more and more features,
/// many of the core improvements that Zig brings to the table are actually about removing annoying behaviours/features from C and C++.
/// In other words, Zig tries to be better by simplifying the language, and by having more consistent and robust behaviour.
/// As a result, analyzing, writing and debugging applications become much easier and simpler in Zig, than it is in C or C++.
///
/// ### 1.1.1 The zen of zig
/// By running;
/// ```sh
/// zig zen
/// ```
/// Zig aims to:
/// * Communicate intent precisely.
/// * Edge cases matter.
/// * Favor reading code over writing code.
/// * Only one obvious way to do things.
/// * Runtime crashes are better than bugs.
/// * Compile errors are better than runtime crashes.
/// * Incremental improvements.
/// * Avoid local maximums.
/// * Reduce the amount one must remember.
/// * Focus on code rather than style.
/// * Resource allocation may fail; resource deallocation must succeed.
/// * Memory is a resource.
/// * Together we serve the users.
///
/// ## 1.2 Hello world in Zig
/// To start a new Zig project in your computer, you simply call the init command from the zig compiler.
/// ```sh
/// zig init
/// ```
/// ### 1.2.1 Understanding zig project files
/// After you run the init command from the zig compiler, some new files are created inside of your current directory.
/// First, a “source” (src) directory is created, containing two files, `main.zig` and `root.zig`.
/// Each .zig file is a separate Zig module, which is simply a text file that contains some Zig code.
///```zig
/// .
/// ├── build.zig
/// ├── build.zig.zon
/// └── src
///     ├── main.zig
///     └── root.zig
/// ```
/// The init command also creates two additional files in our working directory: `build.zig` and `build.zig.zon`.
/// The first file (`build.zig`) represents a build script written in Zig.
/// This script is executed when you call the build command from the zig compiler.
/// In other words, this file contains Zig code that executes the necessary steps to build the entire project
///
/// #### 1.2.1.1 Excecutable Entrypoint
/// By convention, the `main.zig` module is where your main function lives.
/// Thus, if you are building an executable program in Zig, you need to declare a public `main()` function,
/// which represents the entrypoint of your program, i.e., where the execution of your program begins.
///
/// #### 1.2.1.2 Library Entrypoint
/// However, if you are building a library (instead of an executable program), then,
/// the normal procedure is to delete this `main.zig` file and start with the `root.zig` module.
/// By convention, the `root.zig` module is the root source file of your library.
///
/// #### 1.2.1.3  Understanding the build system
/// Low-level languages normally use a compiler to build your source code into binary executables or binary libraries.
/// Nevertheless, this process of compiling your source code and building binary executables or binary libraries from it,
/// became a real challenge in the programming world, once the projects became bigger and bigger.
/// As a result, programmers created “build systems”, which are a second set of tools designed to make this process of compiling and building complex projects, easier.
///
/// Examples of build systems are CMake, GNU Make, GNU Autoconf and Ninja, which are used to build complex C and C++ projects.
/// With these systems, you can write scripts, which are called “build scripts”.
/// They simply are scripts that describes the necessary steps to compile/build your project.
///
/// However, these are separate tools, that do not belong to C/C++ compilers, like gcc or clang.
/// As a result, in C/C++ projects, you have not only to install and manage your C/C++ compilers,
/// but you also have to install and manage these build systems separately.
///
/// In Zig, we don’t need to use a separate set of tools to build our projects, because a build system is embedded inside the language itself.
/// We can use this build system to write small scripts in Zig, which describe the necessary steps to build/compile our Zig project.
/// So, everything you need to build a complex Zig project is the zig compiler, and nothing more.
///
/// The second generated file `build.zig.zon` is a JSON-like file, in which you can describe your project,
/// and also, declare a set of dependencies of your project that you want to fetch from the internet.
/// In other words, you can use this `build.zig.zon` file to include a list of external libraries in your project.
///
/// One possible way to include an external Zig library in your project,
/// is to manually build and install the library in your system,
/// and just link your source code with the library at the build step of your project.
///
/// However, if this external Zig library is available on GitHub for example, and it has a valid `build.zig.zon` file in the root folder of the project,
/// which describes the project,
/// you can easily include this library in your project by simply listing this external library in your `build.zig.zon` file.
///
/// In summary, the `build.zig.zon` file works similarly to the `package.json` file in Javascript projects, or the `Cargo.toml` file in Rust projects.
///
/// ### 1.2.3 Compiling your source code
/// You can compile your Zig modules into a binary executable by running the build-exe command from the zig compiler.
/// You simply list all the Zig modules that you want to build after the build-exe command, separated by spaces.
/// In the example below, we are compiling the module `main.zig`.
/// ```sh
/// zig build-exe src/main.zig
/// ```
/// Since we are building an executable, the zig compiler will look for a public `main()` function declared in any of the files that you list after the `build-exe` command.
/// If the compiler does not find a public `main()` function declared somewhere, a compilation error will be raised, warning about this mistake.
///
/// The zig compiler also offers a `build-lib` and `build-obj` commands, which work the exact same way as the build-exe command.
/// The only difference is that, they compile your Zig modules into a portable [C ABI](https://dlang.org/spec/abi.html#c_abi) library or into object files, respectively.
/// In the case of the `build-exe` command, a binary executable file is created by the zig compiler in the root directory of your project.
///
/// ### 1.2.4 Compile and execute at the same time
/// We can use the `zig run` command which compiles Zig modules into an executable file and call the executable file created by the compiler.
/// In the example below, we are compiling and running the module `main.zig`.
/// ```sh
/// zig run src/main.zig
/// ```
///
/// ### 1.2.6 Important note for Windows users
/// This is a Windows-specific thing, and, therefore, does not apply to other operating systems, such as Linux and macOS.
/// In summary, if you have a piece of Zig code that includes some global variables whose initialization rely on runtime resources, then,
/// you might have some troubles while trying to compile this Zig code on Windows.
///
/// An example of this is accessing the the standard output of your system `stdout`, which is usually done in Zig by using the expression `std.fs.File.stdout()`.
/// If you use this expression to instantiate a global variable in a Zig module, then,
/// the compilation of your Zig code will very likely fail on Windows, with an “unable to evaluate comptime expression” error message.
///
/// This failure in the compilation process happens because all global variables in Zig are initialized at compile-time.
/// However, on Windows, operations like accessing the `stdout` (or opening a file)
/// depend on resources that are available only at runtime (you will learn more about compile-time versus runtime in Section 3.1.1 of chapter three).
///
/// For example, if you try to compile this code example on Windows, you will likely get the error message exposed below:
/// ```zig
/// const std = @import("std");
/// var stdout_buffer: [0x400]u8 = undefined;
/// // ERROR! Compile-time error that emerges from
/// // this next line, on the `stdout` object
/// var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
/// const stdout = &stdout_writer.interface;
///
/// pub fn main() !void {
///   try stdout.write("Hello\n");
///   try stdout.flush();
/// }
/// ```
/// The error would be:
/// ```
/// PS E:\clido\zig\zig-lessons> zig run ./src/main.zig
/// C:\Program Files (x86)\zigup-x86_64-windows\zig\0.16.0-dev.747+493ad58ff\files\lib\std\os\windows.zig:2194:13: error: unable to evaluate comptime expression
///            asm (
///            ^~~
/// C:\Program Files (x86)\zigup-x86_64-windows\zig\0.16.0-dev.747+493ad58ff\files\lib\std\os\windows.zig:2203:15: note: called at comptime from here
///    return teb().ProcessEnvironmentBlock;
///           ~~~^~
/// C:\Program Files (x86)\zigup-x86_64-windows\zig\0.16.0-dev.747+493ad58ff\files\lib\std\fs\File.zig:188:52: note: called at comptime from here
///    return .{ .handle = if (is_windows) windows.peb().ProcessParameters.hStdOutput else posix.STDOUT_FILENO };
///                                        ~~~~~~~~~~~^~
/// src\debug_simulation\add_program.zig:4:39: note: called at comptime from here
/// var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
///                    ~~~~~~~~~~~~~~~~~~^~
/// src\debug_simulation\add_program.zig:4:48: note: initializer of container-level variable must be comptime-known
/// var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
///                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~
/// referenced by:
///     stdout: src\debug_simulation\add_program.zig:5:17
///    main: src\debug_simulation\add_program.zig:17:9
///    4 reference(s) hidden; use '-freference-trace=6' to see all references
/// ```
/// To avoid this problem on Windows, we need to force the zig compiler to instantiate this stdout object only at runtime,
/// instead of instantiating it at compile-time. We can achieve that by simply moving the expression to a function body.
/// ```zig
/// const std = @import("std");
/// pub fn main() !void {
///     // SUCCESS: Stdout initialized at runtime.
///     var stdout_buffer: [1024]u8 = undefined;
///     var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
///     const stdout = &stdout_writer.interface;
///     _ = try stdout.write("Hello\n");
///     try stdout.flush();
/// }
/// ```
/// You can read more details about this Windows-specific limitation in a couple of GitHub issues opened at the official Zig repository.
/// More specifically, the issues [6845](https://github.com/ziglang/zig/issues/6845) and [19864](https://github.com/ziglang/zig/issues/19864) for reference
///
/// This solves the problem because all expressions that are inside a function body in Zig are evaluated only at runtime,
/// unless you use the comptime keyword explicitly to change this behaviour.
/// You will learn more about this `comptime` keyword in chapter 12.
pub fn main() !void {
    switch (@as(u8, 0xB)) {
        0x1 => try variables(),
        0x2 => try arrays_basics(),
        0x3 => try array_ops(),
        0x4 => try comptime_vs_runtime(),
        0x5 => try block_scope(),
        0x6 => try strings_basics(),
        0x7 => try string_slices(),
        0x8 => try string_indexing(),
        0x9 => try inspect_objects(),
        0xA => try unicode_chars_basics(),
        0xB => try complex_unicode_chars(),
        0xC => try useful_string_operations(),
        else => unreachable,
    }
}
/// Variable Basics
fn variables() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    // mutable variables
    var num: u8 = 0;
    // immutable variables
    const age: u8 = 20;
    // discareded variable
    _ = age;
    // var kimiki = "I am kimiki"; //mutable variables must be used
    num = 30;
    try stdout.print("My num is {d}\n", .{num});
    try stdout.flush(); //Dont forget to flush
}

/// Array Basics
fn arrays_basics() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const ns = [0x4]u8{ 48, 24, 64, 96 }; //you assert array size
    const ls = [_]f64{ 0.05, 0.800, 55.9 }; //compiler asserts array size
    const sl = ls[1..];
    const unar = [0x2]i32{ 2, 6 };
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
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const fas = [0x3]u8{ 10, 20, 30 };
    const sec = [0x4]i32{ -22, 11, -44, 55 };

    const las = fas ++ sec;
    const ori = [0x3]i32{ 2, 4, 7 };
    const rep = ori ** 3;

    try stdout.print("Concatenated Array = {any}\n", .{las}); // concatenates as long as they are of integer type despite bitwise length (best use case is to concat strings)
    try stdout.print("Type interface for new array: {any}\n", .{@TypeOf(las)}); // Highest bit depth takes precedence

    try stdout.print("Repeated Array = {any}\n", .{rep}); //creates a new array which contains the elements of the array ori repeated 3 times.
    try stdout.flush(); //Dont forget to flush
}

/// Demonstrates runtime versus compile-time known length in slices
fn comptime_vs_runtime() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    // --- Allocator setup ---
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
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
    const file_contents = try read_file(allocater, path);
    //rebuild the *original* allocation slice so that the `allocator.free()` sees the exact (ptr, len) it gave us.
    // `file_contents.ptr` points to the beginning of the allocated block.
    // `[0..1024]` restores the original allocation size.
    defer allocater.free(file_contents.ptr[0..1024]);

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
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var y: i32 = 0x78;
    const x = add_one: { //label to this particular block
        y += 1;
        break :add_one y;
    };
    if (x == 121 and y == 121) {
        try stdout.print("Hey!", .{});
    }
    try stdout.flush(); //Dont forget to flush
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
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const array = "An example of string in Zig";
    //  “Hello”. In UTF-8,
    // is represented by the sequence of decimal numbers 72, 101, 108, 108, 111.
    // In hexadecimal, this sequence is 0x48, 0x65, 0x6C, 0x6C, 0x6F.
    const bytes = [0x5]u8{ 0x48, 0x65, 0x6C, 0x6C, 0x6F };
    try stdout.print("Number of elements in the array: {d}\n", .{array.len});
    try stdout.print("{s}\n", .{bytes});
    try stdout.flush(); //Dont forget to flush
}
/// This is a string value being
/// interpreted as a slice.
fn string_slices() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const str: []const u8 = "A string value";
    try stdout.print("{any}\n", .{@TypeOf(str)});

    try stdout.flush(); // Dont forget to flush
}

fn string_indexing() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
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
fn inspect_objects() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const simple_array = [4]i32{ 1, 2, 3, 4 };
    const str_obj: []const u8 = "A string Object";

    try stdout.print("Type of simple_array {}\n", .{@TypeOf(simple_array)});
    try stdout.print("Type of simple_obj {}\n", .{@TypeOf(str_obj)});
    try stdout.print("Type of pointer to simple_array {}\n", .{@TypeOf(&simple_array)});

    try stdout.flush(); // Dont forget to flush
}

/// All english letters (or ASCII letters if you prefer) can be
/// represented by a single byte in UTF-8.
/// if your string contains other types of letters… for example,
/// you might be working with text data that contains, chinese, japanese or latin letters,
/// then, the number of bytes necessary to represent your UTF-8 string will
/// likely be much higher than the number of characters in that string.
fn unicode_chars_basics() !void {
    // --- Setup for buffered stdout writer ---
    var stdout_buffer: [0x40]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const char: []const u8 = "Ⱥ";
    // the Latin Capital Letter A With Stroke (Ⱥ) is represented by the number 570
    // which  is higher than the maximum number stored inside a single byte, which is 255.
    // That is why, the unicode point 570 is actually stored inside the computer’s memory as the bytes C8 BA.
    try stdout.print("Hex upper value of char:  ", .{});
    for (char) |byte| {
        try stdout.print("0x{X} ", .{byte});
    }
    try stdout.flush(); // Dont forget to flush
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
    var stdout_buffer: [0x400]u8 = undefined;
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
    var stdout_buffer: [0x400]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    // --- Allocator setup ---
    var alloc_buffer: [0x400]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&alloc_buffer);
    const allocator = fba.allocator();

    const instance: []const u8 = "Pedro";
    const second: []const u8 = "Pascal";
    const sequence: []const u8 = "Sequence|Char";

    const slices = [0x3][]const u8{ instance, " ", second };
    const concat = try std.mem.concat(allocator, u8, &slices);

    var repl_buffer: [0x5]u8 = undefined;
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
