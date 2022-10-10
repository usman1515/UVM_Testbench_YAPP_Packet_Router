class router_incr_payload_test extends router_base_test;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_incr_payload_test)

    // ------------------------------------------ component instances
    int iterations=1;
    yapp_incr_payload_seq yapp_seq1;
    bit en_yapp_short_pkt = 1'b1;

    // how to disabel constraint c_packet_length

    // ------------------------------------------ constructor
    function new(string name="router_incr_payload_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED building router_incr_payload_test:    "), UVM_HIGH)
        super.build_phase(phase);
        if(en_yapp_short_pkt) begin
            set_type_override_by_type(yapp_packet::get_type(), yapp_packet_short::get_type());
            `uvm_info(get_type_name(), $sformatf("YAPP packet = yapp_packet_short"), UVM_LOW)
        end
        else begin
            `uvm_info(get_type_name(), $sformatf("YAPP packet = yapp_packet"), UVM_LOW)
        end
        uvm_config_int::set(this, "*", "recording_detail", 1);
        yapp_seq1 = yapp_incr_payload_seq::type_id::create("yapp_seq1", this);
        `uvm_info(get_type_name(), $sformatf("COMPLETED building router_incr_payload_test:  "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ run task
    task run_phase(uvm_phase phase);
        repeat(iterations) begin
            phase.raise_objection(this);
            yapp_seq1.start(tb.yappenv.yapp_tx_agnt.yapp_tx_seqr);
            phase.drop_objection(this);
        end
        //set a drain-time for the environment if desired
        phase.phase_done.set_drain_time(this, 20);
    endtask : run_phase


endclass : router_incr_payload_test