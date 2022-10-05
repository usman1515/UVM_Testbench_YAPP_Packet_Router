class router_base_test extends uvm_test;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_base_test)

    // ------------------------------------------ constructor
    function new(string name="router_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED BUILDING router_base_test:    "), UVM_HIGH)
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("COMPLETED BUILDING router_base_test:  "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ end of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED ELABORATING router_base_test:    "), UVM_HIGH)
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        `uvm_info(get_type_name(), $sformatf("COMPLETED ELABORATING router_base_test:  "), UVM_LOW)
    endfunction : end_of_elaboration_phase


endclass : router_base_test