`timescale 1ns/100ps

// -------------------------------- pre defined macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// -------------------------------- UVM Environment Channel
// -------------------------------- UVM Environment Clock and Reset
// -------------------------------- UVM Environment HBUS
// -------------------------------- UVM Environment YAPP Packet
`include "./yapp/yapp_packet.sv"
`include "./yapp/yapp_packet_short.sv"
`include "./yapp/yapp_tx_sequencer.sv"
`include "./yapp/yapp_tx_driver.sv"
`include "./yapp/yapp_tx_monitor.sv"
`include "./yapp/yapp_tx_agent.sv"
`include "./yapp/yapp_env.sv"

// -------------------------------- UVM tb
`include "./tb/router_tb.sv"

// --------------------------------------------------------- Sequences
`include "../sequences/yapp/yapp_base_seq.sv"
`include "../sequences/yapp/yapp_5_packets_seq.sv"

// --------------------------------------------------------- Test cases
`include "../tests/router/router_base_test.sv"
`include "../tests/router/router_short_packet_test.sv"
`include "../tests/router/router_set_config_test.sv"
