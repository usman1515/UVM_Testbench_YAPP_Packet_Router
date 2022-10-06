class yapp_tx_driver extends uvm_driver #(yapp_packet);

    // ------------------------------------------ UVM macros
    `uvm_component_utils(yapp_tx_driver)

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED building yapp_tx_driver:      ", get_full_name()}, UVM_HIGH)
        super.build_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED building yapp_tx_driver:    ", get_full_name()}, UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ start of simulation phase
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED simulating yapp_tx_driver:      ", get_full_name()}, UVM_HIGH)
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), {"COMPLETED simulating yapp_tx_driver:    ", get_full_name()}, UVM_LOW)
    endfunction : start_of_simulation_phase

    // ------------------------------------------ drive task
    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED running yapp_tx_driver:      ", get_full_name()}, UVM_HIGH)
        forever begin
            // gets a new transaction from the sequencer once current transaction has finished
            seq_item_port.get_next_item(req);
            // drive respective interface signals
            send_to_dut(req);
            // inform sequencer that the current operation with transaction has finished
            seq_item_port.item_done();
        end
        `uvm_info(get_type_name(), {"COMPLETED running yapp_tx_driver:    ", get_full_name()}, UVM_LOW)
    endtask : run_phase

    // ------------------------------------------ task sending data to dut
    task send_to_dut(yapp_packet packet);
        `uvm_info(get_type_name(), {"STARTED sending yapp_packet yapp_tx_driver:    ", get_full_name()}, UVM_HIGH)
        `uvm_info(get_type_name(), $sformatf("Input Packet to Send:\n%s             ", packet.sprint()), UVM_LOW)
        `uvm_info(get_type_name(), {"COMPLETED sending yapp_packet yapp_tx_driver:  ", get_full_name()}, UVM_LOW)
        #10ns;
    endtask : send_to_dut

endclass : yapp_tx_driver