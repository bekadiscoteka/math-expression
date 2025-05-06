`ifndef bin2bcd
`define bin2bcd
module bin2bcd
	#(
		parameter WIDTH=20
	)
	(
    output ready, done_tick,
    output reg [3:0] bcd5, bcd4, bcd3, bcd2, bcd1, bcd0,
    input clk, reset, start,
    input [WIDTH-1:0] bin
);
	localparam READY = 0, PROC = 1, FINISH = 2, LAST=3;
   	// abcd 
    reg [1:0] state;
    reg [WIDTH-1:0] bin_reg;
    reg [log(WIDTH+1)-1:0] counter;
	
	reg [3:0] _bcd5, _bcd4, _bcd3, _bcd2, _bcd1, _bcd0;
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			state <= 0;
			bin_reg <= bin;
			counter <= 0;
			bcd5 <= 0;
			bcd4 <= 0;
			bcd3 <= 0;
			bcd2 <= 0;
			bcd1 <= 0;
			bcd0 <= 0;
				
		end
		else begin
			case (state) 
				READY: begin
					state <= start ? PROC : 0;
					bin_reg <= bin;
					counter <= 0;
					bcd5 <= 0;
					bcd4 <= 0;
					bcd3 <= 0;
					bcd2 <= 0;
					bcd1 <= 0;
					bcd0 <= 0;
				end
				PROC: begin				
					proc_and_shift();
					if (counter == WIDTH-2) state <= LAST;
					counter <= counter + 1;
				end
				LAST: begin
					proc_and_shift();
					state <= FINISH;
				end
				FINISH: begin
					state <= READY;	
				end
			endcase	
		end
	end
   	
   		
    assign ready = (state == READY);
    assign done_tick = (state == FINISH);

	task automatic proc_and_shift;
		begin
		{
			bcd5,
			bcd4, 
			bcd3,
			bcd2,
			bcd1,
			bcd0,
			bin_reg
		} <= ({
			(bcd5 >= 4'd5) ? bcd5 + 4'd3 : bcd5,
    		(bcd4 >= 4'd5) ? bcd4 + 4'd3 : bcd4,
    		(bcd3 >= 4'd5) ? bcd3 + 4'd3 : bcd3,
			(bcd2 >= 4'd5) ? bcd2 + 4'd3 : bcd2,
			(bcd1 >= 4'd5) ? bcd1 + 4'd3 : bcd1,
			(bcd0 >= 4'd5) ? bcd0 + 4'd3 : bcd0,
			bin_reg
	   	}) << 1;
		end
	endtask

	task automatic shift;
		begin
		{
			_bcd5,
			_bcd4, 
			_bcd3,
			_bcd2,
			_bcd1,
			_bcd0,
			bin_reg
		} <= ({
			_bcd5,
    		_bcd4,
    		_bcd3,
			_bcd2,
			_bcd1,
			_bcd0,
			bin_reg
	   	}) << 1;
		end
	endtask

		function integer log;
			input [31:0] N;
			integer i;
			begin
				for (i=31; !N[31]; i = i-1) 
					N = N << 1;	
				log = i;	
			end	
		endfunction

endmodule
`endif
