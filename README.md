# CPU_Design
 DesignDoc & Project for 16-bit CPU Project (Course Project of *Computer Organization and Architecture II* in Southeast University). 
 
 **Doc Usage**: It is using *ElegantPaper* Template. Compilation using xelatex and biber. A pdf version is also provided in this repo (Recommended).
 
 **Project Development**: It is developed and tested under NEXYS 4 DDR FPGA board and Xilinx Vivado 2024.2 on Linux platform.

 ## Features
 - [x] No IP Cores
 - [x] Support for given ISA
 - [x] Check current PC/Opcode, flags and 32-bit results when pressing specific button
 - [x] 32-bit arithmetic calculation, flags update and storage to memory, including `ADD`, `SUB` and `MPY` instructions
 - [x] Feed self-defined Assembly code to board via UART/FIFO
 - [ ] Shutdown and Exception Functions
 - [ ] 32-bit logic calculation
 - [ ] More user-friendly result display  
