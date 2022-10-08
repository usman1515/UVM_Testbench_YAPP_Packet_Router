class router_short_packet_test extends router_base_test;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_short_packet_test)

    // ------------------------------------------ component instances
    int iterations=1;
    yapp_5_packets_seq yapp_seq;

    // ------------------------------------------ constructor
    function new(string name="router_short_packet_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED building router_short_packet_test:    "), UVM_HIGH)
        super.build_phase(phase);
        // set type override to short yapp packet
        set_type_override_by_type(yapp_packet::get_type(), yapp_packet_short::get_type());  // method 1
        // yapp_packet::type_id::set_type_override(yapp_packet_short::get_type());          // method 2
        uvm_config_int::set(this, "*", "recording_detail", 1);
        yapp_seq = yapp_5_packets_seq::type_id::create("yapp_seq", this);
    `uvm_info(get_type_name(), $sformatf("COMPLETED building router_short_packet_test:  "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ run task
    task run_phase(uvm_phase phase);
        repeat(iterations) begin
            phase.raise_objection(this);
            yapp_seq.start(tb.yappenv.yapp_tx_agnt.yapp_tx_seqr);
            phase.drop_objection(this);
        end
        //set a drain-time for the environment if desired
        phase.phase_done.set_drain_time(this, 20);
    endtask : run_phase

endclass : router_short_packet_test
