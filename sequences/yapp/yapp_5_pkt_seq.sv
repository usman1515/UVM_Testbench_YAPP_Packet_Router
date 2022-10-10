class yapp_5_pkt_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_5_pkt_seq)

    // ------------------------------------------ component instances
    yapp_packet req;

    // ------------------------------------------ constructor
    function new(string name="yapp_5_pkt_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_type_name(), {"STARTED running yapp_5_pkt_seq:    ", get_full_name()}, UVM_LOW)
        req = yapp_packet::type_id::create("req");
        repeat(5)
            `uvm_do(req)
        // `uvm_do_with(req, { req.length == 6'd10; })
        // `uvm_do_with(req, { req.length == 6'd20; })
        // `uvm_do_with(req, { req.length == 6'd30; })
        // `uvm_do_with(req, { req.length == 6'd40; })
        // `uvm_do_with(req, { req.length == 6'd50; })
        `uvm_info(get_type_name(), {"COMPLETED running yapp_5_pkt_seq:  ", get_full_name()}, UVM_LOW)
    endtask : body

endclass : yapp_5_pkt_seq