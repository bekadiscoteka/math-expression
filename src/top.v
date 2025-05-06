`include "uart/uart.v"
`include "top_support_files/bcd2sseg_active_low.v"
`include "top_support_files/bin2bcd.v"
`include "design.v"
module top(
	output [7:0]
					sseg3,
					sseg2,
					sseg1,
					sseg0,
	output reg [7:0] sseg5, sseg4,
	output	baund_rate_ready, //indicates baund is detected 
			tx,
	output reg ind,
	input clk, reset, rx
);				
	localparam	SET_A=0,
				SET_B=1,
				SET_C=2,
				SET_D=3;	

	wire	rx_empty, read;

	wire [7:0] ascii;
	assign read = ~rx_empty;

	uart uart_inst(
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.tx(tx),
		.data_in(),
		.data_out(ascii),
		.rx_empty(rx_empty), // rx fifo empty
		.ready(baund_rate_ready),
		.rd_data(read)
	);		
	
	reg [3:0] state;
	reg [3:0] a, b, c, d;
	reg temp, start;

	always @(posedge clk, posedge reset) begin
		if (reset) begin
			start <= 0;
			state <= SET_A;
			temp <= 0;
			a <= 0;
			b <= 0;
			c <= 0;
			d <= 0;
		end
		else if (read) begin
			case (state) 
				SET_A: begin
					start <= 0;
					if (ascii == 45) begin
				   		temp <= 1;
					end
					else begin
						a <= temp ? -(ascii - 48) : ascii - 48;
						temp <= 0;
						state <= SET_B;
					end
				end
				SET_B: begin
					if (ascii == 45) begin
				   		temp <= 1;
					end
					else begin
						b <= temp ? -(ascii - 48) : ascii - 48;
						temp <= 0;
						state <= SET_C;
					end	
				end
				SET_C: begin
					if (ascii == 45) begin
				   		temp <= 1;
					end
					else begin
						c <= temp ? -(ascii - 48) : ascii - 48;
						temp <= 0;
						state <= SET_D;
					end	
				end
				SET_D: begin
					if (ascii == 45) begin
				   		temp <= 1;
					end
					else begin
						d <= temp ? -(ascii - 48) : ascii - 48;
						temp <= 0;
						state <= SET_A;
						start <= 1;
					end	
				end
			endcase
		end
		else start <= 0;
	end
	
	wire valid, rmd;
	wire signed [11:0] q;

	math_expression #(
		.W(4)
	) me(
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.valid(valid),
		.clk(clk),
		.reset(reset),
		.start(start),
		.q(q),
		.rmd(rmd)
	);	

	wire done;
	wire signed [15:0] bin = q[11] ? -q : q;
	wire [3:0] bcd3, bcd2, bcd1, bcd0;
	reg [3:0] bcd5, bcd4;

	bin2bcd #(.WIDTH(16)) conv(
		.clk(clk),
		.reset(reset),
		.bin(bin),
		.bcd3(bcd3),
		.bcd2(bcd2),
		.bcd1(bcd1),
		.bcd0(bcd0),
		.done_tick(done),
		.start(valid)
	);	
	reg [15:0] bcd_set; 
	always @(posedge clk, posedge reset) begin
		if (reset) begin
		   bcd_set <= 0;
			bcd5 <= 0;
			bcd4 <= 0;
			sseg4 <= ~8'b0;
			sseg5 <= ~8'b0;
			ind <= 0;
		end
		else begin
			if (done) begin
				bcd_set <= {bcd3, bcd2, bcd1, bcd0};
			end
			if (start) ind <= 1;
			if (valid) sseg4 <= q[11] ? 8'b10111111 : ~8'b0;
		end
	end

	bcd2sseg_active_low bcd2ssg(
		.bcd5(bcd5),
		.bcd4(bcd4),	
		.bcd3(bcd_set[(4*4)-1:(4*4)-4]),
		.bcd2(bcd_set[(4*3)-1:(4*3)-4]),
		.bcd1(bcd_set[(4*2)-1:(4*2)-4]),
		.bcd0(bcd_set[(4*1)-1:(4*1)-4]),
		.sseg3(sseg3[6:0]),
		.sseg2(sseg2[6:0]),
		.sseg1(sseg1[6:0]),
		.sseg0(sseg0[6:0])
	);	

	assign {sseg3[7], sseg2[7], sseg1[7], sseg0[7]} = ~4'b0;
	
endmodule
