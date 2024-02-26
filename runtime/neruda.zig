//! The Neruda programming language VM
//!
//! It is written in Zig and is designed as typed alternative to common scripting languages.

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
    /// The stack data
    data: *[]Value,
};
// -- Memory --

// -- Instructions --
pub const InstructionReader = extern struct {
    /// The instruction pointer
    ip: u64,
    /// The instructions
    instructions: *[]u64,
};

/// The instruction set of the VM
///
/// The instructions are encoded as a 64-bit integer
/// followed by the arguments of the instruction
pub const Instructions = enum(u64) {
    // -- Stack manipulation --
    /// Write a value to the stack
    /// (reg: u8, position: u32)
    /// value from register[reg] is written to the stack[stack.sp - position]
    Write = 1,
    /// Read a value from the stack
    /// (reg: u8, position: u32)
    /// value is read from the stack[stack.sp - position] and written to register[reg]
    Read = 2,
    /// Write a value from pointer to the stack
    /// (reg: u8, position: u32)
    /// value that is pointed to by ptr at register[reg] is written to the stack[stack.sp - position]
    WritePtr = 3,
    /// Read a value from the ptr and write it to the register
    /// (ptr_reg: u8, value_reg: u8)
    /// value that is pointed to by ptr at register[ptr_reg] is written to register[value_reg]
    ReadPtr = 4,
    /// Write const
    /// (reg: u8, value: Value)
    /// value is written to the stack[stack.sp - register[reg]]
    WriteConst = 5,
    // -- Stack manipulation --

    // -- Arithmetic --
    /// Add two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddInt = 6,
    /// Subtract two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] - register[reg3]
    SubInt = 7,
    /// Multiply two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] * register[reg3]
    MulInt = 8,
    /// Divide two integers
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] / register[reg3]
    DivInt = 9,
    /// Modulo two integers¨
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] % register[reg3]
    ModInt = 10,

    /// Add two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddFloat = 11,
    /// Subtract two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] - register[reg3]
    SubFloat = 12,
    /// Multiply two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] * register[reg3]
    MulFloat = 13,
    /// Divide two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] / register[reg3]
    DivFloat = 14,
    /// Modulo two floats
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] % register[reg3]
    ModFloat = 15,

    /// Pointer arithmetic (integer)
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] + register[reg3]
    AddPtr = 16,

    /// Compare two integers for equality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] == register[reg3]
    CmpIntEq = 17,
    /// Compare two integers for inequality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] != register[reg3]
    CmpIntNe = 18,
    /// Compare two integers for less than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] < register[reg3]
    CmpIntLt = 19,
    /// Compare two integers for less than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] <= register[reg3]
    CmpIntLe = 20,
    /// Compare two integers for greater than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] > register[reg3]
    CmpIntGt = 21,
    /// Compare two integers for greater than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] >= register[reg3]
    CmpIntGe = 22,

    /// Compare two floats for equality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] == register[reg3]
    CmpFloatEq = 23,
    /// Compare two floats for inequality
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] != register[reg3]
    CmpFloatNe = 24,
    /// Compare two floats for less than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] < register[reg3]
    CmpFloatLt = 25,
    /// Compare two floats for less than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] <= register[reg3]
    CmpFloatLe = 26,
    /// Compare two floats for greater than
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] > register[reg3]
    CmpFloatGt = 27,
    /// Compare two floats for greater than or equal
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] >= register[reg3]
    CmpFloatGe = 28,
    // -- Arithmetic --

    // -- Boolean logic --
    /// Logical AND
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] && register[reg3]
    And = 29,
    /// Logical OR
    /// (reg1: u8, reg2: u8, reg3: u8)
    /// register[reg1] = register[reg2] || register[reg3]
    Or = 30,
    /// Logical NOT
    /// (reg1: u8, reg2: u8)
    /// register[reg1] = !register[reg2]
    Not = 31,
    // -- Boolean logic --

    // -- Control flow --
    /// Go to the instruction at the given position
    /// (position: u64)
    /// This will only set the instruction pointer to the given position
    /// and will not change the stack or any other state
    Goto = 32,
    /// Go to the instruction at the given position if the value is true
    /// (position: u64, reg: u8)
    /// If register[reg] is true, the instruction pointer is set to the given position
    GotoIf = 33,
    /// Go to the instruction one of the two positions depending on the boolean value
    /// (position1: u64, position2: u64, reg: u8)
    /// If register[reg] is true, the instruction pointer is set to position1
    /// If register[reg] is false, the instruction pointer is set to position2
    GotoBranch = 34,
    // -- Control flow --

    // -- Function calls --
    /// Call a function
    /// (position: u64)
    /// This will push the current instruction pointer to the stack and set the instruction pointer to the given position
    Call = 35,
    /// Return from a function
    /// ()
    /// This will pop the last instruction pointer from the stack and set the instruction pointer to that value
    Return = 36,
    /// Reserve space for next function frame
    /// (size: u64)
    /// This will reserve space for the next function frame on the stack
    Reserve = 37,
    /// Release space for the current function frame
    /// ()
    /// This will release space for the current function frame on the stack
    Release = 38,
    // -- Function calls --

    // -- Memory management --
    /// Allocate static
    /// (size: u64, reg: u8)
    /// This will allocate compile known amount of memory and write the pointer to register[reg]
    AllocStatic = 39,
    /// Allocate dynamic
    /// (size_reg: u8, reg: u8)
    /// This will allocate dynamic amount of memory read from register[size_reg] and write the pointer to register[reg]
    AllocDynamic = 40,
    /// Free memory
    /// (reg: u8)
    /// This will free the memory that is pointed to by register[reg]
    Free = 41,
    // -- Memory management --

    // -- interface --
    /// Runtime call
    /// (id: u32, call: u32)
    /// This will break the execution and ask the runtime to handle the call
    RuntimeCall = 42,
    /// End
    /// ()
    /// This will break the execution and return to the runtime
    End = 43,
    // -- interface --
};
// -- Instructions --

