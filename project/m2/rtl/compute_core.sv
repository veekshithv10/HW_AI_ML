`timescale 1ns/1ps
/* ==============================================================================
 * Module Name: compute_core
 * File Name:   compute_core.sv
 * Description: 2D Convolution MAC unit for a 3x3 kernel window.
 * * Clock Domain Strategy: 
 * - Single clock domain (clk). All synchronous logic triggers on the rising edge.
 * * Reset Behavior:
 * - Asynchronous, active-low reset (rst_n).
 * * Port Documentation:
 * ------------------------------------------------------------------------------
 * Port Name    | Dir | Width      | Purpose
 * ------------------------------------------------------------------------------
 * clk          | IN  | 1 bit      | Main system clock
 * rst_n        | IN  | 1 bit      | Asynchronous active-low reset
 * valid_in     | IN  | 1 bit      | Asserted high when input data/weights are valid
 * pixel_in     | IN  | DATA_WIDTH | Streaming input feature map pixel
 * weight_in    | IN  | DATA_WIDTH | Streaming weight for convolution
 * valid_out    | OUT | 1 bit      | Asserted high when a 3x3 MAC result is ready
 * mac_out      | OUT | ACC_WIDTH  | Accumulated output pixel result
 * ==============================================================================
 */

module compute_core #(
    // Parameters to match your M1 Quantization choice
    parameter DATA_WIDTH = 8,  
    parameter ACC_WIDTH  = 16  
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    valid_in,
    input  logic [DATA_WIDTH-1:0]   pixel_in,
    input  logic [DATA_WIDTH-1:0]   weight_in,
    
    output logic                    valid_out,
    output logic [ACC_WIDTH-1:0]    mac_out
);

    // --------------------------------------------------------------------------
    // Internal Signals
    // --------------------------------------------------------------------------
    logic signed [ACC_WIDTH-1:0] mult_result;
    logic signed [ACC_WIDTH-1:0] accumulator;
    logic [3:0]                  pixel_count; // Counts from 0 to 8 for a 3x3 window

    // --------------------------------------------------------------------------
    // Combinational Logic (The Math)
    // --------------------------------------------------------------------------
    // Casting inputs to signed for hardware multiplication
    always_comb begin
        mult_result = $signed(pixel_in) * $signed(weight_in);
    end

    // --------------------------------------------------------------------------
    // Sequential Logic (Registers / Accumulation)
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= '0;
            valid_out   <= 1'b0;
            mac_out     <= '0;
            pixel_count <= '0;
        end else begin
            // Default valid_out to low unless we hit the 9th pixel
            valid_out <= 1'b0; 

            if (valid_in) begin
                if (pixel_count == 4'd8) begin
                    // 9th pixel of the 3x3 window: Output the result
                    mac_out     <= accumulator + mult_result;
                    valid_out   <= 1'b1;
                    
                    // Reset internal counters/accumulators for the next 3x3 window
                    accumulator <= '0;
                    pixel_count <= '0;
                end else begin
                    // Keep accumulating
                    accumulator <= accumulator + mult_result;
                    pixel_count <= pixel_count + 1'b1;
                end
            end
        end
    end

endmodule
