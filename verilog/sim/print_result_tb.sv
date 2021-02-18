`timescale 1ns/1ns
`default_nettype none

module print_result_tb();

    logic clk;
    logic reset;
    logic req;
    logic ready;
    logic win_a;
    logic win_b;
    logic uart_wr;
    logic [7:0] uart_d;
    logic uart_ready;

    initial begin
	clk = 0;
	reset = 1;
	req = 0;
	win_a = 0;
	win_b = 0;
	#100 reset = 0;
	#100;

	win_a = 0;
	win_b = 1;
	req = 1;
	#20 req = 0;
	#2000000;

	win_a = 1;
	win_b = 0;
	req = 1;
	#20 req = 0;
	#2000000;

	win_a = 0;
	win_b = 0;
	req = 1;
	#20 req = 0;
	#2000000;

	$finish;
    end

    always begin
	#5 clk = ~clk;
    end


    print_result print_result_i(
				.clk(clk),
				.reset(reset),
				.req(req),
				.ready(ready),
				.win_a(win_a),
				.win_b(win_b),
				.uart_wr(uart_wr),
				.uart_d(uart_d),
				.uart_ready(uart_ready)
				);

    wire uart_line;
    uart_tx#(.SYS_CLK(100000000), .RATE(115200))
    uart_tx_i(
	      .clk(clk),   // クロック
	      .reset(reset), // リセット
	      .wr(uart_wr),    // 送信要求
	      .din(uart_d), // 送信データ
	      .dout(uart_line), // シリアル出力
	      .ready(uart_ready) // 送信要求を受け付けることができるかどうか
	      );
    wire rd;
    wire [7:0] c;
    uart_rx#(.SYS_CLK(100000000), .RATE(115200))
    uart_rx_i(
	      .clk(clk),
	      .reset(reset),
	      .din(uart_line),
	      .rd(rd),
	      .dout(c)
	      );

endmodule // print_result_tb
