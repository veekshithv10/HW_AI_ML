`timescale 1ns/1ps

module axis_interface (
    input  logic        clk,
    input  logic        rst_n,

    // AXI4-Stream Slave Signals (WIDENED TO 72 BITS)
    input  logic        s_axis_tvalid,
    input  logic [71:0] s_axis_tdata, 
    output logic        s_axis_tready,

    // Ports to Compute Core
    output logic [71:0] payload_out,
    output logic        valid_to_core
);

    // Ready as long as we aren't in reset
    assign s_axis_tready = rst_n;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            payload_out   <= 72'd0;
            valid_to_core <= 1'b0;
        end else begin
            payload_out   <= s_axis_tdata;
            valid_to_core <= (s_axis_tvalid && s_axis_tready);
        end
    end

endmodule
