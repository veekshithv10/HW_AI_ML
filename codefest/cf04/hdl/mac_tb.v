module mac_tb;

    logic clk;
    logic rst;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [31:0] out;

    // Instantiate your perfect MAC module
    mac dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .out(out)
    );

    // Generate a 10ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Run the test
    initial begin
        // 1. Initial Reset
        rst = 1; a = 0; b = 0;
        @(posedge clk);
        rst = 0;
        
        $display("--- STARTING TEST ---");

        // 2. Apply [a=3, b=4] for 3 cycles
        a = 3; b = 4;
        repeat(3) begin
            @(posedge clk);
            #1; // Wait 1 timestep for the output flip-flop to update
            $display("Phase 1: a=%0d, b=%0d | out=%0d", a, b, out);
        end

        // 3. Assert rst (Reset the accumulator)
        rst = 1;
        @(posedge clk);
        #1;
        $display("--- RESET APPLIED --- | out=%0d", out);
        rst = 0;

        // 4. Apply [a=-5, b=2] for 2 cycles
        a = -5; b = 2;
        repeat(2) begin
            @(posedge clk);
            #1;
            $display("Phase 2: a=%0d, b=%0d | out=%0d", a, b, out);
        end

        $display("--- TEST COMPLETE ---");
        $finish; // End the simulation
    end

endmodule