module scanner(input logic clk,
							 input logic reset,
							 input logic enable,

							 output logic [3:0] rows);

    logic [22:0] count;

    counter #(23, 6000000) rowSelect(clk, reset, enable, count);

    always_comb begin
        if (count < 6000000/4) begin
            rows = 4'b1000;
        end
        else if (count < 6000000/2) begin
            rows = 4'b0100;
        end
        else if (count < 3*6000000/4) begin
            rows = 4'b0010;
        end
        else begin
            rows = 4'b0001;
        end
		else begin
			rows = 4'b0000;
		end
    end

endmodule
