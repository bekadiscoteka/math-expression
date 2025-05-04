`ifndef MATH_EXPRESSION
	`define MATH_EXPRESSION
	module math_expression #(
		parameter W=32
	)(
		output signed [W-1:0] q, // quotient 
		output reg	valid, // done tick, availiable for one cycle
		output rmd, // remainder 
		input signed [W-1:0] a, b, c, d,
		input clk, reset, start
	);	
		localparam	IDLE=0,
					PROC=1;

		reg signed [W-1:0] _a, _b, _c, _d;	// internal registers

		// math expression implementation
		wire signed [W-1:0] numerator = (((_a - _b) * (1 + (3 * _c))) - (4 * _d));
		assign q = numerator >>> 1;
		assign rmd = numerator[0];

		always @(posedge clk) begin //sync reset
			if (reset) begin
				valid <= 0;
				_a <= 0;
				_b <= 0;
				_c <= 0;
				_d <= 0;
			end
			else begin
				if (start) begin
					{_a, _b, _c, _d} <= {a, b, c, d}; // sync value receive
					valid <= 1;
				end
				else begin
				   	valid <= 0; // result is valid only for one cycle
					{_a, _b, _c, _d} <= 0; // after that it is reset
				end
			end
		end		
	endmodule
`endif
