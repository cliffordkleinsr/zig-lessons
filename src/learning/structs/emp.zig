const std = @import("std");
/// # Stack vs Heap Memory Allocation
/// A gentle comparison between heap & stack memory implementations in both C++ & Zig.
/// C++ code can be found here: https://www.geeksforgeeks.org/dsa/stack-vs-heap-memory-allocation/.
///
/// ## In C++
/// When the program starts, all runtime classes are stored in heap memory.
/// The main method is stored in stack memory along with its local variables and reference variables.
/// The reference variable Emp of type init is stored in the stack and points to the corresponding object in heap memory.
/// The parameterized constructor `Emp(int, string)` is invoked from main, and its execution is allocated at the top of the stack.
/// When Emp class object is called from main, a new stack frame is created on top of the previous stack frame.
/// The newly created `Emp_detail()` object and all its instance variables are stored in heap memory.
const cpp_employee_object =
    \\#include <bits/stdc++.h;
    \\using namespace std;
    \\class Emp {
    \\public:
    \\    int id;
    \\    string emp_name;
    \\
    \\    Emp(int id, string emp_name) {
    \\      this ->id = id;
    \\      this ->emp_name =emp_name;
    \\    }
    \\};
    \\Emp Emp_detail(int id, string emp_name) {
    \\    return Emp(id, emp_name);
    \\}
    \\int main() {
    \\    int id = 21;
    \\    string name = "Maddy";
    \\
    \\
    \\    Emp person_ = Emp_detail(id, name);
    \\    
    \\    return 0;
    \\}
;

/// ## in Zig
/// Zig doesn’t have hidden heap allocations. When you do: `const employee = Emp.init(id, name);` `employee` is a stack value, not a heap object.
/// Zig has no classes or implicit heap storage for “instances.” Structs are just plain values.
/// If you want to implicitly set the Emp struct on the heap, you must explicitly allocate it with an allocator.
const Emp = struct {
    id: i32,
    emp_name: []const u8,
    // Constructor to initialize employee details
    fn init(id: i32, emp_name: []const u8) Emp {
        return Emp{ .id = id, .emp_name = emp_name };
    }
    fn print_emp(self: Emp) void {
        std.debug.print("New Employee created: {s}\n", .{self.emp_name});
    }
};

pub fn main() !void {
    // Initializing employee details
    const id: i32 = 21;
    const name: []const u8 = "Maddy";
    // Creating an Emp object using the function
    const employee = Emp.init(id, name);

    employee.print_emp();
}
