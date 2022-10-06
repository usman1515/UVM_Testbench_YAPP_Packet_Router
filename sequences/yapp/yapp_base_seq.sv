class yapp_base_seq extends uvm_sequence #(yapp_packet);

    `uvm_object_utils(yapp_base_seq)

    function new(string name="yapp_base_seq");
        super.new(name);
    endfunction : new

    task pre_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else
            phase = starting_phase;
        `endif
        if (phase != null) begin
            phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise objection yapp_base_seq", UVM_LOW)
        end
    endtask : pre_body

    task post_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else
            phase = starting_phase;
        `endif
        if (phase != null) begin
            phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop objection yapp_base_seq", UVM_LOW)
        end
    endtask : post_body

endclass : yapp_base_seq