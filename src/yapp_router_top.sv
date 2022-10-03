/*----------------------------------------------------------------------
File name     : yapp_router.v
Developers    : Kathleen Meade, Brian Dickinson, Lisa Barbay
Created       : 23 Jun 2009
Description   : YAPP Router RTL model
Notes         : New version properly drops packets with extra debug reporting
Updates       : LKB 10/17/2011 Added new registers to work with a register
														: Model:
														- Router_Enable for 8 enables
														- Packet register that is 6 bits not 8
														- Count Registers for Illegal Packet Addr, Max Packet Addr
														- Addr Counts, and Parity Errors
														- Works on interface level, no tests available for functionality
									- Interrupt IEN
									- Interrupt Status

									- Don't use: has not been tested in a long time
														- Reset Register (Include indiviual channenl resets, parity,
						and a full router reset)
														- Works but do not use in class -- needs more debugging

									- Last packet received RAM
														- Ram for the Last Packet Received (doesn't include parity)

2 known bugs:
		1- The last bit in the reset register (MSB) will not work correctly -- Added
					special rst_prot_err_fld -- which isn't being implemented, so the real
					cases will work correctly.
		2- The parity is not being updated in the last_pkt_mem memory.
v 2.0 LKB  1/22/2014  Added ifdef INT_SUPPORT for interrupt pin assignments.  This way it
will work with the Fundamentals class.
		2.0 LKB  3/22/2014 Added more parameters to easily move the YAPP registers
and memories around
3. The registers are not part of the output instantiantion.  The plus side is
that does not reflect the top.dut instantiation.  Some of the host_ctrl is
intermixed with functionality -- this should be revisited.


			Change this parameter:

				YAPP_OFFSET 16'h10000 -- all other address blocks will readjust.


Currently:
12 registers are implemented with a parameterized offset
1 256 byte memory at offset 0x100 of YAPP_OFFSET
1 65 Byte memory that is the last packet received (header + payload) at offset
0x010
- Bug, parity is not updated in last packet memory

YAPP_OFFSET  0x1000
each register is accessible xxx_reg (DPI) and host bus offset + YAPP_OFFSET
field are accessible via DPI xxx_fld


Memories (used off of YAPP_OFFSET)
YAPP_MEM_RO_ADJ
last_pkt_size_reg = The last packet size (header + packet length)
last_pkt_mem [RO] = last packet received (header + packet). Maximum 65 bytes

	Only overwrites
the current packet received.  Read the last_pkt_size_reg to read only the
current packet contents

YAPP_MEM_RW_OFFSET
memory-[256]
RW memory -- to have an additonal memory.  This shows how update can be used.



----------------------------------------------------------------------
Copyright Cadence Design Systems (c)2014
----------------------------------------------------------------------*/

//****                                                                ****
//****                         waveforms                              ****
//****                                                                ****
//
//                _   _   _   _   _   _   _   _   _   _   _   _   _   _
//clock ...... : | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___________________             _______________
//in_data_vld  : /                   \___________/               \___________
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                                        ___                         ___
//error....... : ________________________/   \_______________________/   \___
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___ ___ __...__ ___ ___         ___ ___ __...__ ___
//in_data .... : X_H_X_D_X__...__X_D_X_P_>_______<_H_X_D_X__...__X_P_>_______
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                _______________________         ___________________
//packet ..... : <______packet_0_________>-------<______packet_1_____>-------
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//
//H = Header
//D = Data
//P = Parity
//
// the router assert data_vld_x  when valid data appears in channel queue x
// assert input read_enb_x to read packets from the queue.
// receiver must keep track of packet extent and size.
// error is asserted if parity error is detected at the end of packet reception
//
//****************************************************************************/
`timescale 1ns/100ps

// `include "../src/fifo.sv"
// `include "../src/host_ctl.sv"
// `include "../src/port_fsm.sv"

module yapp_router_top (input clock,
																				input reset,
																				output error,

																				// Input channel
																				input [7:0] in_data,
																				input in_data_vld,
																				output in_suspend,
`ifdef INT_SUPPORT
																				output parity_intr,
																				output ovrsized_pkt_intr,
																				output illegal_pkt_addr_intr,
`endif
																				// Output Channels
																				output [7:0] data_0,  //Channel 0
																				output reg data_vld_0,
																				input suspend_0,
																				output [7:0] data_1,  //Channel 1
																				output reg data_vld_1,
																				input suspend_1,
																				output [7:0] data_2,  //Channel 2
																				output reg data_vld_2,
																				input suspend_2,

																				// Host Interface Signals
																				input [15:0] haddr,
																				inout [7:0] hdata,
																				input hen,
																				input hwr_rd);

// Internal Signals
wire     full_0;
wire     full_1;
wire     full_2;
wire     empty_0;
wire     empty_1;
wire     empty_2;
wire     almost_empty_0;
wire     almost_empty_1;
wire     almost_empty_2;
wire     fifo_empty;
wire     fifo_empty0;
wire     fifo_empty1;
wire     fifo_empty2;
wire     hold_0;
wire     hold_1;
wire     hold_2;
wire     hold;
wire   [2:0] write_enb;
wire   [1:0] addr;
wire   [7:0] router_enable;
wire [5:0]   max_pkt_size;
wire [7:0] chan_data;
wire [7:0] parity_err_cnt;
wire [7:0] len_err_cnt;
wire [7:0] ill_addr_cnt;
wire [7:0] addr0_cnt;
wire [7:0] addr1_cnt;
wire [7:0] addr2_cnt;
wire [4:0] resets;
wire [3:0] intr_stat;
wire [3:0] intr_ien;
wire [3:0] intr_clr;
wire [6:0] pkt_addr;
wire [7:0] pkt_data;
wire [7:0] parity_out;
wire       parity_done;
wire       pkt_start;
wire [5:0] last_pkt_size;

