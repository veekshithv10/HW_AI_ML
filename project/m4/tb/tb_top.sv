`timescale 1ns/1ps
module tb_top();
    logic        clk;
    logic        rst_n;
    logic        s_axis_tvalid;
    logic [71:0] s_axis_tdata;
    logic        s_axis_tready;
    logic        m_axis_tvalid;
    logic [15:0] m_axis_tdata;

    top u_top (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tdata  (s_axis_tdata),
        .s_axis_tready (s_axis_tready),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tdata  (m_axis_tdata)
    );

    // 12 ns = 83.3 MHz, matching CLOCK_PERIOD in config.json
    always #6 clk = ~clk;

    // Timeout watchdog
    initial begin
        #5000;
        $fatal(1, "TIMEOUT: simulation hung");
    end

    // ----------------------------------------------------------------
    // Task: load weights then stream one pixel window, check result
    // ----------------------------------------------------------------
    task automatic run_test(
        input string        test_name,
        input logic [71:0]  weights,
        input logic [71:0]  pixels,
        input logic signed [15:0] expected
    );
        // --- Load weights ---
        @(posedge clk);
        s_axis_tvalid <= 1;
        s_axis_tdata  <= weights;
        @(posedge clk);

        // --- Stream pixels (keep valid high so COMPUTE sees valid_in=1) ---
        s_axis_tdata  <= pixels;
        @(posedge clk);

        // --- Drop valid: data consumed by core this cycle ---
        s_axis_tvalid <= 0;
        s_axis_tdata  <= 72'd0;

        // --- Wait for result through 3-stage pipeline ---
        wait (m_axis_tvalid);
        @(posedge clk);

        // --- Check ---
        if ($signed(m_axis_tdata) == expected) begin
            $display("  PASS [%s]: got %0d, expected %0d",
                     test_name, $signed(m_axis_tdata), expected);
        end else begin
            $fatal(1, "  FAIL [%s]: got %0d, expected %0d",
                   test_name, $signed(m_axis_tdata), expected);
        end

        // Drain pipeline + reset for next test
        repeat (6) @(posedge clk);
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);
    endtask

    // ----------------------------------------------------------------
    // Expected value math (done at elaboration time for clarity)
    // ----------------------------------------------------------------
    // Test 1: weights all 1s, pixels {10,20,30,40,50,60,70,80,90}
    //   (10*1)+(20*1)+(30*1)+(40*1)+(50*1)+(60*1)+(70*1)+(80*1)+(90*1)
    //   = 10+20+30+40+50+60+70+80+90 = 450
    localparam signed [15:0] EXP_1 = 16'sd450;

    // Test 2: mixed non-trivial signed weights
    //   weights: {2, -3, 4, -1, 5, -2, 3, -4, 1}   (signed INT8)
    //   pixels:  {10, 20, 30, 40, 50, 60, 70, 80, 90}
    //
    //   The bus packs element[0] at bits [7:0], element[8] at bits [71:64]
    //   so the array index maps as:
    //   incoming_data[0]=10, [1]=20, [2]=30, [3]=40, [4]=50,
    //                  [5]=60, [6]=70, [7]=80, [8]=90
    //   weight_cache[0]=2,   [1]=-3, [2]=4,  [3]=-1, [4]=5,
    //                  [5]=-2, [6]=3, [7]=-4, [8]=1
    //
    //   Products:
    //   10* 2 =   20
    //   20*-3 =  -60
    //   30* 4 =  120
    //   40*-1 =  -40
    //   50* 5 =  250
    //   60*-2 = -120
    //   70* 3 =  210
    //   80*-4 = -320
    //   90* 1 =   90
    //   ----------
    //   Sum   =  150
    localparam signed [15:0] EXP_2 = 16'sd150;

    // ----------------------------------------------------------------
    // Stimulus
    // ----------------------------------------------------------------
    initial begin
        $dumpfile("final_waveform.vcd");
        $dumpvars(0, tb_top);

        clk           = 0;
        rst_n         = 0;
        s_axis_tvalid = 0;
        s_axis_tdata  = 72'd0;

        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        $display("=== Starting MAC Verification ===");

        // ----------------------------------------------------------
        // TEST 1: all-ones weights — proves adder tree and FSM flow
        // weights[i=0..8] = 1, pixels[i=0..8] = {10,20,30,40,50,60,70,80,90}
        // Bus packing: element[0] → bits[7:0], element[8] → bits[71:64]
        // ----------------------------------------------------------
        $display("--- Test 1: All-ones weights (adder tree check) ---");
        run_test(
            "ALL_ONES",
            {8'd1,  8'd1,  8'd1,  8'd1,  8'd1,  8'd1,  8'd1,  8'd1,  8'd1},
            {8'd90, 8'd80, 8'd70, 8'd60, 8'd50, 8'd40, 8'd30, 8'd20, 8'd10},
            EXP_1
        );

        // ----------------------------------------------------------
        // TEST 2: mixed signed weights — proves the INT8 signed
        //         multiplier handles positive and negative weights,
        //         and that negative products are correctly subtracted
        //         in the adder tree.
        //
        // weights: [0]=2, [1]=-3, [2]=4, [3]=-1, [4]=5,
        //          [5]=-2, [6]=3, [7]=-4, [8]=1
        // pixels:  [0]=10,[1]=20,[2]=30,[3]=40,[4]=50,
        //          [5]=60,[6]=70,[7]=80,[8]=90
        //
        // Bus order: element[8] in bits[71:64] ... element[0] in bits[7:0]
        // weights packed: {1, -4, 3, -2, 5, -1, 4, -3, 2}
        //               = {8'd1, 8'hFC, 8'd3, 8'hFE, 8'd5,
        //                  8'hFF, 8'd4, 8'hFD, 8'd2}
        // ----------------------------------------------------------
        $display("--- Test 2: Mixed signed weights (multiplier check) ---");
        run_test(
            "SIGNED_MIX",
            {8'd1,  8'hFC, 8'd3,  8'hFE, 8'd5,  8'hFF, 8'd4,  8'hFD, 8'd2},
            {8'd90, 8'd80, 8'd70, 8'd60, 8'd50, 8'd40, 8'd30, 8'd20, 8'd10},
            EXP_2
        );

        $display("=== ALL TESTS PASSED ===");
        repeat (4) @(posedge clk);
        $finish;
    end
endmodule
