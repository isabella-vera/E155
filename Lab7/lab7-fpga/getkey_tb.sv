`timescale 1ns/1ps
module getkey_tb();
  logic [127:0] prev_key;
  logic [7:0]   rcon;
  logic [127:0] new_key;
  integer tests, errors;

  // dut instance here
  getkey dut(.prev_key(prev_key), .rcon(rcon), .new_key(new_key));

  task check(input string        name, 
             input logic [127:0] expected);

      logic wrong;  
      tests = tests + 1;
      wrong = (new_key != expected);

      if(!(wrong)) begin
        $display("PASS %s", name);
      end else begin
        $error("%s", name);
        $display("got %h", new_key);
        $display("exp %h", expected);
        errors = errors + 1;
      end
  endtask

  initial begin
    #1;
    prev_key = 128'ha0fafe1788542cb123a339392a6c7605;
    rcon     = 8'h02;
    #1
    check("round 2", 128'hf2c295f27a96b9435935807a7359f67f);
  end

  initial begin
    #100;
    $finish;
  end
endmodule
