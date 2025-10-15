const std = @import("std");
const User = @import("structs/user.zig").User;
const Vec3 = @import("structs/vect.zig").Vec3;
const print = std.debug.print;

/// # 2.  Control flow, structs, modules and types
/// We begin this chapter by discussing the different keywords and structures in Zig related to control flow (e.g. loops and if statements).
/// Then, we talk about structs and how they can be used to do some basic Object-Oriented (OOP) patterns in Zig.
/// We also talk about type inference and type casting. Finally, we end this chapter by discussing modules, and how they relate to structs.
///
/// ## 2.1. Control flow
/// Sometimes, you need to make decisions in your program. Maybe you need to decide whether or not to execute a specific piece of code.
/// Or maybe, you need to apply the same operation over a sequence of values.
/// These kinds of tasks, involve using structures that are capable of changing the “control flow” of our program.
/// ### 2.1.1. `If/else` statements.
fn ctrl_flow_basics() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const x: i32 = 5;
    if (x > 10) {
        try stdout.print("x > 10\n", .{});
    } else {
        try stdout.print("x < 10\n", .{});
    }
    try stdout.flush(); //Dont forget to flush
}

/// ### 2.1.2 Switch statements.
/// Switch statements are also available in Zig, and they have a very similar syntax to a switch statement in Rust.
/// As you would expect, to write a switch statement in Zig we use the switch keyword.
/// We provide the value that we want to “switch over” inside a pair of parentheses.
/// Then, we list the possible combinations (or “branches”) inside a pair of curly braces.
fn switch_statements() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const Role = enum { SE, DPE, DE, DA, PM, PO, KS };

    var area: []const u8 = undefined;
    const role = Role.SE;
    // Switch must handle all possibilities
    // This is what “exhaust all existing possibilities” means.
    switch (role) {
        .PM, .SE, .DPE, .PO => {
            area = "platform";
        },
        .DE, .DA => {
            area = "data analytics";
        },
        .KS => {
            area = "sales";
        },
    }

    const rank: i32 = 0x2;
    // If a switch handles an infinite number of possibilities, then
    // we use an else branch to handle a “not supported” case.
    const rankings = switch (rank) {
        0x1 => "best",
        0x2 => "better",
        0x3 => "good",
        0x4 => "mid",
        0x5 => "bad",
        else => @panic("rank is not supported!"),
    };
    // Furthermore, you can also use ranges of values in switch statements.
    // That is, you can create a branch in your switch statement that is used whenever the input value is within the specified range.
    const level: i32 = 0x1;
    const category = switch (level) {
        0...25 => "beginner",
        26...75 => "intermediary",
        76...100 => "professional",
        else => unreachable,
    };

    try stdout.print("{s}\n", .{area});
    try stdout.print("{s}\n", .{rankings});
    try stdout.print("{s}\n", .{category});
    try stdout.flush(); //Dont forget to flush
}

/// #### 2.1.2.4 Labeled switch statements.
///
/// if you give the label xsw to a switch statement, you can use this label in conjunction with the continue keyword to go back to the beginning of the switch statement.
fn labaled_switch_statements() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    xsw: switch (@as(u8, 1)) {
        1 => {
            try stdout.print("First branch\n", .{});
            continue :xsw 2;
        },
        2 => continue :xsw 3,
        3 => {
            try stdout.print("Ended here\n", .{});
            try stdout.flush(); //Dont forget to flush
            return;
        },
        4 => {},
        else => {
            try stdout.print("Unmatched case {d}\n", .{@as(u8, 1)});
        },
    }
}
/// ### 2.1.3 The defer keyword
/// Zig has a `defer` keyword, which plays a very important role in control flow, and also, in releasing resources.
/// In summary, the `defer` keyword allows you to register an expression to be executed when you exit the current scope.
fn defer_keyword() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    defer print("Exiting function ...\n", .{});

    try stdout.print("Adding some numbers....\n", .{});
    try stdout.print("2 + 2 = {d}\n", .{2 + 2});
    try stdout.print("Multiplying some numbers....\n", .{});
    try stdout.print("2 * 8 = {d}\n", .{2 * 8});
    try stdout.flush(); //Dont forget to flush!
}

/// Foo Error :)
fn foo() !void {
    return error.FooError;
}

/// ### 2.1.4 The errdefer keyword
///
/// While defer is an “unconditional defer”, the errdefer keyword is a “conditional defer”.
/// Which means that the given expression is executed only when you exit the current scope on a very specific circumstance.
/// “defer expressions” are executed in a `LIFO` order,
/// the last `defer` or `errdefer` expressions in the code are the first ones to be executed.
/// Therefore, if I change the order of the `defer` and `errdefer` expressions,
/// you will notice that the value of `i` that gets printed to the console changes to `1`.
/// This doesn’t mean that the defer expression was not executed in this case.
fn errdefer_keyword() !void {
    var i: usize = 1;
    errdefer print("Value of i: {d}\n", .{i});
    defer i = 2;
    try foo();
}

