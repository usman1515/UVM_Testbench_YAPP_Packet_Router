class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);

    // ------------------------------------------ UVM macros
    `uvm_component_utils(yapp_tx_sequencer)

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED building yapp_tx_sequencer:      ", get_full_name()}, UVM_HIGH)
        super.build_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED building yapp_tx_sequencer:    ", get_full_name()}, UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ start of simulation phase
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED simulating yapp_tx_sequencer:      ", get_full_name()}, UVM_HIGH)
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED simulating yapp_tx_sequencer:    ", get_full_name()}, UVM_LOW)
    endfunction : start_of_simulation_phase

endclass : yapp_tx_sequencer