
`default_nettype none

module top
  (
   input  wire CLK100,
   input  wire RESET,
   input  wire RXD,
   output wire TXD,
   output wire [3:0] LED
   );

    wire sysclk;
    wire sysrst;

    wire locked;
    clk_wiz_0 clk_wiz_0_i(.clk_out1(sysclk),
			  .reset(RESET),
			  .locked(locked),
			  .clk_in1(CLK100));
    assign sysrst = ~locked; // クロックがロックしたらリセットを0に(解除)する

    TicTacToe TicTacToe_i(.clk(sysclk),
			  .reset(sysrst),
			  .io_obj_tx_dout_exp(TXD),
			  .io_obj_rx_din_exp(RXD),
			  .game_manager_busy(),
			  .game_manager_req(1) // free-run
			  );

    (* KEEP *) logic [31:0] heart_beat_counter = 0;
    always @(posedge sysclk) begin
	if(~locked) begin
	    heart_beat_counter <= 0;
	end else begin
	    heart_beat_counter <= heart_beat_counter + 1;
	end
    end
    // LEDに出力して手軽に確認(実機がある場合は便利)
    assign LED = heart_beat_counter[27:24];

endmodule // top

`default_nettype wire

