class yapp_incr_payload_seq extends yapp_base_seq;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_incr_payload_seq)

    // ------------------------------------------ component instances
    yapp_packet req1;
    rand bit [5:0] pkt_len;
    int ok;

    // ------------------------------------------ constructor
    function new(string name="yapp_incr_payload_seq");
        super.new(name);
    endfunction : new

    // virtual task body();
    //     `uvm_info(get_type_name(), {"STARTED running yapp_incr_payload_seq:    ", get_full_name()}, UVM_LOW)
    //     req1 = yapp_packet::type_id::create("req1");
    //     for (int i=0; i<33; i=i+3) begin
    //         `uvm_do_with(req1, { req1.length == i; })
    //     end
    //     `uvm_info(get_type_name(), {"COMPLETED running yapp_incr_payload_seq:  ", get_full_name()}, UVM_LOW)
    // endtask : body

	virtual task body();
		`uvm_info(get_type_name(), {"STARTED running yapp_incr_payload_seq:    ", get_full_name()}, UVM_LOW)
		`uvm_create(req)
		ok = req.randomize();
		foreach(req.payload[i])
			req.payload[i] = i;
		req.set_parity();
		`uvm_send(req)
        `uvm_info(get_type_name(), {"COMPLETED running yapp_incr_payload_seq:  ", get_full_name()}, UVM_LOW)
	endtask : body

endclass : yapp_incr_payload_seq