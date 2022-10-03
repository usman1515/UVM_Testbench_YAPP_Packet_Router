`define HEADER_WAIT  2'b00
`define DATA_LOAD    2'b01
`define DUMP_PKT     2'b10

module port_fsm (//FSM Control Signals
																	input clock,
																	input reset,
																	input hold,
																	input fifo_empty,
																	output reg   error,

																	// Host Interface Registers
																	input [4:0] resets,		//get reset values
																	input en_reg_t router_enable,	//get router_enables
																	input [5:0] max_pkt_size,	//get max_pkt_size to fsm_core
																	input [3:0] intr_clr,		//get the clr bits of the current W1 of the int reg
																	input [5:0] last_pkt_size,     //send the last pkt received size
																	input [7:0] parity_err_cnt,	//send the parity error counts
																	input [7:0] len_err_cnt,	//send the length pkt exceed counts
																	input [7:0] ill_addr_cnt,	//send the illegal address counts
																	input [3:0] intr_stat,  	//send the current interrupt status
																	input [3:0] intr_ien,		//get the current interrupt enables
																	// Host Channel Counts Registers
																	input [7:0] addr0_cnt,		//get the addr0 packet counts
																	input [7:0] addr1_cnt,		//get the addr1 packet counts
																	input [7:0] addr2_cnt,		//get the addr2 packet counts
																	input [6:0] pkt_addr,          // packet address pointer in last packet
																	input [7:0] pkt_data,          // contents of data at curr pkt_addr
																	input [7:0] parity_out,        // send the parity back to the host
																	input parity_done,             // send that the parity has been calculated
																	input pkt_start, 		// start of pkt -held high while pkt is valid
																	// Input Port Data
																	input  [7:0] in_data,
																	input  in_data_vld,
																	output in_suspend,
`ifdef INT_SUPPORT
																	output parity_intr,
																	output ovrsized_pkt_intr,
																	output illegal_pkt_addr_intr,
`endif
																	// Output Port Data
																	output     [1:0] addr,
																	output     [7:0] chan_data,
																	output     [2:0] write_enb);

// Internal Signals
reg    [2:0] write_enb_r;
reg          fsm_write_enb;
reg    [1:0] state_r, state;
reg    [7:0] parity;
reg          sus_data_in;
reg    [1:0] dest_chan_r;
reg    [7:0] parity_err_cnt_int;
reg    [7:0] len_err_cnt_int;
reg    [7:0] ill_addr_cnt_int;
reg    [7:0] addr0_cnt_int;
reg    [7:0] addr1_cnt_int;
reg    [7:0] addr2_cnt_int;
reg    [3:0] intr_stat_int;
reg    [6:0] pkt_addr_int;
reg    [7:0] pkt_data_int;
reg          parity_done_int;
reg    [7:0] parity_out_int;
reg          pkt_start_int;
reg          illegal_addr_int;
reg    [7:0] last_pkt_size_int;
reg          parity_intr_int;
reg          illegal_pkt_addr_intr_int;
reg          ovrsized_pkt_intr_int;

//Continuous Assignments
		assign ill_addr_cnt = ill_addr_cnt_int;
		assign len_err_cnt = len_err_cnt_int;
		assign parity_err_cnt = parity_err_cnt_int;
		assign addr0_cnt = addr0_cnt_int;
		assign addr1_cnt = addr1_cnt_int;
		assign addr2_cnt = addr2_cnt_int;
		assign intr_stat = intr_stat_int;
		assign pkt_addr = pkt_addr_int;
		assign pkt_data = pkt_data_int;
		assign in_suspend = sus_data_in;
		assign parity_done = parity_done_int;
		assign parity_out = parity_out_int;
		assign last_pkt_size = last_pkt_size_int;
		assign pkt_start = pkt_start_int;
`ifdef INT_SUPPORT
		assign parity_intr = parity_intr_int;
		assign ovrsized_pkt_intr = ovrsized_pkt_intr_int;
		assign illegal_pkt_addr_intr = illegal_pkt_addr_intr_int;
