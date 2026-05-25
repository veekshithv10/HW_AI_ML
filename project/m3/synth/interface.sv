`timescale 1ns/1ps

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

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_out     <= 8'd0;
            weight_out    <= 8'd0;
            valid_to_core <= 1'b0; // FIX: valid is now registered!
        end else begin
            // FIX: valid and data both update on the same clock edge
            pixel_out     <= s_axis_tdata[7:0];
            weight_out    <= s_axis_tdata[15:8];
            valid_to_core <= (s_axis_tvalid && s_axis_tready);
        end
    end

endmodule