// -- registers --
/// The registers of the VM
///
/// The registers are used to store temporary values
pub const Registers = extern struct {
    /// The general purpose registers
    general: [3]Value,
    /// The VM helper registers
    helper: [3]Value,
    /// The memory registers
    memory: [3]Value,
    /// The return register
    ret: Value,
};
// -- registers --

// -- VM --
/// Contains the whole state of the VM
pub const VM = extern struct {
    /// The memory of the VM
    memory: Memory,
    /// The instruction reader
    reader: InstructionReader,
    /// The registers of the VM
    registers: Registers,
};

/// The runtime of the VM
/// This is the main entry point for the VM
export fn run(ctx: *VM) RuntimeReturnCode {
    while (false) {
        const i: Instructions = @enumFromInt(ctx.reader.instructions.*[ctx.reader.ip]);
        switch (i) {
            Instructions.End => {
                return RuntimeReturnCode.Success;
            },
            Instructions.Write => {
                const reg = ctx.reader.instructions.*[ctx.reader.ip + 1];
                const position = ctx.reader.instructions.*[ctx.reader.ip + 2];
                ctx.memory.stack.data.*[ctx.memory.stack.sp - position] = ctx.registers.general[reg];
                ctx.reader.ip += 3;
            },
            Instructions.Read => {},
            Instructions.WritePtr => {},
            Instructions.ReadPtr => {},
            Instructions.WriteConst => {},
            Instructions.AddInt => {},
            Instructions.SubInt => {},
            Instructions.MulInt => {},
            Instructions.DivInt => {},
            Instructions.ModInt => {},
            Instructions.AddFloat => {},
            Instructions.SubFloat => {},
            Instructions.MulFloat => {},
            Instructions.DivFloat => {},
            Instructions.ModFloat => {},
            Instructions.AddPtr => {},
            Instructions.CmpIntEq => {},
            Instructions.CmpIntNe => {},
            Instructions.CmpIntLt => {},
            Instructions.CmpIntLe => {},
            Instructions.CmpIntGt => {},
            Instructions.CmpIntGe => {},
            Instructions.CmpFloatEq => {},
            Instructions.CmpFloatNe => {},
            Instructions.CmpFloatLt => {},
            Instructions.CmpFloatLe => {},
            Instructions.CmpFloatGt => {},
            Instructions.CmpFloatGe => {},
            Instructions.And => {},
            Instructions.Or => {},
            Instructions.Not => {},
            Instructions.Goto => {},
            Instructions.GotoIf => {},
            Instructions.GotoBranch => {},
            Instructions.Call => {},
            Instructions.Return => {},
            Instructions.Reserve => {},
            Instructions.Release => {},
            Instructions.AllocStatic => {},
            Instructions.AllocDynamic => {},
            Instructions.Free => {},
            Instructions.RuntimeCall => {},
        }
    }
    return RuntimeReturnCode.Success;
}
// -- VM --

// -- interface --
/// The runtime return code
/// This is used to communicate with the runtime
pub const RuntimeReturnCode = enum(u32) {
    /// The VM exited successfully
    Success = 0,
    /// The call was not successful
    ///
    /// The error itself is stored in the VM
    Failure = 1,
    /// The VM asked for call to be handled by the runtime
    ///
    /// The call itself is stored in the VM
    Call = 2,
    /// The VM paused the execution
    ///
    /// The reason for the pause is stored in the VM
    Pause = 3,
};

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

test "run" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const stack_init_size = 1024;
    var stack_space = try allocator.alloc(Value, stack_init_size);
    defer {
        _ = gpa.deinit();
        _ = allocator.free(stack_space);
    }
    var vm = VM{
        .memory = Memory{
            .stack = Stack{ .sp = 0, .data = &stack_space },
        },
        .reader = InstructionReader{
            .ip = 0,
            .instructions = undefined,
        },
        .registers = Registers{
            .general = undefined,
            .helper = undefined,
            .memory = undefined,
            .ret = undefined,
        },
    };
    const result = run(&vm);
    try expect(result == RuntimeReturnCode.Success);
}
