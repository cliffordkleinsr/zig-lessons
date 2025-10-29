const std = @import("std");
const User = @import("structs/user.zig").User;
///  # 6 Pointers and Optionals
/// In our next project we are going to build a HTTP server from scratch.
/// But in order to do that, we need to learn more about pointers and how they work in Zig.
/// Pointers in Zig are similar to pointers in C. But they come with some extra advantages in Zig.
///
/// A pointer is an object that contains a memory address. This memory address is the address where a particular value is stored in memory.
/// It can be any value. Most of the times, it’s a value that comes from another object (or variable) present in our code.
///
/// In the example below, I’m creating two objects (number and pointer).
/// The pointer object contains the memory address where the value of the number object (the number 5) is stored.
///
/// So, that is a pointer in a nutshell. It’s a memory address that points to a particular existing value in the memory.
/// You could also say, that, the pointer object points to the memory address where the number object is stored.
///
/// We create a pointer object in Zig by using the & operator.
/// When you put this operator before the name of an existing object, you get the memory address of this object as result.
/// When you store this memory address inside a new object, this new object becomes a pointer object.
/// Because it stores a memory address. People mostly use pointers as an alternative way to access a particular value. See example `pointer_expression()`
///
/// For example, I can use the pointer object to access the value stored by the number object.
/// This operation of accessing the value that the pointer “points to” is normally called of dereferencing the pointer.
///
/// We can dereference a pointer in Zig by using the `*` method of the pointer object.
/// Like in the example `pointer_expression()`, where we take the number 5 pointed by the pointer object, and double it.
///
/// This syntax to dereference the pointer is nice. Because we can easily chain it with methods of the value pointed by the pointer.
/// We can use the User struct that we have created in Section 2.3 of chap 2 as an example,
/// the struct contains a `print_name()` method. See the example `other_ptr_operations()`
///
/// We can also use pointers to effectively alter the value of an object.
/// For example, I could use the pointer object to set the value of the object number to 6, like in the example `other_ptr_operations()`.
///
/// Therefore people use pointers as an alternative way to access a particular value.
/// And they use it especially when they do not want to “move” these values around.
/// There are situations where, you want to access a particular value in a different scope (i.e., a different location) of your code,
/// but you do not want to “move” this value to this new scope (or location) that you are in.
///
/// This matters especially if this value is big in size. Because if it is, then, moving this value becomes an expensive operation to do.
/// The computer will have to spend a considerable amount of time copying this value to this new location.
///
/// Therefore, many programmers prefer to avoid this heavy operation of copying the value to the new location, by accessing this value through pointers.
/// We are going to talk more about this “moving operation” over the next sections.
/// For now, the key takeaway is that avoiding this “move operation” is one of main reasons why pointers are used in programming languages.
///
/// ##  5.1 Constant objects vs variable objects
/// You can have a pointer that points to a constant object, or, a pointer that points to a variable object.
/// But regardless of who this pointer is, it must always respect the characteristics of the object that it points to.
/// As a consequence, if the pointer points to a constant object, then, you cannot use this pointer to change the value that it points to.
/// Because it points to a value that is constant. As discussed in Section 1.4 of the introduction, you cannot change a value that is constant.
///
/// You can see this relationship between “constant versus variable” on the data type of your pointer object.
/// In other words, the data type of a pointer object already gives you some clues about whether the value that it points to is constant or not.
///
/// When a pointer object points to a constant value, then, this pointer have a data type `*const T`,
/// which means “a pointer to a constant value of type `T`”.
/// In contrast, if the pointer points to a variable value, then, the type of the pointer is usually *T, which is simply “a pointer to a value of type `T`”.
///
/// Hence, whenever you see a pointer object whose data type is in the format `*const T`,
/// then, you know that you cannot use this pointer to change the value that it points to. Because this pointer points to a constant value of type `T`.
///
/// We have looked at the value pointed by the pointer being constant or not, and the consequences that arises from it.
/// But not the pointer itself. If the pointer object itself is constant or not, then what happens?.
/// We can have a constant pointer that points to a constant value. But we can also have a variable pointer that points to a constant value and vice-versa.
///
/// Until this point, the pointer object was always constant, but what does this mean for us?
/// What is the consequence of the pointer object being constant?
/// The consequence is that we cannot change the pointer object, because it is constant.
/// We can use the pointer object in multiple ways, but we cannot change the memory address that is inside this pointer object.
///
/// However, if we mark the pointer object as a variable object, then, we can change the memory address pointed by this pointer object.
pub fn main() !void {
    switch (@as(u8, 0xA)) {
        0x1 => try pointer_expression(),
        0x2 => try other_ptr_operations(),
        0x3 => try debeg(),
        else => unreachable,
    }
}

fn pointer_expression() !void {
    const number: u8 = 5;
    const addr = &number;

    const doubled = addr.* * 2;

    addr.* = 6;

    std.debug.print("Address of number is: {*}\n", .{addr});
    std.debug.print("Value of address is {d}\n", .{addr.*});
    std.debug.print("Doubled address value = {d}\n", .{doubled});
}

fn other_ptr_operations() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    var number: u8 = 5;
    const pointer = &number;
    pointer.* = 6;
    const clido = User.init(1, "Clifford", "cnjoroge925@gmail.com");
    const addr = &clido;

    try addr.*.print_name(stdout);

    try stdout.print("Altered pointer to variable number = {d}\n", .{number});
    try stdout.flush();
}

fn debeg() !void {
    const a: u8 = 2;
    const b: c_int = 3;

    const c = a + b;

    std.debug.print("{d}\n", .{c});
}
