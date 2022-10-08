class router_tb extends uvm_env;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(router_tb)

    // ------------------------------------------ instances
    yapp_env yappenv;

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("STARTED building router_tb environment:     "), UVM_LOW)
        super.build_phase(phase);
        yappenv = yapp_env::type_id::create("yappenv", this);
        `uvm_info(get_type_name(), $sformatf("COMPLETED building router_tb environment:   "), UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ start of simulation phase
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED simulating router_tb environment:      ", get_full_name()}, UVM_HIGH)
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED simulating router_tb environment:    ", get_full_name()}, UVM_LOW)
    endfunction : start_of_simulation_phase

endclass : router_tb
