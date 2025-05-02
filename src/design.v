`ifndef MATH_EXPRESSION
	`define MATH_EXPRESSION
	module math_expression #(
		parameter W=16 
	)(
		output reg signed [W-1:0] q, // quotient 
		output reg valid, // done tick, availiable for one cycle
				   rmd, // remainder 
		input signed [W-1:0] a, b, c, d,
		input clk, reset, start
	);	
		localparam	IDLE=0,
					PROC=1;

		reg [1:0] state;
		reg signed [W-1:0] _a, _b, _c, _d;	// internal registers

		// math expression implementation
		wire signed [W-1:0] numerator = (((_a - _b) * (1 + (3 * _c))) - (4 * _d));
		wire signed [W-1:0] _q = numerator >>> 1;
		wire _rmd = numerator[0];

		always @(posedge clk) begin //sync reset
			if (reset) begin
				valid <= 0;
				state <= IDLE;
				q <= 0;
				_a <= 0;
				_b <= 0;
				_c <= 0;
				_d <= 0;
			end
			else begin
				if (start) begin
					state <= PROC;
					{_a, _b, _c, _d} <= {a, b, c, d}; // sync value receive
				end
				else state <= IDLE;

				case (state) 
					IDLE: begin
						valid <= 0;
						q <= 0;
						rmd <= 0;
					end
					PROC: begin
						q <= _q;
						rmd <= _rmd;
						valid <= 1;
					end
				endcase	
			end
		end		
	endmodule
`endif
