const std = @import("std");
const print = std.debug.print;

fn ctrl_flow_basics() !void {
    var std_buffer: [48]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const x: i32 = 5;
    if (x > 10) {
        try stdout.print("x > 10\n", .{});
        try stdout.flush(); //Dont forget!
    } else {
        try stdout.print("x < 10\n", .{});
        try stdout.flush(); //Dont forget!
    }
}

/// switch must handle all possibilities
/// This is what “exhaust all existing possibilities” means.
fn switch_statements() !void {
    var std_buffer: [48]u8 = undefined;
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
    const level: i32 = 1;

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
    try stdout.flush(); //Dont forget!
}

fn labaled_switch_statements() !void {
    var std_buffer: [48]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    xsw: switch (@as(u8, 1)) {
        1 => {
            try stdout.print("First branch\n", .{});
            try stdout.flush(); // Dont!
            continue :xsw 2;
        },
        2 => continue :xsw 3,
        3 => {
            try stdout.print("Ended here\n", .{});
            try stdout.flush(); // Dont!
            return;
        },
        4 => {},
        else => {
            try stdout.print("Unmatched case {d}\n", .{@as(u8, 1)});
            try stdout.flush(); // Dont!
        },
    }
}

fn defer_keyword() !void {
    var std_buffer: [48]u8 = undefined;
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

///  Instead of using a (value in items) syntax, in Zig, for loops use the syntax (items) |value|.
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
    try stdout.flush(); // Dont!
}

///  A for loop iterates through the items of an array,
///  but a while loop will loop continuously, and infinitely, until a logical test (specified by you) becomes false.
fn while_loops() !void {
    var std_buffer: [48]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    var i: u8 = 1;
    // You can also specify the increment expression to be used at the beginning of a while loop.
    // This can be acheived by writing the increment expression inside a pair of parentheses after a colon character (:)
    while (i < 5) : (i += 1) {
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
    // The if statement is constantly checking if the current index is a multiple of 2. If it is, we jump to the next iteration of the loop.
    for (ns) |byte| {
        if ((byte % 2) == 0) {
            continue;
        }
        try stdout.print("{d} | ", .{byte});
    }

    try stdout.print("\n", .{});
    try stdout.print("New value of i: {d}\n", .{i});
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

pub fn main() !void {
    switch (@as(i32, 9)) {
        0x1 => try ctrl_flow_basics(),
        0x2 => try switch_statements(),
        0x3 => try labaled_switch_statements(),
        0x4 => try defer_keyword(),
        0x5 => try errdefer_keyword(),
        0x6 => try for_loops(),
        0x7 => try while_loops(),
        0x8 => try modifying_loops(),
        0x9 => try functions_are_immutable(),
        else => unreachable,
    }
}
