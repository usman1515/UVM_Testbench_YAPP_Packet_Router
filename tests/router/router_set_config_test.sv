class router_set_config_test extends router_base_test;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_set_config_test)

    // ------------------------------------------ component instances
    int iterations=1;
    yapp_5_packets_seq yapp_seq;

    // ------------------------------------------ constructor
    function new(string name="router_set_config_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED building router_set_config_test:    "), UVM_HIGH)
        super.build_phase(phase);
        uvm_config_int::set(this, "*", "recording_detail", 1);
        uvm_config_int::set(this, "tb.yappenv.yapp_tx_agnt", "is_active", UVM_PASSIVE);
        `uvm_info(get_type_name(), $sformatf("COMPLETED building router_set_config_test:  "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ run task
    task run_phase(uvm_phase phase);
        repeat(iterations) begin
            phase.raise_objection(this);
            phase.drop_objection(this);
        end
        //set a drain-time for the environment if desired
        phase.phase_done.set_drain_time(this, 20);
    endtask : run_phase

endclass : router_set_config_test
