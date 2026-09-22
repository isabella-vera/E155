module debounce ( input  logic clk,
                  input  logic rst,
                  input  logic [3:0] in,
                  output logic [3:0] debounced_out );

                  parameter int DEBOUNCE_CYCLES = 200000;
                  // synchronize (avoids metastability)
                  logic [3:0] sync0, sync1;
                  always_ff @(posedge clk) begin
                      if (rst) begin
                          sync0 <= '0;
                          sync1 <= '0;
                      end else begin
                          sync0 <= in;
                          sync1 <= sync0;
                      end
                  end

                  // counters that must saturate before output updates
                  logic [$clog2(DEBOUNCE_CYCLES)-1:0] count [4];
                  logic [3:0] clean_reg;

                  always_ff @(posedge clk) begin
                      if (rst) begin
                          count[0]     <= '0;
                          clean_reg[0] <= 1'b0;
                      end else if (sync1[0] != clean_reg[0]) begin
                          // input differs from accepted value -> count how long it's stayed different
                          if (count[0] == DEBOUNCE_CYCLES-1) begin
                              clean_reg[0] <= sync1[0];   // accept new stable value
                              count[0]     <= '0;
                          end else begin
                              count[0] <= count[0] + 1'b1;
                          end
                      end else begin
                          count[0] <= '0;  // matches current output, reset counter
                      end
                  end

                  always_ff @(posedge clk) begin
                      if (rst) begin
                          count[1]     <= '0;
                          clean_reg[1] <= 1'b0;
                      end else if (sync1[1] != clean_reg[1]) begin
                          // input differs from accepted value -> count how long it's stayed different
                          if (count[1] == DEBOUNCE_CYCLES-1) begin
                              clean_reg[1] <= sync1[1];   // accept new stable value
                              count[1]     <= '0;
                          end else begin
                              count[1] <= count[1] + 1'b1;
                          end
                      end else begin
                          count[1] <= '0;  // matches current output, reset counter
                      end
                  end

                  always_ff @(posedge clk) begin
                      if (rst) begin
                          count[2] <= '0;
                          clean_reg[2] <= 1'b0;
                      end else if (sync1[2] != clean_reg[2]) begin
                          // input differs from accepted value -> count how long it's stayed different
                          if (count[2] == DEBOUNCE_CYCLES-1) begin
                              clean_reg[2] <= sync1[2];   // accept new stable value
                              count[2] <= '0;
                          end else begin
                              count[2] <= count[2] + 1'b1;
                          end
                      end else begin
                          count[2] <= '0;  // matches current output, reset counter
                      end
                  end

                  always_ff @(posedge clk) begin
                      if (rst) begin
                          count[3] <= '0;
                          clean_reg[3] <= 1'b0;
                      end else if (sync1[3] != clean_reg[3]) begin
                          // input differs from accepted value -> count how long it's stayed different
                          if (count[3] == DEBOUNCE_CYCLES-1) begin
                              clean_reg[3] <= sync1[3];   // accept new stable value
                              count[3] <= '0;
                          end else begin
                              count[3] <= count[3] + 1'b1;
                          end
                      end else begin
                          count[3] <= '0;  // matches current output, reset counter
                      end
                  end

                  assign debounced_out = clean_reg;

endmodule