`endif

		wire [1:0] dest_chan = ((state_r == `HEADER_WAIT) && (in_data_vld == 1'b1)) ? in_data : dest_chan_r;

		assign addr = dest_chan;

		wire chan0 = dest_chan == 2'b00 ? 1'b1 : 1'b0;
		wire chan1 = dest_chan == 2'b01 ? 1'b1 : 1'b0;
		wire chan2 = dest_chan == 2'b10 ? 1'b1 : 1'b0;

		assign chan_data = in_data;
		assign write_enb[0] = chan0 & fsm_write_enb;
		assign write_enb[1] = chan1 & fsm_write_enb;
		assign write_enb[2] = chan2 & fsm_write_enb;

		wire header_valid = (state_r == `HEADER_WAIT) && (in_data_vld == 1'b1);


		always @(negedge clock or posedge reset)
		begin : fsm_state
				if ((reset) || (resets[0])) begin
						state_r <= `HEADER_WAIT;
						dest_chan_r <= 2'b00;
						addr0_cnt_int <= 8'h00;
						addr1_cnt_int <= 8'h00;
						addr2_cnt_int <= 8'h00;
						len_err_cnt_int <= 8'h00;
						ill_addr_cnt_int <= 8'h00;
						parity_err_cnt_int <= 8'h00;
						intr_stat_int <= 8'h00;
						pkt_addr_int <= 8'h00;
						pkt_data_int <= 8'h00;
						illegal_addr_int <= 1'b0;
						last_pkt_size_int <= 6'h00;
						parity_intr_int <= 1'b0;
						illegal_pkt_addr_intr_int <= 1'b0;
						ovrsized_pkt_intr_int <= 1'b0;

				end
				else begin
						// check for error count resets
						if (resets[1]) begin
								len_err_cnt_int <= 8'h00;
								ill_addr_cnt_int <= 8'h00;
								parity_err_cnt_int <= 8'h00;
								illegal_addr_int <= 1'b0;
						end
						if (resets[2]) begin
								addr0_cnt_int <= 8'h00;
								addr1_cnt_int <= 8'h00;
								addr2_cnt_int <= 8'h00;
						end
						if (resets[3]) begin
								intr_stat_int <= 8'h00;
								parity_intr_int <= 1'b0;
								illegal_pkt_addr_intr_int <= 1'b0;
								ovrsized_pkt_intr_int <= 1'b0;


						end
						if (intr_clr[0]) begin
									intr_stat_int[0] <= 0;
									parity_intr_int <= 0;
						end
						if (intr_clr[1]) begin
									intr_stat_int[1] <= 0;
									ovrsized_pkt_intr_int <= 0;
						end
						if (intr_clr[2]) begin
									intr_stat_int[2] <= 0;
									illegal_pkt_addr_intr_int <= 0;
						end

						if (resets[4]) begin
									pkt_addr_int <= 8'h00;
									pkt_data_int <= 8'h00;
						end


						state_r <= state;
						if ((state_r == `HEADER_WAIT) && (in_data_vld == 1'b1))
								dest_chan_r <= in_data[1:0];
				end
		end //fsm_state;

		always @(state_r or in_data_vld or in_data or max_pkt_size or fifo_empty or hold)
		begin
						state = state_r;   //Default state assignment
						sus_data_in = 1'b0;
						fsm_write_enb = 1'b0;

						//$display(" <<<LKB Waiting for packet router_en = %h>>>", router_enable);
						case (state_r)
						`HEADER_WAIT : begin
																						sus_data_in = !fifo_empty && in_data_vld;
																						pkt_start_int <= 1'b0;
																						parity_done_int <= 1'b0;
																						illegal_addr_int <= 1'b0;
																						if (in_data_vld == 1'b0)
																								state = `HEADER_WAIT;      // stay in state if data not valid

																						// LKB 3/13: For some reason I no longer cannot get a
																						// max packet error, instead I always get a illegal
																						// address error, so I moved the oversized packet above
																						// the illegal address error -- doesn't make sense
																						// both errors happen and the router drops packet
																						else if  (in_data[1:0] == 2'b11) begin		// error length
																								state = `DUMP_PKT;      // invalid length or illegal address
																								$display("ROUTER DROPS PACKET - ADDRESS is %0d",in_data[1:0]);
																								if (router_enable.illegal_addr_cnt_en_fld && !resets[1]) begin
																								//if (router_enable[7] && !resets[1]) begin
																												illegal_addr_int <= 1;
																												ill_addr_cnt_int <= ill_addr_cnt_int + 1;
																													if (intr_ien[2]) begin
																							intr_stat_int[2] <= 'b1;
													illegal_pkt_addr_intr_int <= 1'b1;
																													end
																								end
																						end
																						else if ((in_data[7:2] > max_pkt_size[5:0]) || (in_data[7:2] < 1)) begin
																								state = `DUMP_PKT;      // invalid length or illegal address
																								$display("ROUTER DROPS PACKET - LENGTH is %0d, MAX is %0d",in_data[7:2],max_pkt_size[5:0]);
																								// Update the max packet error if it is in the router ctr bit
																								if (router_enable.len_err_cnt_en_fld && !resets[1])begin
																											//$display("LKB DBG Counter will be incremented - LENGTH is %0d, MAX is %0d",in_data[7:2],max_pkt_size[5:0]);

																											len_err_cnt_int <= len_err_cnt_int + 1;
																											if (intr_ien[1]) begin
																										intr_stat_int[1] <= 1'b1;
																														ovrsized_pkt_intr_int <= 1'b1;

																											end
																								end
																								else if (router_enable.router_en_fld == 1'b0) begin
																											state = `DUMP_PKT;
																											$display("ROUTER DISABLED -- DROPPING PACKET");
																								end

																						end
																						else if (fifo_empty == 1'b1) begin
																										//$display("<<<LKB  Good packet counting Router_en =%h  in_data = %h  resets[2]%h ",
																											//    router_enable, in_data[1:0],resets[2]                               );
																								// update the address count registers 0, 1, &2
																								if ((router_enable[4])&& (in_data[1:0] == 2'b00) && (!resets[2]))begin
																									// $display("<<<LKB updating addr0 ");
																											addr0_cnt_int <= addr0_cnt_int + 1;
																								end
																								if ((router_enable.addr1_cnt_en_fld) && (in_data[1:0] == 2'b01) && (!resets[2])) begin
																												//$display("<<<LKB updating addr1 ");

																											addr1_cnt_int <= addr1_cnt_int + 1;
																								end
																								if ((router_enable.addr2_cnt_en_fld) && (in_data[1:0] == 2'b10) && (!resets[2])) begin
																											// $display("<<<LKB updating addr2 ");

																											addr2_cnt_int <= addr2_cnt_int + 1;
																								end
																								state = `DATA_LOAD;     // load good packet
																								fsm_write_enb = 1'b1;
																								end
																						else
																								state = `HEADER_WAIT;  // input suspended, fifo not empty - stay in state
																				end // case: HEADER_WAIT

								`DUMP_PKT  : begin
																							if (in_data_vld == 1'b0)
																											state = `HEADER_WAIT;
																					end
								`DATA_LOAD : begin
																							sus_data_in = hold;
//                       sus_data_in = hold && in_data_vld;
																							if (in_data_vld == 1'b0) begin
																									state = `HEADER_WAIT;
																									fsm_write_enb = 1'b1;
																							end
																							else begin
																									fsm_write_enb = !hold;
																							end
																					end // case: DATA_LOAD
									default: state = `HEADER_WAIT;

							endcase
		end //fsm_core

		always @(negedge clock or posedge reset)
		begin
				if ((reset || resets[0]) ) begin : parity_calc
							parity <= 8'b0000_0000;
							parity_done_int <= 0;

							// parity error for this packet set to 0
							error <=1'b0;
							illegal_addr_int <= 0;
				end // if reset
				else begin  // out of reset
						// valid data coming in -- but don't accept data if illegal address
						if ((in_data_vld == 1'b1) && (sus_data_in == 1'b0))  begin
									error <= 1'b0;
									parity <= parity ^ in_data;

								pkt_data_int <= in_data;
								parity_out_int <= parity;
								//LKB Added this back into support last_pkt_mem
								if ((pkt_start_int == 1'b0) && !(resets[4])) begin
															pkt_addr_int <= 8'h00;
															last_pkt_size_int <= in_data[7:2];
															pkt_start_int <= 1'b1;
								end
								else if ((pkt_start_int == 1'b1) && !(resets[4]) &&  (pkt_addr_int < last_pkt_size_int + 1) ) begin
															pkt_addr_int <= pkt_addr_int + 1;
								end
							end // else in_data_vld = 1
							else if (in_data_vld == 1'b0) begin
										if ((state_r == `DATA_LOAD) && (parity != in_data)) begin
													error <= 1'b1;
													$display("*** ROUTER (DUT) Parity Error Identified: Expected:%h Computed:%h ***", in_data, parity);
													pkt_data_int <= in_data;
													if (router_enable.parity_err_cnt_en_fld && !resets[1]) begin
																parity_err_cnt_int <= parity_err_cnt_int + 1;
													if (intr_ien[0]) begin
															intr_stat_int[0] <= 1'b1;
															parity_intr_int <= 1'b1;
												end  // intr_ien
												parity_done_int <= 1'b1;
										end // state
										parity <= 8'b0000_0000;
								end //in_data_vld == 0
								else begin
											error <= 1'b0;
											parity <= 8'b0000_0000;
											pkt_addr_int <= 8'h00;
											pkt_data_int <= 8'h00;
											parity_done_int <= 1'b0;
											pkt_start_int <= 0;
											illegal_addr_int <= 1'b0;
								end // else
						end// not in reset
	end //parity_calc
`ifdef NO_WORK
								//added code for ram and interrupts
								if ((pkt_start_int == 1'b0) && !(resets[4]) ) begin
												pkt_addr_int <= 8'h00;
												last_pkt_size_int <= in_data[7:2];
												pkt_start_int <= 1'b1;
								end // pkt_start_int and reset
								else if ((pkt_start_int == 1'b1) &&  !(resets[4]) && (pkt_addr_int < last_pkt_size_int + 1)) begin
													pkt_addr_int <= pkt_addr_int + 1;
								end // increase pkt address for the ram
								parity_out_int <= in_data;
								parity_done_int <= 1'b1;
								pkt_data_int <= in_data;
						end // in_data valid =0
						else begin
										error <= 1'b0;
										parity <= 8'b0000_0000;
										pkt_addr_int <= 8'h00;
										pkt_data_int <= 8'h00;
										parity_done_int <= 1'b1;
										pkt_start <= 0;
										illegal_addr_int <= 1'b0;
						end
			end //else begin
`endif
`ifdef NOT_WORKING
								// deal with start of packet for memory --which isn't being used in
								// the fundamental class
								if ((pkt_start_int == 1'b0) && !(resets[4]) ) begin
												pkt_addr_int <= 8'h00;
												last_pkt_size_int <= in_data[7:2];
												pkt_start_int <= 1'b1;
								end // pkt_start_int and reset
								else if ((pkt_start_int == 1'b1) &&  !(resets[4]) && (pkt_addr_int < last_pkt_size_int + 1)) begin
													pkt_addr_int <= pkt_addr_int + 1;
									end // increase pkt address for the ram
									//update the host_ctrl parrity error count reg, if the parity error
					//count  is enabled and the reset error count is not high

					if (router_enable[1] && !resets[1]) begin
								parity_err_cnt_int <= parity_err_cnt_int + 1;
								if (intr_ien[0]) begin
														intr_stat_int[0] <= 1'b1;
									end  // intr_ien
						end // router_en
						parity_out_int <= in_data;
						parity_done_int <= 1'b1;
						pkt_data_int <= in_data;

						error <= 1'b0;
						parity <= 8'b0000_0000;
						pkt_addr_int <= 8'h00;
						pkt_data_int <= 8'h00;
						parity_done_int <= 1'b1;
						pkt_start_int <= 0;
						illegal_addr_int <= 1'b0;
					end //in_data_vld

				end //else begin
`endif
		end //parity_calc;

endmodule //port_fsm
