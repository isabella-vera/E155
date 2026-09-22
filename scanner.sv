// Isabella Vera
// ivera@g.hmc.edu
// Created 9/11/2026
// Scanner module for E155 Lab 2

module scanner #( parameter int width = 23,
				  parameter int max = 6000000 )
 
				( input logic clk,
				  input logic reset,
				  input logic enable,
					 
				  output logic [3:0] rows );
					 
				  logic [width-1:0] count;
				  counter #(width, max) rowSelect(clk, reset, enable, count);
					 
				  always_comb begin
					 if (count < max/4) begin
						rows = 4'b1000;
					 end else if (count < max/2) begin
						rows = 4'b0100;
					 end else if (count < 3*max/4) begin
						rows = 4'b0010;
					 end else begin
						rows = 4'b0001;
					 end
				  end
 
endmodule



