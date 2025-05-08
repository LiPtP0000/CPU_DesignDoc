import re
import serial
import os
import colorama
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
    "OR":   0x0A,
    "NOT":  0x0B,
    "SHIFTR": 0x0C,
    "SHIFTL":   0x0D
}

def parse_assembly(lines):
    machine_code = []
    labels = {}
    pending = []

    # First pass: find labels
    addr = 1
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
    addr = 1
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

        if instr in ["HALT"] : # No operand, fill with 0
            opcode = MEMONICS[instr]
            operand = 0x00
        else:
            if len(tokens) < 2:
                raise ValueError(f"Missing operand in line: {line}")
            # Force MSB=1 for STORE instruction
            if instr in  ["STORE","JGZ","JMP"]:
                immediate = True
                opcode = MEMONICS[instr] | 0x80  # MSB = 1
            elif tokens[1] == "IMMEDIATE":
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

def send_to_serial(bitstream:bytearray) -> None:
    # FPGA Config: Baud rate = 115200, 8N1 Transmission
    write_port = '/dev/ttyUSB1'     # Default port
    ser = serial.Serial(
    port= write_port,
    baudrate= 115200,
    timeout=1,
    bytesize=8,
    parity= "N",
    stopbits=1
    ) 

    # 向 FPGA 发送数据
    number_of_bytes = ser.write(bitstream)  # 将字符串转换为字节并发送
    print(f"{number_of_bytes} bytes of data Write successfully")

    # 关闭串口
    ser.close()

def main(filename:str):
    os.chdir("./designs/input_src")
    file_path = f"{filename}.txt"
    if not os.path.exists(file_path):
        raise ValueError("Cannot find such file.")
    else:
        with open(file_path, 'r') as file:
            lines = file.readlines()  

    machine_words = parse_assembly(lines)
    binary = assemble_to_bytes(machine_words)

    # For Reference:
    print("\033[1;34mMachine Code:\033[0m")
    for i, word in enumerate(machine_words):
        print(f"{i+1:02}: {word:04X}")

    # For Simulation Testbench input drive:
    print("\n\033[1;34mGenerated UART Send Bitstream:\033[0m")
    for b in binary:
        bits = f"{b:08b}"          
        reversed_bits = bits[::-1]   
        print(f"uart_send_byte(8'b{reversed_bits});")
    # print(binary)
    # For FPGA Verification:
    
    # Bit reverse each byte in the binary array
    bit_reversed_binary = bytearray()
    for b in binary:
        reversed_byte = 0
        for i in range(8):
            # Extract bit at position i and place it at position (7-i)
            if b & (1 << i):
                reversed_byte |= (1 << (7-i))
        bit_reversed_binary.append(reversed_byte)
        
    # Use the bit-reversed binary for sending to serial
    binary = bit_reversed_binary
    send_to_serial(binary)


if __name__ == "__main__":
    colorama.init()
    filename = input(f"\033[1;32mPlease enter the assembly file name (without .txt): \033[0m")
    main(filename)
