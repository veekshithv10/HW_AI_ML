`timescale 1ns/1ps

module crossbar_tb;

    logic               clk;
    logic               rst_n;
    logic signed [7:0]  in0, in1, in2, in3;
    logic [31:0]        weight_packed;
    logic signed [15:0] out0, out1, out2, out3;

    crossbar_mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .weight_packed(weight_packed),
        .out0(out0), .out1(out1), .out2(out2), .out3(out3)
    );

    // Generate a clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize System
        clk = 0;
        rst_n = 0;
        in0 = 0; in1 = 0; in2 = 0; in3 = 0;

        // Load the packed weights
        weight_packed = {
            2'b01, 2'b11, 2'b11, 2'b11, // Row 3
            2'b11, 2'b01, 2'b01, 2'b11, // Row 2
            2'b11, 2'b11, 2'b01, 2'b01, // Row 1
            2'b11, 2'b01, 2'b11, 2'b01  // Row 0
        };

        // 2. Release Reset on a negative clock edge
        @(negedge clk);
        rst_n = 1;

        // 3. Apply Inputs on the next negative edge
        @(negedge clk);
        in0 = 10;
        in1 = 20;
        in2 = 30;
        in3 = 40;

        // 4. Wait for the rising edge to compute/latch, then check on the next negative edge
        @(negedge clk); 

        // 5. Assertions (Self-Checking Testbench)
        // Changed from $error to $fatal(1, ...) so the simulation HALTS immediately on failure!
        assert(out0 == -40) else $fatal(1, "out[0] mismatch! Expected -40, got %0d", out0);
        assert(out1 == 0)   else $fatal(1, "out[1] mismatch! Expected 0, got %0d", out1);
        assert(out2 == -20) else $fatal(1, "out[2] mismatch! Expected -20, got %0d", out2);
        assert(out3 == -20) else $fatal(1, "out[3] mismatch! Expected -20, got %0d", out3);

        // 6. Print Results to Terminal (Will ONLY execute if all assertions pass)
        $display("\n=================================");
        $display("   CROSSBAR MAC SIMULATION LOG   ");
        $display("=================================");
        $display("Inputs: [%0d, %0d, %0d, %0d]", in0, in1, in2, in3);
        $display("---------------------------------");
        $display("out[0] = %0d \t(Expected: -40)", out0);
        $display("out[1] = %0d \t(Expected: 0)", out1);
        $display("out[2] = %0d \t(Expected: -20)", out2);
        $display("out[3] = %0d \t(Expected: -20)", out3);
        $display("=================================\n");
        $display("ALL ASSERTIONS PASSED SUCCESSFULLY!");
        $display("=================================\n");

        #10 $finish;
    end

endmodule
