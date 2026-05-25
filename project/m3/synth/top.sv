`timescale 1ns/1ps

/* ==============================================================================
 * Module Name: top
 * File Name:   top.sv
 * Description: M3 Integrated Top Module connecting AXI4-Stream Interface and Compute Core.
 * * * Port Documentation:
 * ------------------------------------------------------------------------------
 * Port Name     | Dir | Width | Purpose
 * ------------------------------------------------------------------------------
 * clk           | IN  | 1     | Main system clock
 * rst_n         | IN  | 1     | Asynchronous active-low reset
 * s_axis_tvalid | IN  | 1     | Host indicates input data is valid
 * s_axis_tdata  | IN  | 16    | Incoming packed pixel (7:0) and weight (15:8)
 * s_axis_tready | OUT | 1     | Device indicates it is ready to receive
 * m_axis_tvalid | OUT | 1     | Device indicates MAC result is valid to host
 * m_axis_tdata  | OUT | 16    | Output MAC result (16-bit)
 * ==============================================================================
 * * Glue Logic Identified and Explained:
 * - The AXI4-Stream Slave interface parses incoming host data.
 * - To fulfill the requirement of returning results to the host, the raw 
 * outputs from the compute core (`valid_out` and `mac_out`) act as the glue logic, 
 * mapped directly to an outgoing AXI4-Stream Master interface 
 * (`m_axis_tvalid` and `m_axis_tdata`).
 * ==============================================================================
 */

module top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // AXI4-Stream Slave (Host to Device)
    input  logic                  s_axis_tvalid,
    input  logic [15:0]           s_axis_tdata,
    output logic                  s_axis_tready,

    // AXI4-Stream Master (Device to Host)
    output logic                  m_axis_tvalid,
    output logic [ACC_WIDTH-1:0]  m_axis_tdata
);

    // --------------------------------------------------------------------------
    // Inter-module Wires
    // --------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] intf_to_core_pixel;
    logic [DATA_WIDTH-1:0] intf_to_core_weight;
    logic                  intf_to_core_valid;

    // --------------------------------------------------------------------------
    // Module Instantiations
    // --------------------------------------------------------------------------
    
    // Host Interface Module
    axis_interface u_interface (
        .clk            (clk),
        .rst_n          (rst_n),
        .s_axis_tvalid  (s_axis_tvalid),
        .s_axis_tdata   (s_axis_tdata),
        .s_axis_tready  (s_axis_tready),
        .pixel_out      (intf_to_core_pixel),
        .weight_out     (intf_to_core_weight),
        .valid_to_core  (intf_to_core_valid)
    );

    // 2D Convolution MAC Compute Core
    compute_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_compute_core (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_in       (intf_to_core_valid),
        .pixel_in       (intf_to_core_pixel),
        .weight_in      (intf_to_core_weight),
        .valid_out      (m_axis_tvalid),  // Glue logic: Output mapping
        .mac_out        (m_axis_tdata)    // Glue logic: Output mapping
    );

endmodule

