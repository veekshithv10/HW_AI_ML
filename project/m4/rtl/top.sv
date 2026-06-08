`timescale 1ns/1ps

module top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // AXI4-Stream Slave (Host to Device) - WIDENED FOR M4
    input  logic                  s_axis_tvalid,
    input  logic [71:0]           s_axis_tdata,
    output logic                  s_axis_tready,

    // AXI4-Stream Master (Device to Host)
    output logic                  m_axis_tvalid,
    output logic [ACC_WIDTH-1:0]  m_axis_tdata
);

    logic [71:0] intf_to_core_payload;
    logic        intf_to_core_valid;

    axis_interface u_interface (
        .clk            (clk),
        .rst_n          (rst_n),
        .s_axis_tvalid  (s_axis_tvalid),
        .s_axis_tdata   (s_axis_tdata),
        .s_axis_tready  (s_axis_tready),
        .payload_out    (intf_to_core_payload),
        .valid_to_core  (intf_to_core_valid)
    );

    compute_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_compute_core (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_in       (intf_to_core_valid),
        .payload_in     (intf_to_core_payload),
        .valid_out      (m_axis_tvalid),  
        .mac_out        (m_axis_tdata)    
    );

endmodule
