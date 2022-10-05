module tb_top;

    initial begin
        run_test();
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
