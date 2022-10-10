class yapp_exhaustive_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_exhaustive_seq)

    // ------------------------------------------ component instances
    yapp_addr_1_seq             yapp_seq_addr_1;
    yapp_addr_012_seq           yapp_seq_addr_012;
    yapp_3_pkt_addr_1_seq       yapp_seq_3_pkt_addr_1;
    yapp_2_pkt_repeat_addr_seq  yapp_seq_2_pkt_same_addr;
    yapp_5_pkt_seq              yapp_seq_5_pkt;
    yapp_incr_payload_seq       yapp_seq_incr_payload;
    yapp_random_count_pkt_seq   yapp_seq_random_count_pkt;
    yapp_6_pkt_seq              yapp_seq_6_pkt;

    // ------------------------------------------ constructor
    function new(string name="yapp_exhaustive_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_type_name(), {"STARTED running yapp_exhaustive_seq:    ", get_full_name()}, UVM_LOW)
        req = yapp_packet::type_id::create("req");
        yapp_seq_addr_1 = yapp_addr_1_seq::type_id::create("yapp_seq_addr_1");
        yapp_seq_addr_012 = yapp_addr_012_seq::type_id::create("yapp_seq_addr_012");
        yapp_seq_3_pkt_addr_1 = yapp_3_pkt_addr_1_seq::type_id::create("yapp_seq_3_pkt_addr_1");
        yapp_seq_2_pkt_same_addr = yapp_2_pkt_repeat_addr_seq::type_id::create("yapp_seq_2_pkt_same_addr");
        yapp_seq_5_pkt = yapp_5_pkt_seq::type_id::create("yapp_seq_5_pkt");
        yapp_seq_incr_payload = yapp_incr_payload_seq::type_id::create("yapp_seq_incr_payload");
        yapp_seq_random_count_pkt = yapp_random_count_pkt_seq::type_id::create("yapp_seq_random_count_pkt");
        yapp_seq_6_pkt = yapp_6_pkt_seq::type_id::create("yapp_6_pkt_seq");
        repeat(1) begin
            `uvm_info(get_type_name(), "RUNNING yapp_addr_1_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_addr_1)
            `uvm_info(get_type_name(), "RUNNING yapp_addr_012_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_addr_012)
            `uvm_info(get_type_name(), "RUNNING yapp_3_pkt_addr_1_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_3_pkt_addr_1)
            `uvm_info(get_type_name(), "RUNNING yapp_2_pkt_repeat_addr_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_2_pkt_same_addr)
            `uvm_info(get_type_name(), "RUNNING yapp_5_pkt_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_5_pkt)
            `uvm_info(get_type_name(), "RUNNING yapp_incr_payload_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_incr_payload)
            `uvm_info(get_type_name(), "RUNNING yapp_random_count_pkt_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_random_count_pkt)
            `uvm_info(get_type_name(), "RUNNING yapp_6_pkt_seq: ", UVM_LOW)
            `uvm_do(yapp_seq_6_pkt)
        end
        `uvm_info(get_type_name(), {"COMPLETED running yapp_exhaustive_seq:  ", get_full_name()}, UVM_LOW)
    endtask : body

endclass : yapp_exhaustive_seq