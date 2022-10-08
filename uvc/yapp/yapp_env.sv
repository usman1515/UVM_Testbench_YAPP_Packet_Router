class yapp_env extends uvm_env;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(yapp_env)

    yapp_tx_agent yapp_tx_agnt;

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED building yapp_env:      ", get_full_name()}, UVM_HIGH)
        super.build_phase(phase);
        yapp_tx_agnt = yapp_tx_agent::type_id::create("yapp_tx_agnt", this);
        `uvm_info(get_type_name(), {"COMPLETED building yapp_env:    ", get_full_name()}, UVM_LOW)
    endfunction : build_phase

endclass : yapp_env