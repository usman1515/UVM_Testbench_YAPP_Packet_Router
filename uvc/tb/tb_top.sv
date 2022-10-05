// `include "flist.sv"
// `include "../../yapp/tb/flist.sv"
// `include "./uvc/yapp/tb/flist.sv"
// -----------------------------------------
// uvc/flist.sv
// `include "../../uvc/flist.sv"

module tb_top;

    yapp_packet pkt1;
    yapp_packet pkt2;
    yapp_packet pkt3;

    initial begin
        for (int i=0; i<10; i=i+1) begin
            pkt1 = new("pkt1");
            assert(pkt1.randomize());
            $display("Generating packet: %d", i);
            // pkt1.print(uvm_default_tree_printer);
            pkt1.print(uvm_default_table_printer);
            // pkt1.print(uvm_default_line_printer);
            $display("\n\n");
        end
    end



    // ------------------------------------------ enable the wave dump
    `ifdef VCD
    initial begin
        $dumpfile("tb_waves.vcd");
        $dumpvars;
    end
    `endif

    `ifdef FSDB
    initial begin
        $fsdbDumpfile("tb_waves.fsdb");
        $fsdbDumpvars(0, "+struct", "+mda", "+all");
    end
    `endif

    `ifdef VPD
    initial begin
        $vcdplusfile("tb_waves.vpd");
        $vcdpluson(0, tb_top);
    end
    `endif


endmodule : tb_top