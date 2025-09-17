const std = @import("std");
const User = @import("structs/user.zig").User;
const print = std.debug.print;

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

/// switch must handle all possibilities
/// This is what “exhaust all existing possibilities” means.
fn switch_statements() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const Role = enum { SE, DPE, DE, DA, PM, PO, KS };

    var area: []const u8 = undefined;
    const role = Role.SE;

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

    // using ranges in switch statements
    const level: i32 = 0x1;

    const category = switch (level) {
        0...25 => "beginner",
        26...75 => "intermediary",
        76...100 => "professional",
        // we use an else branch to handle a “not supported” case.
        else => {
            @panic("Not supported level!");
        },
    };

    // Labeled switch statements

    try stdout.print("{s}\n", .{area});
    try stdout.print("{s}\n", .{category});
    try stdout.flush(); //Dont forget to flush
}

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

///  A for loop iterates through the items of an array,
///  but a while loop will loop continuously, and infinitely, until a logical test (specified by you) becomes false.
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

///In Zig, you can explicitly stop the execution of a loop, or, jump to the next iteration of the loop, by using the keywords break and continue
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

/// How to overcome this barrier
/// There are some situations where you might need to change the value of your function argument directly inside the function’s body.
/// This happens more often when we are passing C structs as inputs to Zig functions.
fn add2(x: *u32) void {
    x.* = x.* + 0x2;
}
fn how_to_modify_immutability() !void {
    var x: u32 = 0x4;
    add2(&x);
    print("{d}", .{x});
}

const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }

    fn dot_product(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    /// This method calculates the distance between two Vec3 objects, by following the distance formula in euclidean space.
    fn distance(self: Vec3, other: Vec3) f64 {
        const xd = std.math.pow(f64, self.x - other.x, 2);
        const yd = std.math.pow(f64, self.y - other.y, 2);
        const zd = std.math.pow(f64, self.z - other.z, 2);

        return std.math.sqrt(xd + yd + zd);
    }
};
/// Structs & OOP
/// In Zig, we normally declare the constructor and the destructor methods of our structs, by declaring an init() and a deinit() methods inside the struct.
/// Structs should be globally scoped
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

    try stdout.flush();
}

pub fn main() !void {
    switch (@as(i32, 0xB)) {
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
        else => unreachable,
    }
}
