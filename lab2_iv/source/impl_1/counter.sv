// Isabella Vera
// ivera@g.hmc.edu
// Created 9/7/2026
// This module was created for lab 1 to blink an LED at 2.4 Hz
// Last updated 9/11/2026
// This module was modified for lab 2 to include cleaner verilog and be more compatible for various counter uses

module counter #(parameter int width = 2,
				 parameter int max = 1)
	
			    (input logic clk,
				 input logic reset,
				 input logic enable,
				 
				 output logic out);
				 
				 logic [width-1:0] count;
				 

				 always_ff @(posedge clk) begin
					if (reset) begin
						count <= '0;
					end	
					
					else if (enable) begin
						if (count == max - 1) begin
							out = ~out;
							count <= '0;
						end else begin
							count <= count + 1'b1;
						end
					end 
					
					else begin
						count <= count;
					end
					
				end
				 
endmodule