import re

# memonics
MEMONICS = {
    "STORE":  0x01,
    "LOAD": 0x02,
    "ADD":   0x03,
    "SUB":   0x04,
    "JGZ":   0x05,
    "JMP":  0x06,
    "HALT":  0x07,
    "MPY":  0x08,
    "AND":  0x09,
    "OR":   0x10,
    "NOT":  0x11,
    "SHIFTR": 0x12,
    "SHIFTL":   0x13
}

def parse_assembly(lines):
    machine_code = []
    labels = {}
    pending = []

    # First pass: find labels
    addr = 0
    for line in lines:
        line = line.split(';')[0].strip()  # clear comments
        if not line:
            continue
        if ':' in line:
            label, rest = map(str.strip, line.split(':', 1))
            labels[label] = addr
            if rest:
                addr += 1
        else:
            addr += 1

    # Second pass: generate code
    addr = 0
    for line in lines:
        line = line.split(';')[0].strip()
        if not line:
            continue
        if ':' in line:
            parts = line.split(':', 1)
            line = parts[1].strip()
            if not line:
                continue

        tokens = line.split()
        if not tokens:
            continue

        instr = tokens[0]
        immediate = False

        if instr in ["HALT","SHIFTR","SHIFTL"] : # No operand, fill with 0
            opcode = MEMONICS[instr]
            operand = 0x00
        else:
            if len(tokens) < 2:
                raise ValueError(f"Missing operand in line: {line}")

            if tokens[1] == "IMMEDIATE":
                immediate = True
                operand_str = tokens[2]
                opcode = MEMONICS[instr] | 0x80  # MSB = 1
            else:
                operand_str = tokens[1]
                opcode = MEMONICS[instr]  # MSB = 0

            if operand_str.isdigit():
                operand = int(operand_str)
            elif operand_str in labels:
                operand = labels[operand_str]
            else:
                try:
                    operand = int(operand_str, 0)  # Support 0x form operand
                except:
                    raise ValueError(f"Unknown operand: {operand_str}")

        if operand < 0 or operand > 255:
            raise ValueError(f"Operand out of 8-bit range: {operand}")

        machine_code.append((opcode << 8) | operand)
        addr += 1

    return machine_code


def assemble_to_bytes(code: list[int]) -> bytearray:
    result = bytearray()
    for word in code:
        result.append((word >> 8) & 0xFF)  # opcode
        result.append(word & 0xFF)         # operand
    return result


if __name__ == "__main__":
    # 示例程序：从1加到100
    asm_code = """
      LOAD IMMEDIATE 0
      STORE 1
      LOAD IMMEDIATE 1
      STORE 2
    LOOP: LOAD 1
      ADD 2
      STORE 1
      LOAD 2
      ADD IMMEDIATE 1
      STORE 2
      SUB IMMEDIATE 100
      JGZ LOOP
      HALT
    """

    lines = asm_code.strip().split('\n')
    machine_words = parse_assembly(lines)
    binary = assemble_to_bytes(machine_words)

    # 打印每条机器码（16位）和最终二进制流
    print("机器码:")
    for i, word in enumerate(machine_words):
        print(f"{i:02}: {word:04X}")

    print("\n二进制比特流:")
    print(" ".join(f"{b:08b}" for b in binary))
    print("\nUART传输流:")
    print("".join(f"0{b:08b}1" for b in binary))

    
