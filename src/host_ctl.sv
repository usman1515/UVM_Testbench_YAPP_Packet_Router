typedef struct packed {
	//typedef struct packed {
						logic illegal_addr_cnt_en_fld;     //Enable or Disable Illegal Address Counter
						logic addr2_cnt_en_fld;            //Enable or Disable Address 2 Counter
						logic addr1_cnt_en_fld;            //Enable or Disable Address 1 Counter
						logic addr0_cnt_en_fld;            //Enable or Disable Address 0 Counter
						logic unimp;                       // protocol_err_en_en_fld;      //Not implemented
						logic len_err_cnt_en_fld;          //Enable or Disable the max packet illegal error counter
						logic parity_err_cnt_en_fld;       //Enable or Disable the parity error counter
						logic router_en_fld; 		//Enable or Disable the entire router
			} en_reg_t;


	module host_ctl
														(
															input clock,
															input reset,
															input wr_rd,
															input en,
															input [15:0] addr,
															inout [7:0] data,
															input [7:0] parity_err_cnt,
															input [7:0] len_err_cnt,
															input [7:0] ill_addr_cnt,
															input [7:0] addr0_cnt,
															input [7:0] addr1_cnt,
															input [7:0] addr2_cnt,
															input [3:0] int_stat,
															input [6:0] pkt_addr,
															input [7:0] pkt_data,
															input [7:0] parity,
															input [5:0] last_pkt_size,
															input       parity_done,
															input       pkt_start,
															output[3:0] int_ien_reg,
															output[3:0] int_clr,
															output[4:0] rst_reg,
															output en_reg_t en_reg, //LKB_3_10
															//output[7:0] en_reg,  //LKB_3_10
															output[5:0] max_pkt_len);

				// Reset values for control and enable registers
				parameter   RST_MAX_PKT = 8'h3F;
				parameter   en_reg_t RST_EN_REG = 8'h01;
				//--------------------------------------------------------------------------------------
				// Parameters that can be adjusted
				// -------------------------------------------------------------------------------------
				parameter   YAPP_OFFSET       = 16'h1000; // Offset of yapp_am container of the yapp_rdb.sv
				parameter   YAPP_MEM_RO_ADJ     = 8'h10;    // For decoding the memory based on an offset
				parameter  YAPP_MEM_RW_OFFSET  =   16'h100;   // Offset of memory from YAPP OFFSET
				parameter  YAPP_RANGE          = YAPP_OFFSET + 16'h1FFF;


			// Individual register offsets
				parameter   YCTRL_REG_OFF     = 8'h00;    // Offset of ctrl_reg, use the bit fields to define
				parameter   YEN_REG_OFF       = 8'h01;    // Offset of en_reg, use the bit fields to define
				parameter   YIEN_REG_OFF      = 8'h02;    // Offset of en_reg, use the bit fields to define
				parameter   YINT_REG_OFF      = 8'h03;    // Offset of the int_stat_reg, use bits to define
				parameter   YPAR_ERR_CNT_OFF  = 8'h04;    // Offset ot the parity err cnt reg, use reg to define
				parameter   YMAX_PKT_CNT_OFF  = 8'h05;    // Offset of max packet count reg
				parameter   YILL_ADDR_CNT_OFF = 8'h06;    // Offset of the illegal address count reg
				parameter   YADDR0_CNT_OFF    = 8'h09;    // Offset of addresss 0 count reg
				parameter   YADDR1_CNT_OFF    = 8'h0a;    // Offset of addresss 0 count reg
				parameter   YADDR2_CNT_OFF    = 8'h0b;    // Offset of addresss 0 count reg
				parameter   YRESET_REG_OFF    = 8'h0c;    // Offset of the reset register
				parameter   YLST_PKT_SIZE_OFF = 8'h0d;    // Offset of the last_pkt_size reg
				parameter   YPARITY_RCVD_OFF  = 8'h0e;     // Offset of the parity rcvd (the packet parity - not the calc_parity (not working)


				//THESE ARE AUTOCALCULATED

				parameter   YAPP_MEM_RO_ADDR    = YAPP_OFFSET+YAPP_MEM_RO_ADJ; // Address  of the last packet ram



				// ---------------------------------------------------------------------------------------
	//  Simple RW memory @ YAPP_MEM_RW
	//  ----------------------
				parameter  YAPP_MEM_RW_SIZE    =   16'h100;    // 256B memory
				parameter  YAPP_MEM_RW_END     =   YAPP_MEM_RW_SIZE -1;
				parameter  YAPP_MEM_RW_START   = YAPP_OFFSET + YAPP_MEM_RW_OFFSET;

	/* // This is for the RO last_pkt_in memory -- does not do well with the
		built-in memory tests */

				parameter   YAPP_MEM_RO_SIZE     = 8'h41;
			parameter     RST_MEM_BIT_OFF	 = 4;         // Bit offset of rst_mem_fld
				parameter  YAPP_MEM_RO_RANGE   = YAPP_OFFSET + YAPP_MEM_RO_ADJ + YAPP_MEM_RO_SIZE;

				//parameter   DEF_EN = 1'b0;   //KAM - For Training

				//reset register made of bit fields

				reg [7:0] reset_reg;
				reg rst_yapp_fld;
				reg rst_err_cnts_fld;
				reg rst_addr_cnts_fld;
				reg rst_ien_stat_fld;
				reg rst_ram_fld;
				reg rst_prot_err_fld;  // this isn't being used. Place holder

				//ctrl_reg @ Offset 00
				reg [7:0] ctrl_reg;
				reg [5:0] pkt_len_fld;

				//router_en_reg @ offset 01
				//LKB_3_10 not real reg [7:0] en_reg;
				reg router_en_fld ;
				reg parity_err_cnt_en_fld ;
				reg len_err_cnt_en_fld;
				//reg protocol_err_cnt_en_fld; LKB_3_10
				reg addr0_cnt_en_fld ;
				reg addr1_cnt_en_fld;
				reg addr2_cnt_en_fld  ;
				reg illegal_addr_cnt_en_fld;

				//interrupt enable reg - ien_reg @ offset 02
				reg [2:0]ien_reg;
				reg illegal_pkt_addr_ien_fld;
				reg ovrsized_pkt_ien_fld;
				reg parity_ien_fld;

				//interrupt status reg - int_stat_reg @ offset 3
				reg [2:0] int_reg;
				reg illegal_pkt_addr_int_fld;
				reg ovrsized_pkt_int_fld;
				reg parity_int_fld;

				// parity error count reg - RO, no bit fields definition
				reg [7:0] parity_err_cnt_reg;
				reg [7:0] max_pkt_len_err_cnt_reg;
				reg [7:0] illegal_addr_cnt_reg;
				reg [7:0] addr0_cnt_reg;
				reg [7:0] addr1_cnt_reg;
				reg [7:0] addr2_cnt_reg;


				reg [7:0] memory [0:YAPP_MEM_RW_END];

				// RO memory of the last packet - do not put this in the built in tests
				reg [7:0] last_pkt_size_reg;
				reg [7:0] last_pkt_mem[0:64];   // Straight R0 memory of the last packet recieved


				//internal data buses
				reg [7:0]   int_data;
				reg [7:0]   int_en_reg;
				reg [3:0]   int_clr_int;
				reg [6:0]   pkt_addr_int;
				reg [7:0]   pkt_data_int;
				//reg [7:0]   parity_int;
				//
				genvar imem;

				//continuous assignments for of internals to nets to other modules
				//LKB_3_10 added int_en_reg back - bug because protocol error is not legal
				//(bit 3 -- writing the single bit will fail a bit bash test -- not sure
				//how to code for this in RTL.
				//assign en_reg = { illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld, 1'b0, len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld};
			// assign en_reg = { illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld, 1'b0, len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld};

		assign max_pkt_len = pkt_len_fld;
				assign rst_reg =  {rst_ram_fld, rst_ien_stat_fld, rst_addr_cnts_fld, rst_err_cnts_fld, rst_yapp_fld};
				assign int_ien_reg = { illegal_pkt_addr_ien_fld, ovrsized_pkt_ien_fld, parity_ien_fld};
				assign int_clr = int_clr_int;
				assign data = int_data;
				assign en_reg = { illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld, 1'b0, len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld};




				// assignments from other modules: counts, resets, and integers
				always @(negedge clock or posedge reset) begin
				if ((parity_err_cnt_en_fld) && (parity_err_cnt_reg < parity_err_cnt)) begin
								parity_err_cnt_reg <= parity_err_cnt;
									end
									if ((len_err_cnt_en_fld) && (max_pkt_len_err_cnt_reg < len_err_cnt)) begin
							max_pkt_len_err_cnt_reg  <= len_err_cnt;
									end
											if ((illegal_addr_cnt_en_fld) && (illegal_addr_cnt_reg < ill_addr_cnt)) begin
						illegal_addr_cnt_reg  <= ill_addr_cnt;
									end
				if ((addr0_cnt_en_fld ) && (addr0_cnt_reg < addr0_cnt)) begin
							addr0_cnt_reg <= addr0_cnt;
									end
				if ((addr1_cnt_en_fld ) && (addr1_cnt_reg < addr1_cnt)) begin
							addr1_cnt_reg <= addr1_cnt;
									end
				if ((addr2_cnt_en_fld ) && (addr2_cnt_reg < addr2_cnt)) begin
							addr2_cnt_reg <= addr2_cnt;
								end
									// assign the interrupt status from the fsm_core to the fields
									illegal_pkt_addr_int_fld <= int_stat[2];
									ovrsized_pkt_int_fld <= int_stat[1];
									parity_int_fld <= int_stat[0];
									if (pkt_start == 1'b1 )begin
												last_pkt_mem[pkt_addr] <= pkt_data;
												//$display("<<<DBG_ROUTER last_pkt_mem[%x] = %x>>>>", pkt_addr, pkt_data);
									end
									//assign the parity as the last register in the packet, this doesn't
									//work
									if (parity_done == 1'b1) begin
												//last_pkt_mem[last_pkt_size+1] <= parity;
									end
									last_pkt_size_reg <= last_pkt_size;
									reset_reg <= {rst_ram_fld, rst_ien_stat_fld, rst_addr_cnts_fld, rst_err_cnts_fld, rst_yapp_fld};

									pkt_len_fld <= ctrl_reg[5:0];

						end// always


				always @(negedge clock or posedge reset) begin
						if ((reset) || (rst_yapp_fld)) begin
								int_data <= 8'h00;
								// ctrl_reg
								pkt_len_fld <= RST_MAX_PKT;
								ctrl_reg <= RST_MAX_PKT;
								//en_reg <= 8'hf7;
								router_en_fld <= RST_EN_REG.router_en_fld;
								parity_err_cnt_en_fld  <= RST_EN_REG.parity_err_cnt_en_fld;
								//LKB_3_10_protocol_err_cnt_en_fld <= 1'b0;
								len_err_cnt_en_fld <= RST_EN_REG.len_err_cnt_en_fld;
								addr0_cnt_en_fld   <= RST_EN_REG.addr0_cnt_en_fld;
								addr1_cnt_en_fld <= RST_EN_REG.addr1_cnt_en_fld;
								addr2_cnt_en_fld  <= RST_EN_REG.addr2_cnt_en_fld;
								illegal_addr_cnt_en_fld  <= RST_EN_REG.illegal_addr_cnt_en_fld;
								//ien_reg default to all ien  to be 0
								ien_reg <= 4'b0000;
								illegal_pkt_addr_ien_fld <= 1'b0;
								ovrsized_pkt_ien_fld <= 1'b0;
								parity_ien_fld <= 1'b0;
								//int_stat_reg (R/W 1 to Clear)
								illegal_pkt_addr_int_fld <= 1'b0;
								ovrsized_pkt_int_fld <= 1'b0;
								parity_int_fld <= 1'b0;
								int_clr_int <= 4'b0000;

								// Error Count registers (RO)
								parity_err_cnt_reg <= 8'h00;
								max_pkt_len_err_cnt_reg <= 8'h00;
								illegal_addr_cnt_reg <= 8'h00;

								// channel count reg (RO)
								addr0_cnt_reg <= 8'h00;
								addr1_cnt_reg <= 8'h00;
								addr2_cnt_reg <= 8'h00;

							// Reset Register (RW)
								rst_ram_fld <= 1'b0;
								rst_ien_stat_fld <= 1'b0;
								rst_addr_cnts_fld <= 1'b0;
								rst_err_cnts_fld <= 1'b0;
								rst_prot_err_fld <= 1'b0;


								reset_mem;

						end // always reset

						if ((reset) && (!rst_yapp_fld))
									rst_yapp_fld <= 1'b0;
						if (rst_err_cnts_fld) begin
									parity_err_cnt_reg <= 8'h00;
									max_pkt_len_err_cnt_reg <= 8'h00;
									illegal_addr_cnt_reg <= 8'h00;
						end

						if (rst_addr_cnts_fld) begin
								addr0_cnt_reg <= 8'h00;
								addr1_cnt_reg <= 8'h00;
								addr2_cnt_reg <= 8'h00;
						end
						if (rst_ram_fld) begin
								reset_mem;
						end

						if (rst_ien_stat_fld) begin
								//int_stat
								illegal_pkt_addr_int_fld <= 1'b0;
								ovrsized_pkt_int_fld <= 1'b0;
								parity_int_fld <= 1'b0;
								// ien flds
								illegal_pkt_addr_ien_fld <= 1'b0;
								ovrsized_pkt_ien_fld <= 1'b0;
								parity_ien_fld <= 1'b0;
						end
						if (rst_prot_err_fld) begin
				// this isn't  being used
				//protocol_err_int_fld <= 1'b0;
									//protocol_err_ien_fld <= 1'b0;
						end
						else if (!en)
										int_data = 8'hZZ;

						else if (en ) begin
								int_clr_int = 4'b0000;
								//YAPP HBUS registers Registers BASE  and RO Packet
								if ((addr >= YAPP_OFFSET) && (addr <= YAPP_RANGE)) begin
											// First see if this is a read and a memory packet -- don't let it
											// be part of the case -- it's too hard to range check This is a
											// hack from a long time ago.  should do it like the memory.
											if ((addr >= YAPP_MEM_RO_ADDR) && (addr < YAPP_MEM_RO_RANGE) && (wr_rd == 1'b0)) begin
														int_data = last_pkt_mem[addr[7:0]-  YAPP_MEM_RO_ADJ  ];
														//$display("LKB First of packets %x %x %x", last_pkt_mem[0], last_pkt_mem[1], last_pkt_mem[2]);
														//$display("LKB ------ Memory at %d = %x-----", addr[7:0]-8'h10, int_data);

											end
											else begin
											if (addr[15:8] == (YAPP_OFFSET >> 8)) begin
												case (wr_rd)
												0 : begin //read

																		case (addr[7:0])
																			YCTRL_REG_OFF: begin
																						int_data = {2'b00,pkt_len_fld};

																			end
																			YEN_REG_OFF: begin
																					// and fail the bit test.
																					// en_reg is being continously assigned as
																						int_data = { illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld, 1'b0, len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld};
																						//LKB_3_10 en_reg = int_data;
																						int_en_reg = { illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld, 1'b0, len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld};
	;
																			//$display("<<<LKB DBG Reading Enable register int_data = %h, int_en_reg = %h>>", int_data, int_en_reg);

																			end

																			YIEN_REG_OFF:begin
																						int_data = {5'h00, illegal_pkt_addr_ien_fld, ovrsized_pkt_ien_fld, parity_ien_fld};
																						ien_reg = {5'h00, illegal_pkt_addr_ien_fld, ovrsized_pkt_ien_fld, parity_ien_fld}; ;
																		end

																			// R/W1 C
														YINT_REG_OFF: begin
																						int_data = {5'h00, illegal_pkt_addr_int_fld, ovrsized_pkt_int_fld, parity_int_fld};
																						int_reg =  {illegal_pkt_addr_int_fld, ovrsized_pkt_int_fld, parity_int_fld};

																			end
																			// RO
																			YPAR_ERR_CNT_OFF: begin
																						int_data = parity_err_cnt_reg;
																			end

														YMAX_PKT_CNT_OFF: int_data = max_pkt_len_err_cnt_reg;
																			YILL_ADDR_CNT_OFF : int_data = illegal_addr_cnt_reg;
																			YADDR0_CNT_OFF:     int_data = addr0_cnt_reg;
																			YADDR1_CNT_OFF:     int_data = addr1_cnt_reg;
																			YADDR2_CNT_OFF:     int_data = addr2_cnt_reg;
																			YRESET_REG_OFF: begin
																						int_data = {3'b000 , rst_ram_fld, rst_ien_stat_fld, rst_addr_cnts_fld, rst_err_cnts_fld, rst_yapp_fld};
																			end
																		YLST_PKT_SIZE_OFF: int_data = { 2'h0,last_pkt_size_reg};
																																														// read out of memory
																default: int_data = 8'hZZ;
															endcase

													end //read
														1 : begin //write

																		case (addr[7:0])
																			YCTRL_REG_OFF: begin
																								pkt_len_fld = data;
																								ctrl_reg = {2'b00, pkt_len_fld};

																			end
																			YEN_REG_OFF: begin
																					//{ illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld,1'b0 , len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld} = data;
																						int_en_reg = data[7:4] & 1'b0 & data[2:0];

																										{illegal_addr_cnt_en_fld, addr2_cnt_en_fld, addr1_cnt_en_fld, addr0_cnt_en_fld} = data[7:4];
										{len_err_cnt_en_fld, parity_err_cnt_en_fld, router_en_fld} = data[2:0];
																					// $display("<<<LKB DEBUG Writing EN_REG = data %h int_en_reg", data,int_en_reg);

																			end // en write
																					YIEN_REG_OFF: begin
																						{ illegal_pkt_addr_ien_fld, ovrsized_pkt_ien_fld, parity_ien_fld} = data;
																						ien_reg = { 5'h0,illegal_pkt_addr_ien_fld, ovrsized_pkt_ien_fld, parity_ien_fld} ;
																			end
																			YINT_REG_OFF : begin

																							if ((parity_ien_fld) && (data[0] == 1'b1) && (int_stat[0]) ) begin
																											parity_int_fld = 0;
																											int_clr_int[0] = 1;
																							end
																							if ((ovrsized_pkt_ien_fld) && (data[1] == 1'b1) && (int_stat[1]))begin
																										ovrsized_pkt_int_fld = 0;
																										int_clr_int[1] = 1;
																							end
																							if ((illegal_pkt_addr_ien_fld) && (data[2] == 1'b1) && (int_stat[2])) begin
																										illegal_pkt_addr_int_fld = 0;
																										int_clr_int[2] = 1;
																							end
																							int_reg = {parity_int_fld, ovrsized_pkt_int_fld,illegal_pkt_addr_int_fld};
																			end //int status

																			YRESET_REG_OFF: begin
																					{rst_ram_fld, rst_ien_stat_fld, rst_addr_cnts_fld, rst_err_cnts_fld, rst_yapp_fld}
																								= data;
																						reset_reg = data;
																					end // rst_reg
																		endcase
															end // write
												endcase // case(wr_rd)
											end // of the Register decodes
										// Now check for the rw memory
										if (addr[15:8] == (YAPP_MEM_RW_START  >> 8)) begin

													case (wr_rd)
														0 : begin //read

																		int_data = memory[addr[7:0]];



														end //read
														1: begin //write
																	`ifdef INJECT_ERROR
																				if (addr[7:0] == 'h0f)
																						memory[addr[7:0]] <= ~data;
																				else
																	`endif
																	memory[addr[7:0]] = data;
														end

												endcase
										end // memory rd/write decode

										end // the else for base registers -- not a RO mem read
								end // addr range check -- okay go into decode.
							end // if (en)
				end // always @ (posedge clock)

				task reset_mem ();
						integer i;
						begin
								i = 0;
								while (i <  YAPP_MEM_RO_SIZE+1) begin
										last_pkt_mem[i] = 0;
										i = i+ 1;
									end
						end
					endtask
	endmodule // host_ctl

