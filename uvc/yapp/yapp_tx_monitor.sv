class yapp_tx_monitor extends uvm_monitor;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(yapp_tx_monitor)

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED building yapp_tx_monitor:      ", get_full_name()}, UVM_HIGH)
        super.build_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED building yapp_tx_monitor:    ", get_full_name()}, UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ run phase
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED running yapp_tx_monitor:      ", get_full_name()}, UVM_HIGH)
        `uvm_info(get_type_name(), {"COMPLETED running yapp_tx_monitor:    ", get_full_name()}, UVM_LOW)
    endtask : run_phase

endclass : yapp_tx_monitor