`timescale 1ns/1ns

module decoder_tb();

    // DUT signals 
	logic [3:0] s;
	logic [6:0] seg;

    // instantiate the device under test
    top dut (
        .s(s),
        .seg(seg)
    );

    // expected 7-segment patterns

    logic [6:0] expected_seg [0:15];
    initial begin
        expected_seg[0]  = ~7'b1111110;
        expected_seg[1]  = ~7'b0110000;
        expected_seg[2]  = ~7'b1101101;
        expected_seg[3]  = ~7'b1111001;
        expected_seg[4]  = ~7'b0110011;
        expected_seg[5]  = ~7'b1011011;
        expected_seg[6]  = ~7'b1011111;
        expected_seg[7]  = ~7'b1110000;
        expected_seg[8]  = ~7'b1111111;
        expected_seg[9]  = ~7'b1111011;
        expected_seg[10] = ~7'b1110111;
        expected_seg[11] = ~7'b0011111;
        expected_seg[12] = ~7'b1001110;
        expected_seg[13] = ~7'b0111101;
        expected_seg[14] = ~7'b1001111;
        expected_seg[15] = ~7'b1000111;
    end
	
	// apply stimuli and check outputs
    initial begin
        for (int i = 0; i < 16; i = i + 1) begin
            s = i[3:0];
            #10; // wait for combinational logic to settle

            // check seg matches the decoder table
            assert (seg == expected_seg[i])
                $display("PASSED! seg correct for s=%b at time %0t.", s, $time);
            else
                $error("FAILED! seg incorrect for s=%b at time %0t. seg=%b expected=%b",
                        s, $time, seg, expected_seg[i]);
        end

        #20 $stop;
    end

endmodule
