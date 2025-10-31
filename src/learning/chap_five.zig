const std = @import("std");
const User = @import("structs/user.zig").User;
///  # 5 Pointers and Optionals
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
/// The example `pointer_declarations()` demonstrates that. Notice that the object pointed by the pointer object changes from `c1` to `c2`.
///
/// Thus, by setting the pointer object to a var or const object, you specify if the memory address contained in this pointer object can change or not in your program.
/// On the other side, you can change the value pointed by the pointer, if, and only if this value is stored in a variable object.
/// If this value is in a constant object, then, you cannot change this value through a pointer.
///
/// ## 5.2 Types of pointers
/// In Zig, there are two types of [pointers](https://ziglang.org/documentation/master/#Pointers), which are:
/// - `*T` - The *`single-item`* pointer to exactly one item.
///     - Supports dereference syntax: `ptr.*`
///     - Supports slice syntax: `ptr[0..1]`
///     - Supports pointer subtraction: `ptr - ptr`
///
/// - `[*]T` - The *`many-item`* pointer to unknown number of items.
///     - Supports index syntax: `slice[i]`
///     - Supports slice syntax: `slice[start..end]`
///     - Supports len property: `slice.len`
///
/// When you apply the `&` operator over an object, you will always get a *`single-item`* pointer.
/// Many-item pointers are more of a “internal type” of the language, more closely related to slices.
/// So, when you deliberately create a pointer with the & operator, you always get a *`single-item`* pointer as result.
/// See the example `many_item_pointer()`
///
/// ## 5.3 Pointer arithmetic
/// Pointer Arithmetic is the set of valid arithmetic operations that can be performed on pointers.
/// As discussed inthe beginning of this chapter, pointer variables store the memory address of another variable and thus it doesn't store any value.
///
/// Pointer arithmetic is available in Zig, and they work the same way they work in C.
/// When you have a pointer that points to an array, the pointer usually points to the first element in the array,
/// and you can use pointer arithmetic to advance this pointer and access the other elements in the array.
///
/// >![ptr_arithmetic](https://media.geeksforgeeks.org/wp-content/uploads/20230424100855/Pointer-Increment-Decrement.webp)
///
/// Notice in the example below, that initially, the "ptr" object was pointing to the first element in the array "ar".
/// But then, I started to walk through the array, by advancing the pointer with simple pointer arithmetic.
///
/// Although you can create a pointer to an array like that, and start to walk through this array by using pointer arithmetic,
/// in Zig, we prefer to use slices, which were presented in Section 1.6 of the introduction chapter.
///
/// Under the hood, slices already are pointers, and they also come with the `len` property, which indicates how many elements are in the slice.
/// This is good because the zig compiler can use it to check for potential buffer overflows, and other problems like that.
/// Also, you don’t need to use pointer arithmetic to walk through the elements of a slice.
/// You can simply use the `slice[index]` syntax to directly access any element you want in the slice.
/// For example;6
/// ```zig
///     const ar = [_]i32{1,2,3,4};
///     const sl = ar[0..ar.len];
///     _ = sl;
/// ```
/// ## 5.4 Optionals and Optional Pointers
/// By default, objects in Zig are non-nullable. This means that, in Zig, you can safely assume that any object in your source code is not null.
/// This is a powerful feature of Zig when you compare it to the developer experience in C.
/// Because in C, any object can be null at any point, and, as consequence, a pointer in C might point to a null value.
/// This is a common source of undefined behaviour in C.
/// When programmers work with pointers in C, they have to constantly check if their pointers are pointing to null values or not.
/// In contrast, when working in Zig, if for some reason,
/// your Zig code produces a null value somewhere, and, this null value ends up in an object that is non-nullable, a runtime error is always raised by your Zig program.
///
/// Take the program `null_exception()` as an example. The zig compiler can see the null value at compile time, and, as result, it raises a compile time error.
/// But, if a null value is raised during runtime, a runtime error is also raised by the Zig program, with a “attempt to use null value” message.
///
/// In C, you don’t get warnings or errors about null values being produced in your program.
/// If for some reason, your code produces a null value in C, most of the times, you end up getting a segmentation fault error as result, which can mean many things.
/// That is why programmers have to constantly check for null values in C.
///
/// Pointers in Zig are also, by default, non-nullable.
/// So, you can safely assume that any pointer that you create in your Zig code is pointing to a non-null value.
///
/// ### 5.4.1 What are optionals?
/// Ok, we know now that all objects are non-nullable by default in Zig.
/// But what if we actually need to use an object that might receive a null value? Here is where optionals come in.
///
/// An optional object in Zig is rather similar to a `std::optional` object in [C++](https://en.cppreference.com/w/cpp/utility/optional.html).
/// It is an object that can either contain a value, or nothing at all (a.k.a. the object can be null).
/// To mark an object in our Zig code as “optional”, we use the `?` operator.
/// When you put this `?` operator right before the data type of an object,
/// you transform this data type into an optional data type, and the object becomes an optional object.
///
/// Take the example optionals. We are creating a new variable object called `num`.
/// This object have the data type `?i32`, which means that, this object contains either a signed 32-bit integer (i32), or, a null value.
///
/// ### 5.4.2 Optional pointers
/// You can also mark a pointer object as an optional pointer, meaning that, this object contains either a null value, or, a pointer that points to a value.
/// When you mark a pointer as optional, the data type of this pointer object becomes `?*const T` or `?*T`,
/// depending if the value pointed by the pointer is a constant value or not.
/// The `?` identifies the object as optional, while the `*` identifies it as a pointer object.
///
/// In the example below, we are creating a variable object named num, and an optional pointer object named ptr.
/// Notice that the data type of the object ptr indicates that it’s either a null value, or a pointer to an `i32` value.
/// Also, notice that the pointer object (ptr) can be marked as optional, even if the object num is not optional.
///
/// In the example below, we are creating a variable object named num, and an optional pointer object named ptr.
/// Notice that the data type of the object ptr indicates that it’s either a null value, or a pointer to an `i32` value.
/// Also, notice that the pointer object (ptr) can be marked as optional, even if the object num is not optional.
///
/// What this code tells us is that, the num variable will never contain a null value.
/// This variable will always contain a valid i32 value.
/// But in contrast, the ptr object might contain either a null value, or, a pointer to an i32 value.
///
/// But what if we mark num object as optional, instead of the pointer object.
/// Then, the pointer object is not optional anymore. It would be a similar (although different) result.
///
/// Because then, we would have a pointer to an optional value. In other words, a pointer to a value that is either a null value, or, a not-null value.
/// In the example below, we are recreating this idea. Now, the `ptr` object have a data type of `*?i32`, instead of `?*i32`.
/// Notice that the `*` symbol comes before of `?` this time. So now, we have a pointer that points to a value that is either null , or, a signed 32-bit integer.
///
/// ### 5.4.3 Null handling in optionals
/// When you have an optional object in your Zig code, you have to explicitly handle the possibility of this object being null.
/// It’s like error-handling with try and catch. In Zig you also have to handle null values like if they were a type of error.
///
/// We can do that, by using either:
/// - an `if` statement, like you would do in C.
/// - the `orelse` keyword.
/// - unwrap the optional value with the `?` method.
///
/// #### 5.4.3.1 IF Handler
/// When you use an `if` statement, you use a pair of pipes to unwrap the optional value, and use this “unwrapped object” inside the `if` block.
/// Using the `handling_optionals()` `IF` case example as a reference, if the object `num` is null, then, the code inside the if statement is not executed.
/// Otherwise, the if statement will unwrap the object `num` into the `not_null_num` object.
///
/// #### 5.4.3.2 ORELSE Handler
/// The `orelse` keyword behaves like a binary operator. You connect two expressions with this keyword.
/// On the left side of `orelse`, you provide the expression that might result in a null value,
/// and on the right side of `orelse`, you provide another expression that will not result in a null value.
///
/// The idea behind the `orelse` keyword is: if the expression on the left side result in a not-null value, then, this not-null value is used.
/// However, if this expression on the left side result in a null value, then, the value of the expression on the right side is used instead.
///
/// Looking at the `handling_optionals()` `ORELSE` case example, since the x object is currently null,
/// the `orelse` decided to use the alternative value, which is the number 15.
///
/// #### 5.4.3.3 UNWRAP Handler (`?`)
/// You can use the `if` statement or the `orelse` keyword, when you want to solve (or deal with) this null value.
/// However, if there is no clear solution to this null value,
/// and the most logic and sane path is to simply panic and raise a loud error in your program when this null value is encountered,
/// you can use the `?` method of your optional object.
///
/// In essence, when you use this `?` method, the optional object is unwrapped.
/// If a not-null value is found in the optional object, then, this not-null value is used.
/// Otherwise, the `unreachable` keyword is used.
/// In essence, when you build your Zig source code using the build modes `ReleaseSafe` or `Debug`,
/// the `unreacheable` keyword causes the program to panic and raise an error during runtime, like in the `handling_optionals()` `UNWRAP` case example
pub fn main() !void {
    switch (@as(u8, 0xA)) {
        0x1 => try pointer_expression(),
        0x2 => try other_ptr_operations(),
        0x3 => try pointer_declarations(),
        0x4 => try many_item_pointer(),
        0x5 => try pointer_increment_decrement(),
        0x6 => try null_exception(),
        0x7 => try optionals(),
        0x8 => try optional_pointers(),
        0x9 => try optional_value_pointers(),
        0xA => try handling_optionals(),
        else => unreachable,
    }
}

