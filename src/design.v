`ifndef MATH_EXPRESSION
	`define MATH_EXPRESSION
	module math_expression #(
		parameter W=16 
	)(
		output reg signed [W-1:0] q, // quotient 
		output reg valid, // done tick, availiable for only one cycle
				   rmd, // remainder 
		input signed [W-1:0] a, b, c, d,
		input clk, reset, start
	);	
		localparam	IDLE=0,
					PROC=1;

		reg state;
		reg signed [W-1:0] _a, _b;	// internal registers
		reg signed [(W-1)+2:0] _c, _d;

		// MATH EXPRESSION IMPLEMENTATION BLOCK STARTS

		wire signed [(W-1)+2:0] _dx4_opt = _d << 2; // _d * 4 optimized
		wire signed [(W-1)+2:0] _cx3_opt = (_c << 1) + _c; // _c * 3 optimized
		wire signed [(W-1)+2:0] inc_opt;  //output of increment optimized

		//incrementation optimized version in binary level
		genvar i;
		generate 
			for (i=0; i<=(W-1)+2; i=i+1) begin
				if (i==0) begin
				   	assign inc_opt[i] = ~_cx3_opt[i];
				end
				else begin
					assign inc_opt[i] = _cx3_opt[i] ^ &_cx3_opt[i-1:0];  
				end
			end
		endgenerate


		wire signed [W-1:0] numerator = (((_a - _b) * inc_opt) - _dx4_opt);
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
					_a <= a;
					_b <= b;
					_c <= c;
					_d <= d;
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
