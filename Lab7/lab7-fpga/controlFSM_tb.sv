`timescale 1ns/1ps
module controlFSM_tb();
  logic clk, reset;
  logic [3:0] roundcount;
  logic done, roundchange;
  logic [1:0] select;
  integer tests, errors;

  // dut instance here
  controlFSM dut(.clk(clk), .reset(reset), .roundcount(roundcount), .done(done), .roundchange(roundchange), .select(select));

  always begin
    clk = 1; #1;
    clk = 0; #1;
  end

  // model the roundcounter
  always_ff @(posedge clk)
    if(reset) roundcount <= 4'd0;
    else if(roundchange) roundcount <= (roundcount == 4'd10) ? 4'd0 : roundcount + 4'd1;


  // apply one test vector and compare against the expected output
  task check(input string      name, 
             input logic [3:0] exp_round, 
             input logic [1:0] exp_select,
             input logic       exp_roundchange,
             input logic       exp_done);

      logic wrong_round, wrong_select, wrong_roundchange, wrong_done;  
      tests = tests + 1;
      wrong_round = (roundcount != exp_round);
      wrong_select = (select != exp_select);
      wrong_roundchange = (roundchange != exp_roundchange);
      wrong_done = (done != exp_done);

      if(!(wrong_round | wrong_select | wrong_roundchange | wrong_done)) begin
        $display("PASS %s", name);
      end else begin
        $error("%s", name);
        $display("    roundcount select roundchange done");
        $display("got %0d          %b     %b           %b", roundcount, select, roundchange, done);
        $display("exp %0d          %b     %b           %b", exp_round, exp_select, exp_roundchange, exp_done);
        errors = errors + 1;
      end
  endtask

  integer i;

  initial begin
    tests = 0; 
    errors = 0;

    /////////////// TEST 1 ///////////////
    // check transition from RESET signal to ROUND0
    reset = 1'b1;
    #10;
    check("rst to round0", 3'b0, 2'b01, 1'b1, 1'b0);
    #1;
    reset = 1'b0;

    /////////////// TEST 2 ///////////////
    // check rounds 1-9 (MIDDLE)
    for (i = 1; i <= 9; i = i + 1) begin
      #2;
      check($sformatf("round %0d (middle)", i), i[3:0], 2'b00, 1'b1, 1'b0);
    end

    /////////////// TEST 3 ///////////////
    // check round 10 (FINAL)
    #2;
    check("round 10 (FINAL)", 4'd10, 2'b10, 1'b1, 1'b0);

    /////////////// TEST 4 ///////////////
    // check the final done and roundchange
    #2; 
    check("done", 4'd0, 2'b00, 1'b0, 1'b1);

    /////////////// TEST 5 ///////////////
    // check that the done signal holds 
    #1; 
    check("done holds 1", 4'd0, 2'b00, 1'b0, 1'b1);
    #1; 
    check("done holds 2", 4'd0, 2'b00, 1'b0, 1'b1);
    #1; 
    check("done holds 3", 4'd0, 2'b00, 1'b0, 1'b1);
    #1; 
    check("done holds 4", 4'd0, 2'b00, 1'b0, 1'b1);
    #1; 
    check("done holds 5", 4'd0, 2'b00, 1'b0, 1'b1);
    $finish;

  end

  initial begin
    #10000;
    $error("tb timeout");
    $finish;
  end
endmodule
