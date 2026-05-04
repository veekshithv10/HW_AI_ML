`timescale 1ns/1ps

/* ==============================================================================
 * Module Name: axis_interface
 * File Name:   interface.sv
 * Description: AXI4-Stream Slave interface for the CNN accelerator.
 * * Protocol: AXI4-Stream
 * Transaction Format: 
 * - s_axis_tdata [15:8] : Weight (8-bit signed)
 * - s_axis_tdata [7:0]  : Pixel  (8-bit signed)
 * * Port Documentation:
 * ------------------------------------------------------------------------------
 * Port Name      | Dir | Width | Purpose
 * ------------------------------------------------------------------------------
 * clk            | IN  | 1     | Main system clock
 * rst_n          | IN  | 1     | Asynchronous active-low reset
 * s_axis_tvalid  | IN  | 1     | Master indicates data is valid
 * s_axis_tdata   | IN  | 16    | Incoming packed pixel and weight
 * s_axis_tready  | OUT | 1     | Slave indicates it is ready to receive
 * pixel_out      | OUT | 8     | Unpacked pixel to compute_core
 * weight_out     | OUT | 8     | Unpacked weight to compute_core
 * valid_to_core  | OUT | 1     | Logic high when a handshake occurs
 * ==============================================================================
 */

module axis_interface (
    input  logic        clk,
    input  logic        rst_n,

    // AXI4-Stream Slave Signals
    input  logic        s_axis_tvalid,
    input  logic [15:0] s_axis_tdata,
    output logic        s_axis_tready,

    // Ports to Compute Core
    output logic [7:0]  pixel_out,
    output logic [7:0]  weight_out,
    output logic        valid_to_core
);

    // Ready as long as we aren't in reset
    assign s_axis_tready = rst_n;

    // Handshake occurs when Master is valid AND Slave is ready
    assign valid_to_core = s_axis_tvalid && s_axis_tready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_out  <= 8'd0;
            weight_out <= 8'd0;
        end else begin
            if (s_axis_tvalid && s_axis_tready) begin
                pixel_out  <= s_axis_tdata[7:0];
                weight_out <= s_axis_tdata[15:8];
            end
        end
    end

endmodule
