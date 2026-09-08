// Isabella Vera
// ivera@g.hmc.edu
// Created 9/7/2026
// This module is a counter used to blink an LED at a desired frequency

module blinkCounter (input logic clk,
					 input logic reset,
					 input logic enable,
					 
					 output logic led2);
					 
					 logic [31:0] counter;
					 
					 parameter DIV = 10000000; // clk frequency(48MHz) / desired frequency(2.4Hz) / 2
					 

					 always_ff @(posedge clk) begin
						if (reset) begin
							counter <= 32'd0;
							led2 <= 1'b0;
						end
						else if (enable) begin
							if (counter == DIV - 1) begin
								counter <= 32'd0;
								led2 <= ~led2;  // toggle LED
							end
							else begin
								counter <= counter + 1;
							end
						end
						
					end
				 
endmodule
