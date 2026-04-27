module mac (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [7:0]  a,
    input  logic signed [7:0]  b,
    output logic signed [31:0] out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            out <= 32'sd0;
        end else begin
            // Explicitly casting the 16-bit product to 32-bit signed 
            // to ensure proper sign extension during accumulation
            out <= out + 32'(a * b);
        end
    end

endmodule
