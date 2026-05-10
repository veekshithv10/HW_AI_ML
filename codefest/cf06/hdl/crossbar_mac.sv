`timescale 1ns/1ps

module crossbar_mac (
    input  logic               clk,
    input  logic               rst_n,
    // Icarus-proof: individual ports instead of arrays
    input  logic signed [7:0]  in0, in1, in2, in3,
    // Icarus-proof: one giant 32-bit vector holding 16 weights (2 bits each)
    input  logic [31:0]        weight_packed,
    output logic signed [15:0] out0, out1, out2, out3
);

    logic signed [15:0] next_out0, next_out1, next_out2, next_out3;

    // Unpack the weights internally
    logic signed [1:0] w00, w01, w02, w03;
    logic signed [1:0] w10, w11, w12, w13;
    logic signed [1:0] w20, w21, w22, w23;
    logic signed [1:0] w30, w31, w32, w33;

    assign {w33, w32, w31, w30, w23, w22, w21, w20, w13, w12, w11, w10, w03, w02, w01, w00} = weight_packed;

    // Hardcode the combinational math (bypasses array issues completely)
    always_comb begin
        next_out0 = (in0 * w00) + (in1 * w10) + (in2 * w20) + (in3 * w30);
        next_out1 = (in0 * w01) + (in1 * w11) + (in2 * w21) + (in3 * w31);
        next_out2 = (in0 * w02) + (in1 * w12) + (in2 * w22) + (in3 * w32);
        next_out3 = (in0 * w03) + (in1 * w13) + (in2 * w23) + (in3 * w33);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out0 <= '0; out1 <= '0; out2 <= '0; out3 <= '0;
        end else begin
            out0 <= next_out0; out1 <= next_out1; out2 <= next_out2; out3 <= next_out3;
        end
    end

endmodule
