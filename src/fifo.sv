module fifo (input clock,
													input reset,
													input write_enb,
													input read_enb,
													input [7:0] in_data,
													input [4:0] resets,
													output reg [7:0] data_out,
													output empty,
													output almost_empty,
													output full);

// Internal Signals
			reg [7:0] ram[0:15];   // FIFO Memory
			reg       tmp_empty;
			reg       tmp_full;
			reg [3:0] write_ptr;
			reg [3:0] read_ptr;

// Continuous assignments
			assign empty = tmp_empty;
			assign almost_empty = (write_ptr == read_ptr + 4'b1) && !write_enb;
			assign full  = tmp_full;
//   assign data_out = ram[read_ptr];

always @(posedge clock) begin
			data_out <= ram[read_ptr];
end

// Processes

			always @(negedge clock or posedge reset )
			if ((reset || resets[0])) begin
						write_ptr <= 0;
						tmp_full <= 1'b0;
						tmp_empty <= 1'b1;
						write_ptr <= 4'b0;
						read_ptr <= 4'b0;
			end
			else begin : fifo_core
					// Read and Write at the same time when empty
					if ((read_enb == 1'b1) && (write_enb == 1'b1) && (tmp_empty == 1'b1)) begin
							ram[write_ptr] <= in_data;
							write_ptr <= (write_ptr + 4'b1);
							tmp_empty <= 0;
					end
					// Read and Write at the same time when not empty
					else if ((read_enb == 1'b1) && (write_enb == 1'b1) && (tmp_empty == 1'b0)) begin
							ram[write_ptr] <= in_data;
							read_ptr <= (read_ptr + 4'b1);
							write_ptr <= (write_ptr + 4'b1);
					end
					// Write
					else if (write_enb == 1'b1) begin
							tmp_empty <= 1'b0;
							if (tmp_full == 1'b0) begin
									ram[write_ptr] <= in_data;
									write_ptr <= (write_ptr + 4'b1);
							end
							if ((read_ptr == write_ptr + 4'b1) && (read_enb == 1'b0)) begin
									tmp_full <= 1'b1;
							end
					end
					// Read
					else if (read_enb == 1'b1) begin
							if (tmp_empty == 1'b0) begin
									read_ptr <= (read_ptr + 4'b1);
							end
							if ((tmp_full == 1'b1) && (write_enb == 1'b0)) begin
									tmp_full <= 1'b0;
							end
							if ((write_ptr == read_ptr + 4'b1) && (write_enb == 1'b0)) begin
									tmp_empty <= 1'b1;
							end
					end
			end

endmodule //fifo
