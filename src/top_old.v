`include "old.v"
module top(
	output valid, 
	output [31:0] q,
	output rmd, 
	input clk, reset, start,
	input [31:0] a, b, c, d
);
	
	math_expression #(.W(4)) me(
		.clk(clk),
		.reset(reset),
		.start(start),
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.valid(valid),
		.rmd(rmd),
		.q(q)
	);
	
endmodule
