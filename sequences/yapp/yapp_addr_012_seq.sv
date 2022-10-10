class yapp_addr_012_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_addr_012_seq)

    // ------------------------------------------ component instances
    yapp_packet req1;

    // ------------------------------------------ constructor
    function new(string name="yapp_addr_012_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_type_name(), {"STARTED running yapp_addr_012_seq:    ", get_full_name()}, UVM_LOW)
        req1 = yapp_packet::type_id::create("req1");
        `uvm_do_with(req1, { req1.addr == 2'd0; })
        `uvm_do_with(req1, { req1.addr == 2'd1; })
        `uvm_do_with(req1, { req1.addr == 2'd2; })
        `uvm_info(get_type_name(), {"COMPLETED running yapp_addr_012_seq:  ", get_full_name()}, UVM_LOW)
    endtask : body

endclass : yapp_addr_012_seq