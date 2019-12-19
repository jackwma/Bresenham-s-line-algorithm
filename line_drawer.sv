
module line_drawer(
	input logic clk, reset,
	input logic [10:0]	x0, y0, x1, y1, //the end points of the line
	output logic [10:0]	x, y, //outputs corresponding to the pair (x, y)
	output logic complete
	);
	
	logic signed [11:0] sum, dx, dy, errorTemp;
	logic right, down;
	
	enum {idle, plot, done} ps, ns;
	
	//switching between modes of graphing
	always_comb begin
		case (ps)
			idle: 	ns = plot;
			plot: if ((x == x1) && (y == y1))
						ns = done;
					else
						ns = plot;
			done: ns = idle;
		endcase
	end
	
	// State behavior
	always_ff @(posedge clk) begin
		case (ps)
			idle:	begin						
						dx = x1 - x0; // x direction
						right = dx >= 0;
						if (~right) // left
							dx = -dx; // switch direction
							
						dy = y1 - y0; // y direction
						down = dy >= 0;
						if (down) // down
							dy = -dy; //switch direction
						
						sum = dx + dy;
						x <= x0;
						y <= y0;
						complete <= 0;
					end
			plot:	begin
						errorTemp = sum << 1;

						// check for change in x
						if ((errorTemp > dy)) begin
							sum += dy;
							if (right) // right
								x <= x + 1;
							else // left
								x <= x - 1;
						end
						
						// check for change in y
						if ((errorTemp < dx)) begin
							sum += dx;
							if (down) // down
								y <= y + 1;
							else // up
								y <= y - 1;
						end
					end
			done: begin
						complete <= 1;
						x <= x1;
						y <= y1;
					end
		endcase
	end
	
	// DFF
	always_ff @(posedge clk) begin
		if (reset)
			ps <= idle;
		else
			ps <= ns;
	end
endmodule

module line_drawer_tb();
	logic [10:0] x0, y0, x1, y1, x, y;
	logic clk, reset, complete;
	
	line_drawer dut(clk, reset, x0, y0, x1, y1, x, y, complete);
	
	// Set up the clock.
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i = 0;
	initial begin
		reset <= 1; x0 <= 40; y0 <= 200; x1 <= 160; y1 <= 0; @(posedge clk);
		reset <= 0; @(posedge clk);
		for(i = 0; i < 500; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule
