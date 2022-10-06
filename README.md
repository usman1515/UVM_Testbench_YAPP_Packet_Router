# UVM Testbench - YAPP Packet Router

## Project Overview
This repo as part of my training was to design a UVM based testbench for a YAPP router design. The testbench was designed as a series of exercises provided by the Cadence course "SystemVerilog Accelerated Verification Using UVM". However I tried to build all the UVC components from scratch.

## YAPP Router Description
The YAPP router accepts data packets on a single input port, `in_data`, and routes the packets to one of three output channels: `channel0`, `channel1` or `channel2`. The input and output ports have slightly different signal protocols. The router also has an HBUS host interface for programming registers that are described in the next section.

<!-- insert YAPP packet router diagram -->

## Packet Data Specification
A packet is a sequence of bytes with the first byte containing a header, the next variable set of bytes containing payload, and the last byte containing parity.

The **header** consists of a `2-bit address` field and a `6-bit length` field. The address field is used to determine which output channel the packet should be routed to, with the address 3 being illegal. The
length field specifies the number of data bytes (payload).

A packet can have a minimum **payload** size of `1 byte` and a maximum size of `63 bytes`.

The **parity** should be a `byte of even, bitwise parity`, calculated over the header and payload bytes of the packet.

<!-- insert packet structure diagram -->

## Directory Structure
```bash
```