/////////////////////////////////////////////
// Isabella Vera
// ivera@g.hmc.edu
// 10/24/2026
//
// controlFSM()
// controller finite state machine that takes the round counter as an input
// outputs done signal after round 10
// outputs roundchange signal each time the round counter increments for rounds 0-10
// outputs 2-bit select signal for the addRoundKey input MUX
/////////////////////////////////////////////



module controlFSM(  input  logic       clk,
                    input  logic       reset,
                    input  logic [3:0] roundcount,
                    output logic       done,
                    output logic       roundchange,
                    output logic [1:0] select
                  );

    typedef enum logic [1:0] {ROUND0, MIDDLE, FINAL, DONE} state_t;
    state_t state, nextstate;

    // state register
    always_ff @(posedge clk)
      if(reset) state <= ROUND0;
      else state <= nextstate;

    // nextstate logic
    always_comb 
      case (state)
        ROUND0: nextstate = MIDDLE;
        MIDDLE: nextstate = (roundcount == 'd9) ? FINAL : MIDDLE;
        FINAL:  nextstate = DONE;
        DONE:   nextstate = DONE;     // holds here until reset
        default: nextstate = ROUND0;  // just in case default case
      endcase 


    // output logic
    always_comb begin
      select      = 2'b00;
      done        = 1'b0;
      roundchange = 1'b0; 

      case(state)
        ROUND0: begin 
                  select = 2'b01;
                  done = 1'b0;
                  roundchange = 1'b1;
                end
        MIDDLE: begin 
                  select = 2'b00;
                  done = 1'b0;
                  roundchange = 1'b1;
                end
        FINAL:  begin 
                  select = 2'b10;
                  done = 1'b0;
                  roundchange = 1'b1;
                end
        DONE:   begin 
                  select = 2'b00;
                  done = 1'b1;
                  roundchange = 1'b0;
                end
      endcase
    end


endmodule