/// ### 2.1.5 For loops
///  With For loops Instead of using a (value in items) syntax like in python, in Zig, for loops use the syntax (items) |value|.
///  In the example below, you can see that we are looping through the items of the array stored at the object name
fn for_loops() !void {
    var std_buffer: [48]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const name = [0x6]u8{ 'B', 'a', 'b', 'a', 'n', 'a' };
    const joined: []const u8 = "Babana";

    for (name) |char| {
        try stdout.print("{d} | ", .{char});
    }
    try stdout.print("\n", .{});
    //There are many situations where we need to use an index instead of the actual values of the items.
    //You can do that by providing a second set of items to iterate over.
    //More precisely, you provide the range selector 0.. to the for loop.
    for (joined, 0..) |_, i| {
        try stdout.print("{d} | ", .{i});
    }
    try stdout.flush(); //Dont forget to flush
}

/// ### 2.1.6 While loops
///  A for loop iterates through the items of an array,
///  but a while loop will loop continuously, and infinitely, until a logical test (specified by you) becomes false.
///  You start with the while keyword, then, you define a logical expression inside a pair of parentheses,
///  and the body of the loop is provided inside a pair of curly braces, like in the example below:
fn while_loops() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    var i: u8 = 0x1;
    // You can also specify the increment expression to be used at the beginning of a while loop.
    // This can be acheived by writing the increment expression inside a pair of parentheses after a colon character (:)
    while (i < 0x5) : (i += 0x1) {
        try stdout.print("{d} | ", .{i});
        // i += 1;
    }
    try stdout.flush();
}

/// ### 2.1.7 Using break and continue
///
///In Zig, you can explicitly stop the execution of a loop, or, jump to the next iteration of the loop, by using the keywords `break` and `continue`
fn modifying_loops() !void {
    var std_buffer: [48]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const ns = [_]u8{ 1, 2, 3, 4, 5, 6 };
    var i: u8 = 0;

    while (true) : (i += 1) {
        if (i == 0xA) {
            break;
        }
    }
    try stdout.print("New value of i: {d}\n", .{i});
    // The if statement is constantly checking if the current index is a multiple of 2. If it is, we jump to the next iteration of the loop.
    for (ns) |byte| {
        if ((byte % 2) == 0) {
            continue;
        }
        try stdout.print("{d} | ", .{byte});
    }

    try stdout.flush();
}

/// ### 2.2 Function parameters are immutable
/// If you look closely at the body of this `add_to()` function,
/// you will notice that we try to save the result back into the `x` function argument.
/// This function not only uses the value that it received through the function argument `x`,
/// but it also tries to change the value of this function argument, by assigning the addition result into `x`.
/// However, function arguments in Zig are immutable.
/// You cannot change their values, or, you cannot assign values to them inside the body’s function.
fn add_to(x: u32) !u32 {
    x = x + 2;
    return x;
}

fn functions_are_immutable() !void {
    const y = add_to(4);
    print("{d}", .{y});
}

/// ### 2.2.2 How to overcome this barrier
/// There are some situations where you might need to change the value of your function argument directly inside the function’s body.
/// This happens more often when we are passing C structs as inputs to Zig functions.
fn add2(x: *u32) void {
    // Even in this code example above, the x argument is still immutable. Which means that the pointer itself is immutable.
    // Therefore, you cannot change the memory address that it points to.
    // However, you can dereference the pointer to access the value that it points to, and also, to change this value, if you need to.
    x.* = x.* + 0x2;
}
fn how_to_modify_immutability() !void {
    var x: u32 = 0x4;
    add2(&x);
    print("{d}", .{x});
}

/// ### 2.3 Structs and OOP
/// Zig is a language more closely related to C (which is a procedural language), than it is to C++ or Java (which are object-oriented languages).
/// Because of that, you do not have advanced OOP (Object-Oriented Programming) patterns available in Zig, such as classes, interfaces or class inheritance.
/// Nonetheless, OOP in Zig is still possible by using struct definitions.
/// In Zig, we normally declare the constructor and the destructor methods of our structs, by declaring an `init()` and a `deinit()` methods inside the struct.
/// Structs **must** be globally scoped. See the `/structs` folder to see struct definitions
fn zig_structs() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;
    // This `init()` method is the constructor method that we will use to instantiate every new User object.
    // That is why this `init()` function returns a new User object as result.
    const usr = User.init(0x1, "Babana", "babanalemmings@gmail.com");
    // You can declare a struct object as a literal value.
    // When we do that, we normally specify the data type of this struct literal by writing its data type just before the opening curly brace.
    const eu = User{ .id = 0x2, .name = "Pedro", .email = "someemail@gmail.com" };
    // In Zig, we can also write an anonymous struct literal.
    // That is, you can write a struct literal, but not specify explicitly the type of this particular struct.
    // An anonymous struct is written by using the syntax `.{}`.
    const ca: User = .{ .id = 0x3, .name = "Johnny", .email = "johndoe@gmail.com" };
    // Struct declarations must be constant
    const vec1 = Vec3.init(0.1, 0.0, 0.1);
    const vec2 = Vec3.init(0.1012, 0.0006, 0.0989);

    const dot = vec1.dot_product(vec2);

    const eucledian_distance = vec1.distance(vec2);

    try usr.print_name(stdout);
    try eu.print_name(stdout);
    try ca.print_name(stdout);

    try stdout.print("Dot product of vec1 & vec 2 = {d}\n", .{dot});
    try stdout.print("Eucleadian distance of vec1 & vec2 = {d}\n", .{eucledian_distance});
    // About the struct state
    // what if we do have a method that alters the state of the object, by altering the values of its data members,
    // how should we annotate self in this instance? The answer is: “we should annotate self as a pointer of x, instead of just x”.
    // In other words, you should annotate self as self: *x, instead of annotating it as self: x.
    var vec3 = Vec3.init(4.2, 2.4, 0.9);
    vec3.twice();
    try stdout.print("twice vec3 {}", .{vec3});
    try stdout.flush();
}

