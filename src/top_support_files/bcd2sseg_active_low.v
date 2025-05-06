`ifndef BCD2SSEG_ACTLOW
`define BCD2SSEG_ACTLOW
module bcd2sseg_active_low (
    input  [3:0] bcd5, bcd4, bcd3, bcd2, bcd1, bcd0,
    output [6:0] sseg5, sseg4, sseg3, sseg2, sseg1, sseg0
);

    // Active-low 7-segment decoder
    function [6:0] bcd_to_sseg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'd0: bcd_to_sseg = 7'b1000000; // 0
                4'd1: bcd_to_sseg = 7'b1111001; // 1
                4'd2: bcd_to_sseg = 7'b0100100; // 2
                4'd3: bcd_to_sseg = 7'b0110000; // 3
                4'd4: bcd_to_sseg = 7'b0011001; // 4
                4'd5: bcd_to_sseg = 7'b0010010; // 5
                4'd6: bcd_to_sseg = 7'b0000010; // 6
                4'd7: bcd_to_sseg = 7'b1111000; // 7
                4'd8: bcd_to_sseg = 7'b0000000; // 8
                4'd9: bcd_to_sseg = 7'b0010000; // 9
                default: bcd_to_sseg = 7'b1111111; // blank (all off)
            endcase
        end
    endfunction

    assign sseg0 = bcd_to_sseg(bcd0);
    assign sseg1 = bcd_to_sseg(bcd1);
    assign sseg2 = bcd_to_sseg(bcd2);
    assign sseg3 = bcd_to_sseg(bcd3);
    assign sseg4 = bcd_to_sseg(bcd4);
    assign sseg5 = bcd_to_sseg(bcd5);

endmodule
`endif
