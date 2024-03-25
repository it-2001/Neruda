use rparse::{lexer::PreprocessorError, parser::ParseError};
use runtime::Context;

const TEXT: &str = 
r##"import "#io"

use io.println;

fun main() {
    println("Hello, World!");
}
"##;

fn compile() -> Result<Context, CompileError>{
    let parser = neruda::gen_parser();
    
    let tokens = parser.lexer.lex_utf8(&TEXT)?;
    let ast = parser.parse(&tokens, &TEXT)?;

    for import in neruda::ast::find_imports(&ast, &TEXT) {
        println!("{:?}", import);
    }

    let mut context = Context::new();

    panic!("Not implemented");

    Ok(context)
}

pub enum CompileError {
    LexerError(PreprocessorError),
    ParserError(ParseError),
}

impl From<PreprocessorError> for CompileError {
    fn from(err: PreprocessorError) -> CompileError {
        CompileError::LexerError(err)
    }
}

impl From<ParseError> for CompileError {
    fn from(err: ParseError) -> CompileError {
        CompileError::ParserError(err)
    }
}

impl std::fmt::Debug for CompileError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            CompileError::LexerError(err) => write!(f, "LexerError: {:?}", err),
            CompileError::ParserError(err) => write!(f, "ParserError: {:?}", err),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let context = compile().unwrap();
    }
}
