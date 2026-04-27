module mac (
(
    input  logic               clk,
    input  logic               rst,   // active-high synchronous reset
    input  logic signed [7:0]  a,
    input  logic signed [7:0]  b,
    output logic signed [31:0] out
);

    // Intermediate product (16-bit signed is sufficient for 8x8)
    logic signed [15:0] prod;

    always_ff @(posedge clk) begin
        if (rst) begin
            out <= 32'sd0;
        end else begin
            prod = a * b;               // combinational within clocked block
            out  <= out + prod;         // accumulate
        end
    end

endmodule