class yapp_2_pkt_repeat_addr_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_2_pkt_repeat_addr_seq)

    // ------------------------------------------ component instances
    yapp_packet req1;

    rand bit [1:0] seq_addr;
    constraint c_repeat_addr {seq_addr != 2'd3;}

    // ------------------------------------------ constructor
    function new(string name="yapp_2_pkt_repeat_addr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_type_name(), {"STARTED running yapp_2_pkt_repeat_addr_seq:    ", get_full_name()}, UVM_LOW)
        req1 = yapp_packet::type_id::create("req1");
        repeat(2)
            `uvm_do_with(req1, { req1.addr == seq_addr; })
        `uvm_info(get_type_name(), {"COMPLETED running yapp_2_pkt_repeat_addr_seq:  ", get_full_name()}, UVM_LOW)
    endtask : body

endclass : yapp_2_pkt_repeat_addr_seq