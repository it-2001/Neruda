use serde::{Serialize, Deserialize};


/// Context for Neruda VM
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Context {
    pub memory: Memory,
    pub executor: Executor,
}

impl Context {
    pub fn new() -> Context {
        Context {
            memory: Memory {
                stack: Stack {
                    data: vec![],
                    frames: vec![],
                    frame_pointer: 0,
                },
                heap: Heap {
                    data: vec![],
                    objects: vec![],
                },
                registers: Registers {
                    data: [Value::Int(0); 12],
                },
                strings: Strings {
                    data: vec![],
                },
                module: Module {
                    functions: vec![],
                    classes: vec![],
                    closures: vec![],
                },
            },
            executor: Executor {
                instructions: vec![],
                instruction_pointer: 0,
            },
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Memory {
    pub stack: Stack,
    pub heap: Heap,
    pub registers: Registers,
    pub strings: Strings,
    pub module: Module,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Stack {
    pub data: Vec<Value>,
    pub frames: Vec<StackFrame>,
    pub frame_pointer: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct StackFrame {
    pub start: u64,
    pub end: u64,
    pub function_id: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Heap {
    pub data: Vec<Value>,
    /// Objects are used for storing heap data
    pub objects: Vec<Object>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub struct Object {
    pub start: u64,
    pub end: u64,
    pub id: u64,
    pub kind: ObjectKind,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum ObjectKind {
    Class,
    Array,
    Tuple,
    Singleton,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Registers {
    /// Registers are used for storing temporary data
    /// for faster access.
    /// 
    /// First half of the registers are used for storing
    /// frequently used long lived data.
    /// 
    /// Second half of the registers are used for storing
    /// temporary data for span of 1 or 2 instructions.
    /// 
    /// If a function is called then the first half of the
    /// registers may be cloned to the stack to preserve
    /// the data.
    pub data: [Value; 12],
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Strings {
    pub data: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Executor {
    pub instructions: Vec<Instructions>,
    pub instruction_pointer: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Function {
    /// Unique identifier for the function
    /// 
    /// This is also index of the function in the
    /// function table.
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Class {
    /// Unique identifier for the class
    /// 
    /// This is also index of the class in the
    /// class table.
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Closure {
    /// Unique identifier for the closure
    /// 
    /// This is also index of the closure in the
    /// closure table.
    pub id: u64,
    pub created_by: u64,
    pub called_by: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Module {
    pub functions: Vec<Function>,
    pub classes: Vec<Class>,
    pub closures: Vec<Closure>,
}



#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum Instructions {

}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum Value {
    // -- Primitive types --
    Int(i64),
    Float(f64),
    Char(char),
    Bool(bool),
    Uint(u64),
    // -- Pointer types --
    Heap(u64),
    Stack(u64),
    String(u64),
    Userdata(u64),
    // -- Identifier types --
    Function(u64),
    Class(u64),
}



#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
    }
}
