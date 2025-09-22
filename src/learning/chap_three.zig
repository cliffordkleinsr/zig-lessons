const std = @import("std");

/// # 3  Memory and Allocators
/// In this chapter, we will talk about memory.
/// How does Zig control memory? What common tools are used? Are there any important aspects that make memory different/special in Zig?
/// You will find the answers here.
/// ## 3.1
/// ### 3.1 Memory spaces
/// Every object that you create in your Zig source code needs to be stored somewhere, in your computer’s memory.
/// Depending on where and how you define your object, Zig will use a different “memory space”, or a different type of memory to store this object.
// Each type of memory normally serves for different purposes. In Zig, there are 3 types of memory (or 3 different memory spaces) that we care about. They are:
///
/// - Global data register (or the “global data section”)
/// - Stack
/// - Heap
/// ### 3.1.1 Compile-time known versus runtime known
/// When you write a program in Zig, the values of some of the objects that you write in your program are known at compile time.
/// Meaning that, when you compile your Zig source code, during the compilation process,
/// the zig compiler can figure out the exact value of a particular object that exists in your source code.
///
/// The zig compiler cares more about knowing the length (or the size) of a particular object,
/// than to know its actual value. But, if the zig compiler knows the value of the object, then,
/// it automatically knows the size of this object. Because it can simply calculate the size of the object by looking at the size of the value.
/// ### 3.1.2 Global data register
/// Every constant object whose value is known at compile time that you declare in your source code, is stored in the global data register.
/// Also, every literal value that you write in your source code, such as the string "this is a string",
/// or the integer 10, or a boolean value such as true, is also stored in the global data register.
/// This type of memory cant be controlled.
/// ### 3.1.3 Stack vs Heap
/// If you are familiar with systems programming, or just low-level programming in general,
/// you probably have heard of the “duel” between Stack vs Heap. These are two different types of memory, or different memory spaces, which are both available in Zig.
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

/// ### 3.1.4 Stack
/// https://courses.grainger.illinois.edu/cs225/fa2022/resources/stack-heap/
///
/// A Stack is a linear data structure that follows a particular order in which the operations are performed. The order may be LIFO(Last In First Out) or FILO(First In Last Out).
/// LIFO implies that the element that is inserted last, comes out first and FILO implies that the element that is inserted first, comes out last.
/// Every time you make a function call in Zig, an amount of space in the stack is reserved for this particular function call.
/// The value of each function argument given to the function in this function call is stored in this stack space.
/// Also, every local object that you declare inside the function scope is usually stored in this same stack space.
///
/// Looking at the example below, the object `result` is a local object declared inside the scope of the `add()` function.
/// Because of that, this object is stored inside the stack space reserved for the `add()` function.
/// The `r` object (which is declared outside of the add() function scope) is also stored in the stack.
/// But since it’s declared in the “outer” scope, this object is stored in the stack space that belongs to this outer scope.
///
/// Therefore any object that you declare inside the scope of a function is always stored inside the space that was reserved for that particular function in the stack memory.
/// This also counts for any object declared inside the scope of your `main()` function for example.
/// As you would expect, in this case, they are stored inside the stack space reserved for the `main()` function.
/// One very important detail about the stack memory is that **it frees itself automatically**.
/// So, once the function call returns (or ends, if you prefer to call it this way)
/// the space that was reserved in the stack is destroyed, and all of the objects that were in that space goes away with it.
///
/// One important consequence of this mechanism is that, once the function returns,
/// you can no longer access any memory address that was inside the space in the stack reserved for this particular function.
/// Because this space was destroyed. This means that, if this local object is stored in the stack, you cannot make a function that returns a pointer to this object.
/// This “invalid pointer to stack variable” problem is well known across many programming language communities. If you try to do the same thing,
/// for example, in a C or C++ program (i.e., returning an address to a local object stored in the stack), you would also get undefined behaviour in the program.
/// But what if you really need to use this local object in some way after your function returns? How can you do this?
/// The answer is: “in the same way you would do if this were a C or C++ program. By returning an address to an object stored in the heap”.
/// The heap memory has a much more flexible lifecycle, and allows you to get a valid pointer to a local object of a function that already returned from its scope.
fn add(x: i32, y: i32) *const i32 {
    const result = x + y;
    return &result;
}
fn stack_memory() !void {
    // This code compiles successfully. But it has
    // undefined behaviour. Never do this!!!
    // The `r` object is undefined!
    const r = add(5, 27);
    _ = r;
    // std.debug.print("{d}\n", .{r.*});

    const a = [4]i32{ 1, 2, 5, 7 };
    for (a, 0..) |_, i| {
        const index = i;
        std.debug.print("index: {d} ", .{index});
    }
    // Trying to use an object that was
    // declared in the for loop scope,
    // and that does not exist anymore.
    // std.debug.print("{d}\n", .{index}); //will fail
}

