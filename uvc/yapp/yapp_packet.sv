typedef enum bit {BAD_PARIY, GOOD_PARITY} parity_t;

class yapp_packet extends uvm_sequence_item;

    // ------------------------------------------ declare IO signals
    rand bit [1:0]  addr;
    rand bit [5:0]  length;
    rand bit [7:0]  payload [];
    rand bit        parity;

    // ------------------------------------------ control knobs
    rand parity_t parity_type;
    rand int packet_delay;

    // ------------------------------------------ UVM utility and field macros
    `uvm_object_utils_begin(yapp_packet)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(length, UVM_ALL_ON | UVM_DEC)
        `uvm_field_array_int(payload, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(parity, UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
        `uvm_field_int(packet_delay, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // ------------------------------------------ constructor
    function new(string name="yapp_packet");
        super.new(name);
    endfunction : new

    // ------------------------------------------ constraints
    constraint c_addr_range     {addr != 2'd3;}
    constraint c_packet_length  {length >= 1; length <= 63;}
    constraint c_payload_size   {length == payload.size();}
    constraint c_packet_delay   {packet_delay >= 1; packet_delay <= 20;}
    constraint c_parity_dist    {parity_type dist {BAD_PARIY := 1, GOOD_PARITY := 5};}

    // ------------------------------------------ calculates parity
    function bit [7:0] calc_parity();
        calc_parity = {length, addr};
        for (int i=0; i<length; i++) begin
            calc_parity = calc_parity ^ payload[i];
        end
    endfunction : calc_parity

    // ------------------------------------------ set parity field according to parity_type
    function void set_parity();
        parity = calc_parity();
        if(parity == BAD_PARIY)
            parity++;
    endfunction : set_parity

    // ------------------------------------------ sets parity
    function void post_randomize();
        set_parity();
    endfunction : post_randomize

endclass : yapp_packet