fn pointer_expression() !void {
    const number: u8 = 5;
    const addr = &number;

    const doubled = addr.* * 2;

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

fn pointer_declarations() !void {
    var std_buffer: [0x30]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;

    const c1: u8 = 5;
    const c2: u8 = 6;

    var pointer = &c1;
    try stdout.print("{d}\n", .{pointer.*});
    pointer = &c2;
    try stdout.print("{d}\n", .{pointer.*});
    try stdout.flush();
}

fn many_item_pointer() !void {
    var x: i32 = 1234; // integer variable
    const x_ptr = &x; // Pointer to a single i32 (type: *i32)
    // Convert to array pointer using slice syntax:
    const x_array_ptr = x_ptr[0..1];
    // This creates an array pointer of type *const [1]i32
    // The syntax [0..1] means: "view memory from index 0 up to (but not including) index 1"
    // So we’re treating the single i32 that x_ptr points to as a 1-element array
    // No copying happens, it's just a reinterpretation of the same address
    std.debug.print("{any}\n", .{x_array_ptr.*});
    // Coerce to many-item pointer:
    const x_many_ptr: [*]i32 = x_array_ptr;
    std.debug.print("{d}\n", .{x_many_ptr[0]});
}

fn pointer_increment_decrement() !void {
    const ar = [4]u8{ 1, 2, 3, 4 };
    var ptr: [*]const u8 = &ar; //create a many_item_pointer
    // Forward increment iteration
    for (ar) |_| {
        std.debug.print("{d}\n", .{ptr[0]});
        ptr += 1;
    }
    // This moves the pointer backward by 4 (ar.len == 4). Therefore;
    // `ptr = (&ar + 4) - 4`
    // `ptr = &ar`
    ptr -= ar.len;
    // Then we move the pointer forward by 3 (because 4 - 1 = 3). Therefore;
    // `ptr = &ar + 3`
    ptr += ar.len - 1; // point to last element
    // So now the pointer points to the last valid element `ar[3]`
    // Backward decrement iteration
    for (ar) |_| {
        std.debug.print("{d}\n", .{ptr[0]});
        ptr -= 1;
    }
}

fn null_exception() !void {
    var number: u8 = 6;
    number = null;
    std.debug.print("{d}\n", .{number});
}

fn optionals() !void {
    var num: ?i32 = 10;
    num = null;

    std.debug.print("{any}\n", .{num});
}

fn optional_pointers() !void {
    var num: i16 = 9;
    var addr: ?*i16 = &num;
    addr = null;
    num = 6;
    std.debug.print("{any}\n", .{@TypeOf(addr)});
}

fn optional_value_pointers() !void {
    var num: ?i16 = 9;
    const addr = &num;
    num = null;
    std.debug.print("{any}\n", .{@TypeOf(addr)});
}

fn handling_optionals() !void {
    const handles = enum { IF, ORELSE, UNWRAP };
    const handler = handles.UNWRAP;
    switch (handler) {
        .IF => {
            const num: ?i32 = 20;
            if (num) |not_null_num| {
                std.debug.print("{d}\n", .{not_null_num});
            }
        },
        .ORELSE => {
            const x: ?i32 = null;
            const dbl = (x orelse 15) * 2;
            std.debug.print("{d}\n", .{dbl});
        },
        .UNWRAP => {
            const x = std.crypto.random.intRangeAtMost(i32, 0, 20);
            const y = return_null(x);
            std.debug.print("{d}\n", .{y.?});
        },
    }
}

fn return_null(n: i32) ?i32 {
    if (@mod(n, 5) == 0) return null;
    return n;
}
