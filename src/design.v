`ifndef MATH_EXPRESSION
	`define MATH_EXPRESSION
	module math_expression #(
		parameter W=32
	)(
		output reg signed [(2*W)+3:0] q, // quotient 
		output reg valid, // done tick, availiable for one cycle
				   rmd, // remainder 
		input signed [W-1:0] a, b, c, d,
		input clk, reset, start
	);	
		reg signed [W-1:0] _a, _b, _c, _d; // internal input registers
		

		// pipelining registers
		reg signed [(W+2)-1:0]	cx3_plus_1;		// 3*c + 1
		reg signed [(W+1)-1:0]	a_minus_b;		// a - b		 
		reg signed [(W+2)-1:0]	dx4,			// 4*d	
								temp; 
		reg signed [((2*W)+3)-1:0]	product;		// (3*c + 1) * (a - b)

		reg valid_in, valid_stage_1, valid_stage_2;

		wire signed [(2*W)+3:0] numerator = product - temp;

		always @(posedge clk) begin //sync reset
			if (reset) begin
				valid <= 0;
				valid_in <= 0;
				valid_stage_1 <= 0;
				valid_stage_2 <= 0;

				cx3_plus_1 <= 0;
				a_minus_b <= 0;
				dx4 <= 0;
				temp <= 0;
				product <= 0;
				q <= 0;

				rmd <= 0;
				_a <= 0;
				_b <= 0;
				_c <= 0;
				_d <= 0;
			end

			else begin
				if (start) begin
					_a <= a;
					_b <= b;
					_c <= c;
					_d <= d; // input is sync
					valid_in <= 1;
				end

				else begin
					_a <= 0;
					_b <= 0;
					_c <= 0;
					_d <= 0;
					valid_in <= 0;
				end

				// pipelining block 
				//
				// stage 1
				//
				cx3_plus_1 <= (_c * 3) + 1;
				a_minus_b <= _a - _b;
				dx4 <= _d << 2;
				valid_stage_1 <= valid_in;

				//stage 2
				//
				product <= cx3_plus_1 * a_minus_b;
				temp <= dx4;
				valid_stage_2 <= valid_stage_1;

				// stage 3 final
				//
				q <= numerator >>> 1;
				rmd <= numerator[0];
				valid <= valid_stage_2;
			end
		end		
	endmodule
`endif
