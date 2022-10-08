class yapp_packet_short extends yapp_packet;

    // ------------------------------------------ UVM macros
    `uvm_object_utils(yapp_packet_short)

    // ------------------------------------------ constructor
    function new(string name="yapp_packet_short");
        super.new(name);
    endfunction : new

    // ------------------------------------------ constraints
    constraint c_packet_length_short    {length >=1; length <= 15;}
    constraint c_addr_range_short       {addr != 2'd2;}

endclass : yapp_packet_short