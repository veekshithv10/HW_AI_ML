`timescale 1ns/1ps

module tb_interface;

    logic        clk;
    logic        rst_n;
    logic        s_axis_tvalid;
    logic [15:0] s_axis_tdata;
    logic        s_axis_tready;
    logic [7:0]  pixel_out;
    logic [7:0]  weight_out;
    logic        valid_to_core;

    // Instantiate using the module name inside interface.sv
    axis_interface dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .pixel_out(pixel_out),
        .weight_out(weight_out),
        .valid_to_core(valid_to_core)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        s_axis_tvalid = 0;
        s_axis_tdata  = 16'h0;

        #20 rst_n = 1;
        @(negedge clk);

        // Send Pixel=42 (2A hex), Weight=7
        $display("Master initiating AXI-Stream transaction...");
        s_axis_tvalid = 1;
        s_axis_tdata  = 16'h072A; 
        
        wait(s_axis_tvalid && s_axis_tready);
        @(negedge clk);
        s_axis_tvalid = 0;

        #1; // Allow signals to settle
        $display("========================================");
        if (pixel_out == 8'd42 && weight_out == 8'd7) begin
            $display("PASS: Interface correctly unpacked AXI data");
        end else begin
            $display("FAIL: Interface error. Got P=%d, W=%d", pixel_out, weight_out);
        end
        $display("========================================");

        #20;
        $finish;
    end

endmodule
