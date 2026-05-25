`timescale 1ns/1ps

module tb_top;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 16;

    // Signals
    logic                  clk;
    logic                  rst_n;

    // Host to Device (AXI-Stream Slave)
    logic                  s_axis_tvalid;
    logic [15:0]           s_axis_tdata;
    logic                  s_axis_tready;

    // Device to Host (AXI-Stream Master)
    logic                  m_axis_tvalid;
    logic [ACC_WIDTH-1:0]  m_axis_tdata;

    // Independent reference calculation variable
    logic signed [ACC_WIDTH-1:0] expected_mac;

    // Instantiate the Integrated Top Module
    top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata(m_axis_tdata)
    );

    // Clock Generation (10ns period / 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Test Sequence
    initial begin
        // Setup waveforms
        $dumpfile("cosim_waves.vcd");
        $dumpvars(0, tb_top);

        // 1. Initialize
        rst_n         = 0;
        s_axis_tvalid = 0;
        s_axis_tdata  = 0;
        expected_mac  = 0;

        // 2. Release Reset
        #20;
        rst_n = 1;
        #10;

        $display("Starting End-to-End 3x3 Convolution Test...");
        
        // 3. Feed 9 pixels (1 through 9) with a weight of 2 via AXI-Stream
        for (int i = 1; i <= 9; i++) begin
            @(negedge clk); // Drive on negedge for stability
            
            s_axis_tvalid = 1;
            // Pack AXI Data: Weight in [15:8], Pixel in [7:0]
            s_axis_tdata  = {8'(2), 8'(i)}; 
            
            // Wait for handshake (valid and ready)
            wait(s_axis_tready == 1'b1);
            
            // INDEPENDENT CALCULATION (Software Model)
            expected_mac = expected_mac + (i * 2);
        end

        // 4. Stop feeding data
        @(negedge clk);
        s_axis_tvalid = 0;
        s_axis_tdata  = 0;

        // Wait for the hardware to assert m_axis_tvalid (Result returning to host)
        wait(m_axis_tvalid == 1'b1);
        
        // Wait one more tiny tick for signals to settle
        #1; 
        
        // 5. AUTOMATED COMPARISON (Prints PASS/FAIL)
        $display("========================================");
        if (m_axis_tdata === expected_mac) begin
            $display("PASS: Hardware output (%0d) matches expected (%0d)", m_axis_tdata, expected_mac);
        end else begin
            $display("FAIL: Hardware output (%0d) does NOT match expected (%0d)", m_axis_tdata, expected_mac);
        end
        $display("========================================");

        #40;
        $finish;
    end

endmodule
