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
`include "../sequences/yapp/yapp_5_pkt_seq.sv"
`include "../sequences/yapp/yapp_addr_1_seq.sv"
`include "../sequences/yapp/yapp_addr_012_seq.sv"
`include "../sequences/yapp/yapp_3_pkt_addr_1_seq.sv"
`include "../sequences/yapp/yapp_2_pkt_repeat_addr_seq.sv"
`include "../sequences/yapp/yapp_incr_payload_seq.sv"
`include "../sequences/yapp/yapp_random_count_pkt_seq.sv"
`include "../sequences/yapp/yapp_6_pkt_seq.sv"
`include "../sequences/yapp/yapp_exhaustive_seq.sv"

// --------------------------------------------------------- Test cases
`include "../tests/router/router_base_test.sv"
`include "../tests/router/router_short_packet_test.sv"
`include "../tests/router/router_set_config_test.sv"
`include "../tests/router/router_incr_payload_test.sv"
`include "../tests/router/router_exhaustive_test.sv"