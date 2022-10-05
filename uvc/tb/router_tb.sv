class router_tb extends uvm_env;

    `uvm_component_utils(router_tb)

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED BUILDING router_tb environment:     "), UVM_LOW)
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("COMPLETED BUILDING router_tb environment:   "), UVM_LOW)
    endfunction : build_phase

endclass : router_tb