// Continuous Assignments
always @(posedge clock or posedge reset) begin
		if ((reset) || resets[0]) begin
				data_vld_0 <= 1'b0;
				data_vld_1 <= 1'b0;
				data_vld_2 <= 1'b0;
				//LKB move internal count reset here
		end
		else begin
				data_vld_0 <= !empty_0 && !almost_empty_0;
				data_vld_1 <= !empty_1 && !almost_empty_1;
				data_vld_2 <= !empty_2 && !almost_empty_2;
		end
end

		assign fifo_empty0 = (empty_0 | ( addr[1] |  addr[0]));     //addr!=00
		assign fifo_empty1 = (empty_1 | ( addr[1] | !addr[0]));     //addr!=01
		assign fifo_empty2 = (empty_2 | (!addr[1] |  addr[0]));     //addr!=10

		assign fifo_empty  = fifo_empty0 & fifo_empty1 & fifo_empty2;

		assign hold_0 = (full_0 & (!addr[1] & !addr[0]));   //addr=00
		assign hold_1 = (full_1 & (!addr[1] &  addr[0]));   //addr=01
		assign hold_2 = (full_2 & ( addr[1] & !addr[0]));   //addr=10

		assign hold   = hold_0 | hold_1 | hold_2;

		host_ctl reg_file (.clock (clock),
																		.reset (reset),
																		.addr  (haddr),
																		.data  (hdata),
																		.en    (hen),
																		.wr_rd (hwr_rd),
																		.parity_err_cnt (parity_err_cnt),
																		.len_err_cnt (len_err_cnt),
																		.ill_addr_cnt (ill_addr_cnt),
								.addr0_cnt (addr0_cnt),
								.addr1_cnt (addr1_cnt),
								.addr2_cnt (addr2_cnt),
																		.int_stat  (intr_stat),
																		.int_clr   (intr_clr),
																		.pkt_addr  (pkt_addr),
																		.pkt_data  (pkt_data),
																		.last_pkt_size (last_pkt_size),
																		.parity_done (parity_done),
																		.pkt_start (pkt_start),
																		.parity    (parity_out),
																		.int_ien_reg (intr_ien),
																		.rst_reg (resets),
																		.en_reg (router_enable),
																		.max_pkt_len (max_pkt_size));

//Input Port FSM
		port_fsm in_port (.clock         (clock),
																				.reset         (reset),
																				.in_suspend    (in_suspend),
`ifdef INT_SUPPORT
																				.parity_intr   (parity_intr),
																				.ovrsized_pkt_intr (ovrsized_pkt_intr),
										.illegal_pkt_addr_intr (illegal_pkt_addr_intr),
`endif
																				.error         (error),
																				.write_enb     (write_enb),
																				.fifo_empty    (fifo_empty),
																				.hold          (hold),
																				.in_data_vld   (in_data_vld),
																				.in_data       (in_data),
																				.addr          (addr),
																				.parity_err_cnt (parity_err_cnt),
																				.last_pkt_size  (last_pkt_size),
																				.len_err_cnt   (len_err_cnt),
																				.ill_addr_cnt  (ill_addr_cnt),
										.addr0_cnt     (addr0_cnt),
										.addr1_cnt     (addr1_cnt),
										.addr2_cnt     (addr2_cnt),
																				.intr_stat     (intr_stat),
																				.chan_data     (chan_data),
																				.intr_ien      (intr_ien),
																				.intr_clr      (intr_clr),
																				.pkt_addr      (pkt_addr),
																				.pkt_data      (pkt_data),
																				.parity_done   (parity_done),
																				.pkt_start     (pkt_start),
																				.parity_out    (parity_out),
																				.resets        (resets),
																				.router_enable (router_enable),
																				.max_pkt_size  (max_pkt_size));

// Output Channels: 0, 1, 2
		fifo queue_0 (.clock     (clock),
																.reset     (reset),
																.write_enb (write_enb[0]),
																.read_enb  (!suspend_0),
																.in_data   (chan_data),
																.resets    (resets),
																.data_out  (data_0),
																.empty     (empty_0),
																.almost_empty (almost_empty_0),
																.full      (full_0));

		fifo queue_1 (.clock     (clock),
																.reset     (reset),
																.write_enb (write_enb[1]),
																.read_enb  (!suspend_1),
																.in_data   (chan_data),
																.resets   (resets),
																.data_out  (data_1),
																.empty     (empty_1),
																.almost_empty (almost_empty_1),
																.full      (full_1));

		fifo queue_2 (.clock     (clock),
																.reset     (reset),
																.write_enb (write_enb[2]),
																.read_enb  (!suspend_2),
																.in_data   (chan_data),
																.resets   (resets),
																.data_out  (data_2),
																.empty     (empty_2),
																.almost_empty (almost_empty_2),
																.full      (full_2));

endmodule //yapp_router
