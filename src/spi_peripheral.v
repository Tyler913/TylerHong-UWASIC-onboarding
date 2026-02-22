`timescale 1ps/1ps

module spi_peripheral # (
    parameter [6:0] MAX_ADDRESS = 7'h04
)
(
    input  wire      clk,
    input  wire      rst_n,

    input  wire      ncs,
    input  wire      sclk,
    input  wire      copi,

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);


    reg ncs_reg_1;
    reg sclk_reg_1;
    reg copi_reg_1;

    reg ncs_reg_2;
    reg sclk_reg_2;
    reg copi_reg_2;

    reg ncs_sync;
    reg sclk_sync;
    reg copi_sync;

    reg ncs_sync_d;
    reg sclk_sync_d;

    wire sclk_rising_edge = (sclk_sync == 1'b1) && (sclk_sync_d == 1'b0);
    wire ncs_falling_edge = (ncs_sync  == 1'b0) && (ncs_sync_d  == 1'b1);
    wire ncs_rising_edge  = (ncs_sync  == 1'b1) && (ncs_sync_d  == 1'b0);


    reg [4:0]  bit_count;
    reg [15:0] shift_reg;
    reg        start_transaction;


    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            bit_count         <= 5'd0;
            shift_reg         <= 16'd0;
            start_transaction <= 1'b0;
            en_reg_out_7_0    <= 8'd0;
            en_reg_out_15_8   <= 8'd0;
            en_reg_pwm_7_0    <= 8'd0;
            en_reg_pwm_15_8   <= 8'd0;
            pwm_duty_cycle    <= 8'd0;
        end
        else begin
            if (ncs_falling_edge == 1'b1) begin
                bit_count         <= 5'd0;
                shift_reg         <= 16'd0;
                start_transaction <= 1'b1;
            end

            if (sclk_rising_edge == 1'b1 && start_transaction == 1'b1 && ncs_sync == 1'b0 && bit_count < 5'd16) begin
                shift_reg <= {shift_reg[14:0], copi_sync};
                bit_count <= bit_count + 5'd1;
            end

            if (ncs_rising_edge == 1'b1) begin
                start_transaction <= 1'b0;

                if (bit_count == 5'd16 && shift_reg[15] == 1'b1 && shift_reg[14:8] <= MAX_ADDRESS) begin
                    case (shift_reg[14:8])
                        7'h00: en_reg_out_7_0  <= shift_reg[7:0];
                        7'h01: en_reg_out_15_8 <= shift_reg[7:0];
                        7'h02: en_reg_pwm_7_0  <= shift_reg[7:0];
                        7'h03: en_reg_pwm_15_8 <= shift_reg[7:0];
                        7'h04: pwm_duty_cycle  <= shift_reg[7:0];
                        default: ;
                    endcase
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            ncs_reg_1   <= 1'd1;
            ncs_reg_2   <= 1'd1;
            sclk_reg_1  <= 1'd0;
            sclk_reg_2  <= 1'd0;
            copi_reg_1  <= 1'd0;
            copi_reg_2  <= 1'd0;
            ncs_sync    <= 1'd1;
            sclk_sync   <= 1'd0;
            copi_sync   <= 1'd0;
            ncs_sync_d  <= 1'd1;
            sclk_sync_d <= 1'd0;
        end
        else begin
            ncs_reg_1   <= ncs;
            ncs_reg_2   <= ncs_reg_1;
            ncs_sync    <= ncs_reg_2;
 
            sclk_reg_1  <= sclk;
            sclk_reg_2  <= sclk_reg_1;
            sclk_sync   <= sclk_reg_2;
 
            copi_reg_1  <= copi;
            copi_reg_2  <= copi_reg_1;
            copi_sync   <= copi_reg_2;

            ncs_sync_d  <= ncs_sync;
            sclk_sync_d <= sclk_sync;
        end
    end

endmodule
