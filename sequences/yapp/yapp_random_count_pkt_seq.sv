class yapp_random_count_pkt_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_random_count_pkt_seq)

    // ------------------------------------------ component instances
    yapp_packet req1;
    rand int count;

    // constraint c_pkt_count {count >= 1; count <= 10;}
    constraint c_pkt_count {count inside {[1:10]};}

    // ------------------------------------------ constructor
    function new(string name="yapp_random_count_pkt_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_type_name(), {"STARTED running yapp_random_count_pkt_seq:    ", get_full_name()}, UVM_LOW)
        req1 = yapp_packet::type_id::create("req1");
        `uvm_info(get_type_name(), $sformatf("Random packet count: %d", count), UVM_LOW)
        repeat(count)
            `uvm_do(req1)
        `uvm_info(get_type_name(), {"COMPLETED running yapp_random_count_pkt_seq:  ", get_full_name()}, UVM_LOW)
    endtask : body

endclass : yapp_random_count_pkt_seq