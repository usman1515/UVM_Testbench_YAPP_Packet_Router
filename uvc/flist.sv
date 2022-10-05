`timescale 1ns/100ps

// -------------------------------- pre defined macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// -------------------------------- UVM Environment Channel
// -------------------------------- UVM Environment Clock and Reset
// -------------------------------- UVM Environment HBUS
// -------------------------------- UVM Environment YAPP Packet
`include "./yapp/yapp_packet.sv"

// -------------------------------- UVM tb
`include "./tb/router_tb.sv"

// --------------------------------------------------------- Sequences

// --------------------------------------------------------- Test cases
`include "../tests/router/router_base_test.sv"
`include "../tests/router/test2.sv"
