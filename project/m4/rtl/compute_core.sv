`timescale 1ns/1ps
module compute_core #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  valid_in,
    input  logic [71:0]           payload_in,   // 9 elements * 8 bits
    output logic                  valid_out,
    output logic [ACC_WIDTH-1:0]  mac_out
);
    // --------------------------------------------------------------------------
    // FSM
    // --------------------------------------------------------------------------
    typedef enum logic {LOAD_WEIGHTS, COMPUTE} state_t;
    state_t state;

    // --------------------------------------------------------------------------
    // Weight store + payload unpack (combinational view of the input bus)
    // --------------------------------------------------------------------------
    logic signed [DATA_WIDTH-1:0] weight_cache  [0:8];
    logic signed [DATA_WIDTH-1:0] incoming_data [0:8];

    always_comb begin
        for (int i = 0; i < 9; i++)
            incoming_data[i] = payload_in[(i*DATA_WIDTH) +: DATA_WIDTH];
    end

    // ==========================================================================
    // STAGE 1: register the multiply OPERANDS (data + the matching weight).
    // This isolates the chip-boundary / unpack logic from the multiplier,
    // shortening the path that feeds the multiply.
    // ==========================================================================
    logic signed [DATA_WIDTH-1:0] data_reg   [0:8];
    logic signed [DATA_WIDTH-1:0] weight_reg [0:8];
    logic                         s1_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_valid <= 1'b0;
            for (int i = 0; i < 9; i++) begin
                data_reg[i]   <= '0;
                weight_reg[i] <= '0;
            end
        end else begin
            s1_valid <= (state == COMPUTE) && valid_in;
            for (int i = 0; i < 9; i++) begin
                data_reg[i]   <= incoming_data[i];
                weight_reg[i] <= weight_cache[i];
            end
        end
    end

    // ==========================================================================
    // STAGE 2: 9 parallel multipliers, REGISTERED.
    // Path here is ONLY the multiply (operands already registered upstream).
    // ==========================================================================
    logic signed [ACC_WIDTH-1:0] mult_reg [0:8];
    logic                        s2_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_valid <= 1'b0;
            for (int i = 0; i < 9; i++) mult_reg[i] <= '0;
        end else begin
            s2_valid <= s1_valid;
            for (int i = 0; i < 9; i++)
                mult_reg[i] <= $signed(data_reg[i]) * $signed(weight_reg[i]);
        end
    end

    // ==========================================================================
    // STAGE 3: balanced adder tree (combinational) -> output register.
    // Path here is ONLY the adder tree.
    // ==========================================================================
    logic signed [ACC_WIDTH-1:0] sum_final;

    always_comb begin
        sum_final = ((mult_reg[0] + mult_reg[1]) + (mult_reg[2] + mult_reg[3]))
                  + ((mult_reg[4] + mult_reg[5]) + (mult_reg[6] + mult_reg[7]))
                  +   mult_reg[8];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            mac_out   <= '0;
        end else begin
            valid_out <= s2_valid;
            if (s2_valid)
                mac_out <= sum_final;
        end
    end

    // --------------------------------------------------------------------------
    // FSM control + weight loading
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= LOAD_WEIGHTS;
            for (int i = 0; i < 9; i++) weight_cache[i] <= '0;
        end else begin
            case (state)
                LOAD_WEIGHTS: begin
                    if (valid_in) begin
                        for (int i = 0; i < 9; i++)
                            weight_cache[i] <= incoming_data[i];
                        state <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    // weights stay resident; nothing to do here for control
                end
            endcase
        end
    end
endmodule
