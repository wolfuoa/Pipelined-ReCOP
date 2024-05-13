use std::collections::HashMap;

#[derive(Debug)]
pub enum OpCode {
    LDR,
}

impl OpCode {
    pub fn opcode_name(&self) -> &'static str {
        match self {
            OpCode::LDR => "LDR",
        }
    }

    pub fn from_str(input: &str) -> Option<Self> {
        match input {
            "LDR" | "ldr" => Some(OpCode::LDR),
            _ => None,
        }
    }
}

/* 
pub static opcode_map: HashMap<&str, &str> = HashMap::from([
    ("ldr", "000000"),
    ("str", "000010"),
    ("str", "000010"),
    ("jmp", "011000"),
    ("andr", "001000"),
    ("orr", "001100"),
    ("addr", "111000"),
    ("subr", "000100"),
    ("subvr", "000011"),
    ("clfz", "010000"),
    ("cer", "111100"),
    ("ceot", "111110"),
    ("seot", "111111"),
    ("noop", "110100"),
    ("sz", "010100"),
    ("ler", "110110"),
    ("ssvop", "111011"),
    ("ssop", "111010"),
    ("lsip", "110111"),
    ("dci", "101000"),
    ("dcr", "101001"),
    ("max", "011110"),
    ("strpc", "011101"),
    ("sres", "101010"),
]);
*/
