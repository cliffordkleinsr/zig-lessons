const std = @import("std");
const User = @import("structs/user.zig").User;
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
/// An example is the `allocPrint()` function from the Zig Standard Library.
/// With this function, you can write a new string using format specifiers. So, this function is, for example, very similar to the function `sprintf()` in C.
/// In order to write such a new string, the `allocPrint()` function needs to allocate some memory to store the output string.
///
/// That is why, the first argument of this function is an allocator object that you, the user/programmer, gives as input to the function.
/// In the example below, we use the `GeneralPurposeAllocator()` as an allocator object.
/// But we could easily use any other type of allocator object from the Zig Standard Library.
///
/// You get a lot of control over where and how much memory this function can allocate.
/// Because it is you, the user/programmer, that provides the allocator for the function to use.
/// This makes “total control” over memory management easier to achieve in Zig.
///
/// ### 3.3.1 What are allocators?
/// Allocators in Zig are objects that you can use to allocate memory for your program.
/// They are similar to the memory allocating functions in C, like `malloc()` and `calloc()`.
/// Zig offers different types of allocators, and they are usually available through the `std.heap` module of the standard library.
///
/// Furthermore, every allocator object is built on top of the Allocator interface in Zig.
/// This means that, every allocator object you find in Zig may have the methods `alloc()`, `create()`, `free()` and `destroy()`
///
/// ### 3.3.2 Why you need an allocator?
/// Everytime you make a function call in Zig, a space in the stack is reserved for this function call.
/// But the stack has a key limitation which is: every object stored in the stack has a known fixed length.
///
/// But in reality, there are two very common instances where this “fixed length limitation” of the stack is a deal braker:
/// 1. The objects that you create inside your function might grow in size during the execution of the function.
/// 2. Sometimes, it’s impossible to know upfront how many inputs you will receive, or how big this input will be.
///
/// Also, there is another instance where you might want to use an allocator, which is when you want to write a function that returns a pointer to a local object.
/// As described in Section 3.1.4, you cannot do that if this local object is stored in the stack.
/// However, if this object is stored in the heap, then, you can return a pointer to this object at the end of the function.
/// Because you (the programmer) control the lifetime of any heap memory that you allocate. You decide when this memory gets destroyed/freed.
///
/// ### 3.3.3 The different types of allocators
/// Zig contains the following types of allocators:
/// - `GeneralPurposeAllocator`.
/// - `page_allocator`.
/// - `FixedBufferAllocator` and `ThreadSafeFixedBufferAllocator`.
/// - `ArenaAllocator`.
/// - `c_allocator` and `raw_c_allocator`.
/// - `FailingAllocator`.
/// - `DebugAllocator`.
/// - `smp_allocator`.
/// - `wasm_allocator`.
fn allocated_printer() !void {
    var std_buffer: [0x40]u8 = undefined;
    var std_writer = std.fs.File.stdout().writer(&std_buffer);
    const stdout = &std_writer.interface;
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const name: []const u8 = "Babana";

    const output = try std.fmt.allocPrint(allocator, "Hello {s}\n", .{name}); //allocates a heap buffer.
    defer allocator.free(output); // releases it.
    try stdout.print("{s}", .{output});
    try stdout.flush();
}

