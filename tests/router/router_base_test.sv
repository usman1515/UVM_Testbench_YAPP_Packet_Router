class router_base_test extends uvm_test;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_base_test)

    // ------------------------------------------ component instances
    int iterations=1;
    router_tb tb;
    yapp_5_packets_seq yapp_seq;

    // ------------------------------------------ constructor
    function new(string name="router_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED building router_base_test:    "), UVM_HIGH)
        super.build_phase(phase);
        tb = router_tb::type_id::create("tb", this);
        yapp_seq = yapp_5_packets_seq::type_id::create("yapp_seq", this);
        `uvm_info(get_type_name(), $sformatf("COMPLETED building router_base_test:  "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ end of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED ELABORATING router_base_test:    "), UVM_HIGH)
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        `uvm_info(get_type_name(), $sformatf("COMPLETED ELABORATING router_base_test:  "), UVM_LOW)
    endfunction : end_of_elaboration_phase

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

	// ------------------------------------------ report phase
    function void report_phase(uvm_phase phase);
        uvm_report_server rpt_svr;
        `uvm_info(get_type_name(), $sformatf("STARTED REPORTING router_base_test:      "), UVM_LOW)
		super.report_phase(phase);
		rpt_svr = uvm_report_server::get_server();
		if(rpt_svr.get_severity_count(UVM_FATAL) + rpt_svr.get_severity_count(UVM_ERROR) > 1) begin
			`uvm_info(get_type_name(), "-----------------------------------------------------------------------------", UVM_LOW)
			`uvm_info(get_type_name(), "--------------------------- TEST COMPILATION FAIL ---------------------------", UVM_LOW)
			`uvm_info(get_type_name(), "-----------------------------------------------------------------------------", UVM_LOW)
		end
		else begin
			`uvm_info(get_type_name(), "-----------------------------------------------------------------------------", UVM_LOW)
			`uvm_info(get_type_name(), "--------------------------- TEST COMPILATION PASS ---------------------------", UVM_LOW)
			`uvm_info(get_type_name(), "-----------------------------------------------------------------------------", UVM_LOW)
		end
        `uvm_info(get_type_name(), $sformatf("COMPLETED REPORTING router_base_test:    "), UVM_LOW)
	endfunction : report_phase

endclass : router_base_test