/// ### 3.1.5 Heap
/// https://courses.engr.illinois.edu/cs225/fa2022/resources/stack-heap/.
///
/// One important limitation of the stack, is that, only objects whose length/size is known at compile-time can be stored in it.
/// In contrast, the heap is a much more dynamic (and flexible) type of memory.
/// It’s the perfect type of memory to use for objects whose size/length might grow during the execution of your program.
///
/// **Virtually any application that behaves as a server is a classic use case of the heap**.
/// A HTTP server, a SSH server, a DNS server, a LSP server, … any type of server.
/// In summary, a server is a type of application that runs for long periods of time, and that serves (or “deals with”) any incoming request that reaches this particular server.
///
/// The heap is a good choice for this type of system, mainly because the server does not know upfront how many requests it will receive from users, while it is active.
/// It could be a single request, 5 thousand requests, or even zero requests.
/// The server needs to have the ability to allocate and manage its memory according to how many requests it receives.
///
/// Another key difference between the stack and the heap, is that the heap is a type of memory that you, the programmer, **have complete control over**.
/// This makes the heap a more flexible type of memory, but it also makes it harder to work with.
/// Because you, the programmer, is responsible for managing everything related to it.
/// Including where the memory is allocated, how much memory is allocated, and where this memory is freed.
///
/// To store an object in the heap, you, the programmer, needs to explicitly tells Zig to do so, by using an allocator to allocate some space in the heap.
/// The majority of allocators in Zig do allocate memory on the heap.
///
/// But some exceptions to this rule are `ArenaAllocator()` and the `FixedBufferAllocator()`.
/// The `ArenaAllocator()` is a special type of allocator that works in conjunction with a second type of allocator.
/// On the other hand, the `FixedBufferAllocator()` is an allocator that works based on buffer objects created on the stack.
/// This means that the `FixedBufferAllocator()` makes allocations only on the stack.
fn heap_memory() !void {}

/// ### 3.1.6 Summary
/// In summary, the Zig compiler will use the following rules to decide where each object you declare is stored:
/// 1. every literal value (such as "this is string", 10, or true) is stored in the global data register.
/// 2. every constant object `(const)` whose value is known at compile-time is also stored in the global data register.
/// 3. every object (constant or not) whose length/size is known at compile time is stored in the stack space within its current scope.
/// 4. if an object is created with the method `alloc()` or `create()` derived from an allocator object,
///    this object is stored in the heap.
/// 5. Most of allocators available in Zig use the heap memory.`FixedBufferAllocator()` & `ArenaAllocator()` are exceptions.
fn summary() !void {}

///## 3.2 Stack overflows
/// Allocating memory on the stack is generally faster than allocating it on the heap. But this better performance comes with many restrictions.
/// We have already discussed many of these restrictions of the stack in Section 3.1.4.
/// But there is one more important limitation, which is the size of the stack itself.
///
/// The stack is limited in size. This size varies from computer to computer, and it depends on a lot of things (the computer architecture, the operating system, etc.).
/// Nevertheless, this size is usually not that big. This is why we normally use the stack to store only temporary and small objects in memory.
/// In essence, if you try to make an allocation on the stack, that is so big that exceeds the stack size limit,
/// a stack overflow happens, and your program just crashes as a result of that.
/// In other words, a stack overflow happens when you attempt to use more space than is available on the stack.
///
/// This type of problem is very similar to a buffer overflow, i.e., you are trying to use more space than is available in the “buffer object”.
/// However, a stack overflow always causes your program to crash, while a buffer overflow does not always cause your program to crash (although it often does).
/// You can see an example of a stack overflow in the example below. We are trying to allocate a very big array of u64 values on the stack.
///
/// This segmentation fault error is a result of the stack overflow that was caused by the big memory allocation made on the stack, to store the very_big_alloc object.
/// This is why very big objects are usually stored on the heap, instead of the stack.
fn stack_overflow() !void {
    var very_big_alloc: [0x16E3600]i64 = undefined;
    @memset(&very_big_alloc, 0);
}

/// ## 3.3 Allocators
/// One key aspect about Zig, is that there are “no hidden-memory allocations” in Zig.
/// What that really means, is that “no allocations happen behind your back in the standard library”.
/// This is a known problem, especially in C++. Because in C++, there are some operators that do allocate memory behind the scene, and there is no way for you to know that,
/// until you actually read the source code of these operators, and find the memory allocation calls.
/// Many programmers find this behaviour annoying and hard to keep track of.
///
/// But, in Zig, if a function, an operator, or anything from the standard library needs to allocate some memory during its execution,
/// then, this function/operator needs to receive (as input) an allocator provided by the user, to actually be able to allocate the memory it needs.
///
/// This creates a clear distinction between functions that **“do not”** from those that **“actually do”** allocate memory.
/// An example is the allocPrint() function from the Zig Standard Library.
/// With this function, you can write a new string using format specifiers. So, this function is, for example, very similar to the function sprintf() in C.
pub fn main() !void {
    switch (@as(i32, 0x3)) {
        0x1 => try comptime_known(),
        0x2 => try stack_memory(),
        0x3 => try stack_overflow(),
        else => unreachable,
    }
}
