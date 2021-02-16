`timescale 1ns/1ns
`default_nettype none

module print_board_tb();

    logic clk;
    logic reset;
    logic wr;
    logic [9-1:0] board_a;
    logic [9-1:0] board_b;
    logic ready;
    logic rd;
    logic [7:0] cout;
    logic [7:0] uart_din;
    logic uart_wr, uart_ready;
    logic uart_txd, uart_rxd;

    initial begin
	clk = 0;
	reset = 1;
	wr = 0;
	board_a = 9'b100010001;
	board_b = 9'b010101010;
	#100 reset <= 0;
	#200 wr = 1;
	#210 wr = 0;
    end
    always begin
	#5 clk <= ~clk;
    end

    print_board#(.SYS_CLK(100000000),
		 .RATE(9600),
		 .ROWS(3),
		 .COLS(3)
		 )
    print_board_i(.clk(clk),
		  .reset(reset),
		  .wr(wr),
		  .board_a(board_a),
		  .board_b(board_b),
		  .ready(ready),
		  .uart_wr(uart_wr),
		  .uart_din(uart_din),
		  .uart_ready(uart_ready));

    uart_tx#(.SYS_CLK(100000000),
	     .RATE(9600))
    uart_tx_i(.clk(clk),
	      .reset(reset),
	      .wr(uart_wr),
	      .din(uart_din),
	      .dout(uart_txd),
	      .ready(uart_ready)
	      );

    uart_rx#(.SYS_CLK(100000000),
	     .RATE(9600))
    uart_rx_i(.clk(clk),
	      .reset(reset),
	      .din(uart_rxd), // input from print_board
	      .rd(rd),        // 受信完了を示す
	      .dout(cout));
    assign uart_rxd = uart_txd;

endmodule // print_board_tb