/// ### 3.3.4 General-purpose allocators
/// The `GeneralPurposeAllocator()`, as the name suggests, is a “general purpose” allocator. You can use it for every type of task.
/// It can be used to detect double frees and memory leaks. In the example below, we are allocating enough space to store a single integer in the object `some_number`.
///
/// While useful, you might want to use the `c_allocator`, which is a alias to the C standard allocator `malloc()`.
/// If you do use `c_allocator`, you must link to Libc when compiling your source code with the zig compiler, by including the flag `-lc` in your compilation process.
/// If you do not link your source code to Libc, Zig will not be able to find the malloc() implementation in your system.
fn gpa_allocator() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();
    const some_number = try allocator.create(i32);
    defer allocator.destroy(some_number);

    some_number.* = @as(i32, 45);

    std.debug.print("some_number = {d}\n", .{some_number.*});
}
/// ### 3.3.5 Page allocator
/// The `page_allocator` is an allocator that allocates full pages of memory in the heap.
/// In other words, every time you allocate memory with `page_allocator`, a full page of memory in the heap is allocated, instead of just a small piece of it.
///
/// The size of this page depends on the system you are using. eg. The default memory page size of the Linux kernel on x86 architecture was 4 KB.
/// Most systems use a page size of 4KB in the heap, so, that is the amount of memory that is normally allocated in each call by `page_allocator`.
/// The, `page_allocator` is considered a fast, but also “wasteful” allocator in Zig.
/// Because it allocates a big amount of memory in each call, and you most likely will not need that much memory in your program.
///
/// see section 2.6 of `chap_two` module for an example
///
/// ### 3.3.6 Buffer allocators
/// The `FixedBufferAllocator()` and `ThreadSafeFixedBufferAllocator()` are allocator objects that work with a fixed sized buffer object.
/// In other words, they use a fixed sized buffer object as the basis for the memory.
/// When you ask these allocator objects to allocate some memory for you,
/// they are essentially reserving some amount of space inside this fixed sized buffer object for you to use.
///
/// This means that, in order to use these allocators, you must first create a buffer object in your code, and then, give this buffer object as an input to these allocators.
/// This also means that, these allocator objects can allocate memory both in the stack or in the heap.
/// Everything depends on where the buffer object that you provide lives. If this buffer object lives in the stack, then, the memory allocated is “stack-based”.
/// But if it lives on the heap, then, the memory allocated is “heap-based”.
///
/// In the example below, we create a buffer object on the stack that is 10 elements long.
/// We give this buffer object to the FixedBufferAllocator() constructor. Since this buffer object is 10 elements long, this means that we are limited to this space.
/// We cannot allocate more than 10 elements with this allocator object. If we try to allocate more than that, the `alloc()` method will return an OutOfMemory error value.
///
fn stack_fba_allocator() !void {
    var buffer: [0xA]u8 = undefined;
    for (buffer, 0..) |_, i| {
        buffer[i] = 0; // Initialize to zero
        std.debug.print("{d} ", .{i});
    }
    std.debug.print("\n", .{});
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const input = try allocator.alloc(u8, 5);
    std.debug.print("len of input: {d}\n", .{input.len});
    defer allocator.free(input);
}
/// In the example above, the buffer object lives in the stack, and, therefore, the memory allocated is based in the stack.
/// But what if it was based on the heap? As we described in Section 3.2, one of the main reasons why you would use the heap, instead of the stack,
/// is to allocate huge amounts of space to store very big objects. Thus, let’s suppose you wanted to use a very big buffer object as the basis for your allocator objects.
/// You would have to allocate this very big buffer object on the heap. The example below demonstrates this case.
fn heap_fba_allocator() !void {
    const heap = std.heap.page_allocator;
    const memory_buffer = try heap.alloc(u8, 0x6400000); // 100 MB memory
    defer heap.free(memory_buffer);
    var fba = std.heap.FixedBufferAllocator.init(memory_buffer);
    const allocator = fba.allocator();

    const input = try allocator.alloc(u8, 1000);
    defer allocator.free(input);

    std.debug.print("len of input {d}\n", .{input.len});
}

