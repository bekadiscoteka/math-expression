`include "sync_input.v"
`timescale 1ns / 1ns
module clk_gen(output reg clk);
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end
endmodule

`timescale 1ms / 1ms
module generator #(
	parameter W=16
)(
	output reg reset, start,
	output reg signed [W-1:0] a, b, c, d,
	output wire clk
);
	clk_gen clk50MHz(.clk(clk));
	initial begin
		reset=0;
		start =0;
		{a, b, c, d} = 0;
	end

	integer i;	
	initial begin
		do_reset();
		set(-4, 6, -2, 1);
		set(3, 3, -3, 3);	
		set(5, 3, 2, -1);
		#1 $finish;		
	end	

	task do_reset();
		begin
			reset = 1;
			@(posedge clk);
			reset = 0;
			@(posedge clk);
		end	
	endtask

	task set(
		input integer signed _a, _b, _c, _d
	);
		begin
			start=1;
			a = _a;
			b = _b;
			c = _c;
			d = _d;
			@(posedge clk);
			start=0;
		end
	endtask

endmodule

module monitor #(
	parameter W=16
)(
	input valid, start, clk,
	input signed [W-1:0] q, a, b, c, d
);
	reg signed [W-1:0] _a,_b,_c,_d, _q;

	//checking after receive of valid tick,

	always @(valid) begin
		while (valid) begin
			if (q == _q) $display(
				"passed quo: %d, inputs: a=%d b=%d c=%d d=%d", _q, _a, _b, _c, _d
			);
			else $display(
				"failed, quo: %d, required: %d  inputs: a=%d b=%d c=%d d=%d", q, _q, 
				_a, _b, _c, _d
			);	
			@(posedge clk);
		end
	end

	always @(posedge clk) begin
		{_a,_b,_c,_d, _q} <= start ? {a, b, c, d, math_expr(a, b, c, d)} : 0; 		
	end
	

	function signed [W-1:0] math_expr(
		input signed [W-1:0] a, b, c, d
	);
		begin
			math_expr = (((a - b) * (1 + (3 * c))) - (4 * d)) / 2;
		end
	endfunction
endmodule

module stimulus;
	parameter W=512;
	wire [W-1:0] q, a, b, c, d;
	wire start, reset, clk, valid, rmd;

	
	generator #(.W(W)) gen(
		.clk(clk),
		.reset(reset),
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.start(start)
	);

	math_expression #(.W(W)) me(
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

	monitor #(.W(W)) mon(
		.clk(clk),
		.valid(valid),
		.start(start),
		.q(q),
		.a(a),
		.b(b),
		.c(c),
		.d(d)
	);

					
endmodule
