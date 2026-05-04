`timescale 1ns/1ps

module tb_compute_core;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 16;

    // Signals
    logic                    clk;
    logic                    rst_n;
    logic                    valid_in;
    logic [DATA_WIDTH-1:0]   pixel_in;
    logic [DATA_WIDTH-1:0]   weight_in;
    logic                    valid_out;
    logic [ACC_WIDTH-1:0]    mac_out;

    // Independent reference calculation variable
    logic [ACC_WIDTH-1:0]    expected_mac;

    // Instantiate DUT (Device Under Test)
    compute_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .pixel_in(pixel_in),
        .weight_in(weight_in),
        .valid_out(valid_out),
        .mac_out(mac_out)
    );

    // Clock Generation (10ns period / 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Test Sequence
    initial begin
        // Setup waveforms
        $dumpfile("compute_core_waves.vcd");
        $dumpvars(0, tb_compute_core);

        // 1. Initialize
        rst_n        = 0;
        valid_in     = 0;
        pixel_in     = 0;
        weight_in    = 0;
        expected_mac = 0;

        // 2. Release Reset
        #20;
        rst_n = 1;
        #10;

        $display("Starting 3x3 Convolution Test...");
        
        // Feed data on the NEGATIVE edge so it is stable for the hardware's POSITIVE edge
        @(negedge clk);
        
        // 3. Feed 9 pixels (1 through 9) with a weight of 2
        for (int i = 1; i <= 9; i++) begin
            valid_in  = 1;
            pixel_in  = i;      
            weight_in = 2;      
            
            // INDEPENDENT CALCULATION (Software Model)
            expected_mac = expected_mac + (i * 2);
            
            @(negedge clk);
        end

        // 4. Stop feeding data
        valid_in  = 0;
        pixel_in  = 0;
        weight_in = 0;

        // Wait for the hardware to assert valid_out
        wait(valid_out == 1'b1);
        
        // Wait one more tiny tick for the signals to settle perfectly on the waveform
        #1; 
        
        // 5. AUTOMATED COMPARISON (Prints PASS/FAIL)
        $display("========================================");
        if (mac_out === expected_mac) begin
            $display("PASS: Hardware output (%0d) matches expected (%0d)", mac_out, expected_mac);
        end else begin
            $display("FAIL: Hardware output (%0d) does NOT match expected (%0d)", mac_out, expected_mac);
        end
        $display("========================================");

        #20;
        $finish;
    end

endmodule
