// Isabella Vera
// ivera@g.hmc.edu
// Created 9/11/2026
// Toggles between 4 states at 2 Hz to scan 

module scanner(input logic clk,
			   input logic reset,
			   input logic enable,
			   
			   output logic [3:0] rows);
			   
			   logic clkEdge;
			   logic [1:0] count;
			   
			   counter #(25, 1200000, 2) rowSelect(clk, reset, enable, count);
			   
			   always_comb begin
				case (count)
					2'b00  : rows = 4'b1000;
					2'b01  : rows = 4'b0100;
					2'b10  : rows = 4'b0010;
					2'b11  : rows = 4'b0001;
					default: rows = 4'b0000;
				endcase
			   end

endmodule