/// ### 3.3.7 Arena allocator
/// The `ArenaAllocator()` is an allocator object that takes a child allocator as input.
/// The idea behind the `ArenaAllocator()` in Zig is similar to the concept of “arenas” in the programming language [Go](https://go.dev/src/arena/arena.go).
/// The `ArenaAllocator()` is an allocator object that allows you to allocate memory as many times you want, but free all memory only once.
/// In other words, if you have for example called the `alloc()` method 5 times, you can free all the memory you allocated over these 5 calls at once,
/// by simply calling the `deinit()` method of the same `ArenaAllocator()` object.
///
/// If you, for example, give a `GeneralPurposeAllocator()` as input to an `ArenaAllocator()`constructor, like in the example below,
/// then, the allocations you perform with `alloc()` will actually be made with the underlying object `GeneralPurposeAllocator()` that was passed.
/// So, with an arena allocator, any new memory you ask for is allocated by the child allocator.
/// The only thing that an arena allocator really does is help you to free all the memory you allocated multiple times with just a single command.
/// In the example below we call `alloc()` 3 times. Therefore, if we did not use an arena allocator then we would need to call `free()` 3 times to free all the allocated memory.
fn arena_allocator() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    var aa = std.heap.ArenaAllocator.init(gpa.allocator());
    defer {
        aa.deinit();
        std.debug.print("Arena deallocated child allocators", .{});
    }

    const allocator = aa.allocator();

    const in1 = try allocator.alloc(u8, 5);
    const in2 = try allocator.alloc(u8, 10);
    const in3 = try allocator.create(u8);
    _ = in1;
    _ = in2;
    _ = in3;
}

/// ### 3.3.8 The `alloc()` and `free()` methods
/// In the code example below, we are accessing the `stdin`, which is the standard input channel, to receive an input from the user.
/// We read the input given by the user with the `readSliceAll()` method.
/// We use the `defer` keyword from Section 2.1.3 to run a small piece of code at the end of the current scope, which is the expression `allocator.free(input)`.
/// When you execute this expression, the allocator will free the memory that it allocated for the input object.
///
/// You should **always explicitly free any memory that you allocate using an allocator!**
/// You do that by using the `free()` method of the same allocator object you used to allocate this memory.
/// The `defer` keyword is used in this example only to help us execute this free operation at the end of the current scope.
fn multi_allocator_operations() !void {
    //stdout interface
    var stdout_buffer: [0x400]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    //stdin interface
    var stdin_buffer: [0x400]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    // gpa setup
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var input = try allocator.alloc(u8, 7);
    defer allocator.free(input);
    @memset(input[0..], 0); // Initialize memory to zero

    try stdout.writeAll("Enter your input: ");
    try stdout.flush(); //dump the stream
    // Read user input
    try stdin.readSliceAll(input[0..]); //input 7 chars like twinkle
    try stdout.print("Your input was: {s}\n", .{input});
    try stdout.flush();
}
/// ### 3.3.9 The `create()` and `destroy()` methods.
/// With the `alloc()` and `free()` methods, you can allocate memory to store multiple elements at once and conversantly free this memory address once done.
/// But what if you need enough space to store just a single item? Should you allocate an array of a single element through `alloc()`?
/// The answer is **no!** In this case, you should use the `create()` method of the allocator object.
/// Every allocator object offers the `create()` and `destroy()` methods, which are used to allocate and free memory for a single item, respectively.
///
/// In the example below we reuse the User struct we created in Section 2.3 of chap_two.
/// We use the `create()` method this time, to store a single User object in the program and
/// conversantly `destroy()` method to free the memory used by this object at the end of the scope.
/// This example could be a user for a game, or software to manage resources, it doesn’t matter.
fn single_allocator_operations() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const user = try allocator.create(User);
    defer allocator.destroy(user);

    user.* = User.init(1, "Babana", "babana@gmail.com");

    std.debug.print("New user with name {s} created!\n", .{user.*.name});
}
pub fn main() !void {
    switch (@as(u8, 0xA)) {
        0x1 => try comptime_known(),
        0x2 => try stack_memory(),
        0x3 => try stack_overflow(),
        0x4 => try allocated_printer(),
        0x5 => try gpa_allocator(),
        0x6 => try stack_fba_allocator(),
        0x7 => try heap_fba_allocator(),
        0x8 => try arena_allocator(),
        0x9 => try multi_allocator_operations(),
        0xA => try single_allocator_operations(),
        else => unreachable,
    }
}
