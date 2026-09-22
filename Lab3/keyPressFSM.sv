// Isabella Vera
// ivera@g.hmc.edu
// Created 9/20/2026
// Key-press FSM for E155 Lab 3
// Validates a single key press per hold: ignores additional keys pressed while one is already held, 
// and registers the surviving key when a multi-key hold is released down to exactly one.

module keyPressFSM ( input  logic       clk,
                     input  logic       reset,
                     input  logic [3:0] cols,        // debounced cols for the currently-scanned row

                     output logic       press_valid, // 1-cycle pulse: new key validated
                     output logic       scan_freeze  // hold scanner on this row while any key is down
                    );

                    typedef enum logic [1:0] {IDLE, MULTI, HELD} state_t;
                    state_t state, next_state;

                    logic zero_keys, one_key, multi_keys;
                    assign zero_keys  = (cols == 4'b0000);
                    assign one_key    = (cols != 4'b0000) && ((cols & (cols - 1)) == 4'b0000); // power of 2 check
                    assign multi_keys = (cols != 4'b0000) && ((cols & (cols - 1)) != 4'b0000);

                    // next-state logic
                    always_comb begin
                        next_state = state;
                        case (state)
                            IDLE:    if (multi_keys)      next_state = MULTI;
                                     else if (one_key)    next_state = HELD;
                            MULTI:   if (one_key)         next_state = HELD;
                                     else if (zero_keys)  next_state = IDLE;
                            HELD:    if (zero_keys)       next_state = IDLE;
									 else if (multi_keys)	  next_state = MULTI;
                            default: next_state = IDLE;
                        endcase
                    end

                    // state register
                    always_ff @(posedge clk) begin
                        if (reset) state <= IDLE;
                        else       state <= next_state;
                    end

                    // outputs: press_valid pulses for a single-key condition 
                    assign press_valid = ((state == IDLE) || (state == MULTI)) && one_key;
                    assign scan_freeze = !zero_keys;

endmodule