mod opcodes;

use std::env;
use std::fs;

struct Instruction {
    addressing_mode: String,
    opcode: String,
    rz: String,
    rx: String,
    operand: String,
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = &args[1];

    println!("The file {} was opened", file_path);

    for line in fs::read_to_string(file_path).unwrap().lines() {
        println!("Current line is {}", line);
        let mut cursor = line.split_whitespace();

        if cursor.next().is_some() {
            println!("Has next");
        }

        // Register
        if cursor.next().is_some() {
            println!("Has next");
        }

        // Immediate / Register
        if cursor.next().is_some() {
            println!("Has next");
        }
    }
}
