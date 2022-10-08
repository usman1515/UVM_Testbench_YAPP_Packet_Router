class yapp_tx_agent extends uvm_agent;

    // ------------------------------------------ UVM macros
    `uvm_component_utils(yapp_tx_agent)

    yapp_tx_sequencer   yapp_tx_seqr;
    yapp_tx_driver      yapp_tx_drv;
    yapp_tx_monitor     yapp_tx_mon;

    // ------------------------------------------ constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    // ------------------------------------------ build phase
    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED building yapp_tx_agent:      ", get_full_name()}, UVM_HIGH)
        super.build_phase(phase);
        // creating yapp_tx_seqr and yapp_tx_drv for ACTIVE agent only
        if(get_is_active() == UVM_ACTIVE) begin
            yapp_tx_seqr = yapp_tx_sequencer::type_id::create("yapp_tx_seqr", this);
            yapp_tx_drv = yapp_tx_driver::type_id::create("yapp_tx_drv", this);
        end
        yapp_tx_mon = yapp_tx_monitor::type_id::create("yapp_tx_mon", this);
        `uvm_info(get_type_name(), {"COMPLETED building yapp_tx_agent:    ", get_full_name()}, UVM_LOW)
    endfunction : build_phase

    // ------------------------------------------ connect phase
    function void connect_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"STARTED connecting yapp_tx_agent:      ", get_full_name()}, UVM_HIGH)
        super.connect_phase(phase);
        // connect yapp_tx_seqr to yapp_tx_drv for ACTIVE agent only
        if(get_is_active == UVM_ACTIVE) begin
            yapp_tx_drv.seq_item_port.connect(yapp_tx_seqr.seq_item_export);
        end
        `uvm_info(get_type_name(), {"COMPLETED connecting yapp_tx_agent:    ", get_full_name()}, UVM_LOW)
    endfunction : connect_phase

endclass : yapp_tx_agent