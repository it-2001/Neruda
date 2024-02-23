//! The Neruda programming language VM
//!
//! It is written in Zig and is designed to typed alternative to common scripting languages.

// -- Types --
/// The value type that can be stored in a memory cell
pub const Value = extern union {
    // -- Primitive types --
    /// A boolean value
    bool: bool,
    /// An integer value
    int: i64,
    /// A floating point value
    float: f64,
    // -- Primitive types --

    // -- Heap allocated types --
    /// A string
    string: u64,
    /// An object or array
    object: u64,
    /// Userdata instance
    userdata: u64,
    // -- Heap allocated types --

    // -- Special types --
    /// A control integer
    control: ControlInt,
    // -- Special types --
};

/// This will always be the first index in any kind of complex value
pub const ControlInt = extern struct {
    /// The type of the control integer
    type: ControlIntType,
    /// The value of the control integer
    value: u32,
};

/// Defines the type of a control integer
pub const ControlIntType = enum(u8) {
    /// The control integer is a reference to an object
    Object = 1,
    /// The control integer is a reference to an array
    Array = 2,
    /// The control integer is a reference to a tuple
    Tuple = 3,
};
// -- Types --

// -- Memory --
/// The memory of the VM
pub const Memory = extern struct {
    /// Stack memory
    stack: Stack,
};

/// The stack of the VM
pub const Stack = extern struct {
    /// The stack pointer
    sp: u64,
    /// The stack size
    size: u64,
    /// The stack data
    data: [Value]u64,
};
// -- Memory --

// -- Instructions --
/// The instruction set of the VM
pub const Instructions = enum(u8) {
    // -- Stack manipulation --
    /// Write a value to the stack
    /// (reg: u8, position: u32)
    /// value from register[reg] is written to the stack[stack.sp - position]
    Write,
    /// Read a value from the stack
    /// (reg: u8, position: u32)
    /// value is read from the stack[stack.sp - position] and written to register[reg]
    Read,
    /// Write a value from pointer to the stack
    /// (reg: u8, position: u32)
    /// value that is pointed to by ptr at register[reg] is written to the stack[stack.sp - position]
    WritePtr,
    /// Read a value from the ptr and write it to the register
    /// (ptr_reg: u8, value_reg: u8)
    /// value that is pointed to by ptr at register[ptr_reg] is written to register[value_reg]
    ReadPtr,
    // -- Stack manipulation --

    // -- Arithmetic --
    /// Add two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddInt,
    /// Subtract two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] - register[reg3]
    SubInt,
    /// Multiply two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] * register[reg3]
    MulInt,
    /// Divide two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] / register[reg3]
    DivInt,
    /// Modulo two integers¨
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] % register[reg3]
    ModInt,

    /// Add two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddFloat,
    /// Subtract two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] - register[reg3]
    SubFloat,
    /// Multiply two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] * register[reg3]
    MulFloat,
    /// Divide two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] / register[reg3]
    DivFloat,
    /// Modulo two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] % register[reg3]
    ModFloat,

    /// Pointer arithmetic (integer)
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddPtr,

    /// Compare two integers for equality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] == register[reg3]
    CmpIntEq,
    /// Compare two integers for inequality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] != register[reg3]
    CmpIntNe,
    /// Compare two integers for less than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] < register[reg3]
    CmpIntLt,
    /// Compare two integers for less than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] <= register[reg3]
    CmpIntLe,
    /// Compare two integers for greater than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] > register[reg3]
    CmpIntGt,
    /// Compare two integers for greater than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] >= register[reg3]
    CmpIntGe,

    /// Compare two floats for equality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] == register[reg3]
    CmpFloatEq,
    /// Compare two floats for inequality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] != register[reg3]
    CmpFloatNe,
    /// Compare two floats for less than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] < register[reg3]
    CmpFloatLt,
    /// Compare two floats for less than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] <= register[reg3]
    CmpFloatLe,
    /// Compare two floats for greater than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] > register[reg3]
    CmpFloatGt,
    /// Compare two floats for greater than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] >= register[reg3]
    CmpFloatGe,
    // -- Arithmetic --

    // -- Boolean logic --
    /// Logical AND
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] && register[reg3]
    And,
    /// Logical OR
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] || register[reg3]
    Or,
    /// Logical NOT
    /// (reg1: u8, reg2: u8)
    /// register[reg1] = !register[reg2]
    Not,
    // -- Boolean logic --

    // -- Control flow --
    /// Go to the instruction at the given position
    /// (position: u64)
    /// This will only set the instruction pointer to the given position
    /// and will not change the stack or any other state
    Goto,
    /// Go to the instruction at the given position if the value is true
    /// (position: u64, reg: u8)
    /// If register[reg] is true, the instruction pointer is set to the given position
    GotoIf,
    /// Go to the instruction one of the two positions depending on the boolean value
    /// (position1: u64, position2: u64, reg: u8)
    /// If register[reg] is true, the instruction pointer is set to position1
    /// If register[reg] is false, the instruction pointer is set to position2
    GotoBranch,
    // -- Control flow --

    // -- Function calls --
    /// Call a function
    /// (position: u64)
    /// This will push the current instruction pointer to the stack and set the instruction pointer to the given position
    Call,
    /// Return from a function
    /// ()
    /// This will pop the last instruction pointer from the stack and set the instruction pointer to that value
    Return,
    /// Reserve space for next function frame
    /// (size: u64)
    /// This will reserve space for the next function frame on the stack
    Reserve,
    /// Release space for the current function frame
    /// ()
    /// This will release space for the current function frame on the stack
    Release,
    // -- Function calls --

    // -- Memory management --
    /// Allocate static
    /// (size: u64, reg: u8)
    /// This will allocate compile known amount of memory and write the pointer to register[reg]
    AllocStatic,
    /// Allocate dynamic
    /// (size_reg: u8, reg: u8)
    /// This will allocate dynamic amount of memory read from register[size_reg] and write the pointer to register[reg]
    AllocDynamic,
    /// Free memory
    /// (reg: u8)
    /// This will free the memory that is pointed to by register[reg]
    Free,
    // -- Memory management --
};
// -- Instructions --

// -- VM --
/// Contains the whole state of the VM
pub const VM = extern struct {
    /// The memory of the VM
    memory: Memory,
    /// The instruction pointer
    ip: u64,
};
// -- VM --

const std = @import("std");
const expect = std.testing.expect;

test "sizes" {
    const size = @sizeOf(Value);
    const expected = 8;
    try std.testing.expectEqual(size, expected);

    const size2 = @sizeOf(ControlInt);
    const expected2 = 8;
    try std.testing.expectEqual(size2, expected2);

    const size3 = @sizeOf(ControlIntType);
    const expected3 = 1;
    try std.testing.expectEqual(size3, expected3);
}