/// ## 2.4 Type inference
/// In general, type inference in Zig is done by using the dot character `(.)`.
/// Everytime you see a dot character written before a struct literal,
/// or before an enum value, or something like that, you know that this dot character is playing a special part in this place.
/// More specifically, it’s telling the zig compiler something along the lines of:
/// “Hey! Can you infer the type of this value for me? **Please!**”.
/// In other words, this dot character is playing a similar role as the `auto` keyword in C++.
fn empty() !void {}
/// ## 2.5 Type casting
/// Most languages have a formal way to perform type casting.
/// In Rust for example, we normally use the keyword `as`, and in C, we normally use the type casting syntax, e.g. `(int) x`.
/// In Zig, we use the `@as()` built-in function to cast an object of type “x”, into an object of type “y”.
///
/// When casting an integer value into a float value, or vice-versa, it’s not clear to the compiler how to perform this conversion safely.
/// Therefore, we need to use specialized “casting functions” in such situations.
/// For example, if you want to cast an integer value into a float value, then, you should use the `@floatFromInt()` function.
/// In the inverse scenario, you should use the `@intFromFloat()` function.
fn type_casting() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;
    const x: i32 = 404;
    const y = @as(u32, x);

    const z: f64 = @floatFromInt(x);

    const a: bool = false;
    const b: i32 = @intFromBool(a);

    // Everytime a pointer is involved in some “type casting operation” in Zig,
    // the `@ptrCast()` function is used. This function works similarly to `@floatFromInt()`.
    // You just provide the pointer object that you want to cast as input to this function,
    // and the target data type is, once again, determined by the type annotation of the object where the results are being stored.
    // `align(@alignOf(u32))` forces the array to be aligned the same way as a u32 (4 bytes on most systems).
    const bytes align(@alignOf(u32)) = [4]u8{ 0x12, 0x12, 0x12, 0x12 };
    const u32_ptr: *const u16 = @ptrCast(&bytes);

    try stdout.print("Type of y: {} & value: {d}\n", .{ @TypeOf(y), y });
    try stdout.print("Type of z: {} & value: {d}\n", .{ @TypeOf(z), z });
    try stdout.print("Type of b: {} & value: {d}\n", .{ @TypeOf(b), b });
    try stdout.print("Type of u32_ptr: {}\n", .{@TypeOf(u32_ptr)});
    try stdout.flush();
}

fn work(inc: u32) void {
    std.debug.print("Start Inc = {d}\n", .{inc});
    var total: u32 = 0;
    var i: u32 = 0;
    while (i < 100000) : (i += 1) {
        total += inc;
    }
    print("Total = {d}, Inc = {d}\n", .{ total, inc });
}
/// ## 2.6 Modules
/// Every Zig module (i.e., a .zig file) that you write in your project is internally stored as a struct object.
/// When we want to access the functions and objects from the standard library, we are basically accessing the data members of the struct stored in the std object.
/// That is why we use the same syntax that we use in normal structs, with the dot operator `(.)` to access the data members and methods of the struct.
fn zig_modules() !void {
    const allocator = std.heap.page_allocator;
    // Creating a thread pool with 5 worker threads ready to run jobs.
    const n_jobs: usize = 5;
    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = allocator, .n_jobs = n_jobs });
    defer pool.deinit(); //cleanup
    // Spawning jobs
    try pool.spawn(work, .{3});
    try pool.spawn(work, .{5});
    try pool.spawn(work, .{7});
}
pub fn main() !void {
    switch (@as(u8, 0xD)) {
        0x1 => try ctrl_flow_basics(),
        0x2 => try switch_statements(),
        0x3 => try labaled_switch_statements(),
        0x4 => try defer_keyword(),
        0x5 => try errdefer_keyword(),
        0x6 => try for_loops(),
        0x7 => try while_loops(),
        0x8 => try modifying_loops(),
        0x9 => try functions_are_immutable(),
        0xA => try how_to_modify_immutability(),
        0xB => try zig_structs(),
        0xC => try type_casting(),
        0xD => try zig_modules(),
        else => unreachable,
    }
}
