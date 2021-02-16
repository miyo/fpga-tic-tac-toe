`default_nettype none

module main
  (
   input  wire CLK100,
   input  wire RESET,
   input  wire RXD,
   output wire TXD,
   output wire [3:0] LED
   );

    localparam SYS_CLK_FREQ = 100000000;
    localparam UART_RATE = 115200;
    localparam ROWS = 3;
    localparam COLS = 3;

    // システムクロックとリセット
    wire sysclk;
    wire sysrst;

    // ゲームの開始フラグ
    (* KEEP *) logic kick_game;

    // my(=FPGA)が先攻する場合1，後攻の場合0
    logic my_target_a = 1;

    // 盤面を保持するレジスタ
    logic [ROWS*COLS-1:0] board_a;
    logic [ROWS*COLS-1:0] board_b;

    // UART入出力
    logic [7:0] uart_din;
    logic uart_wr;
    logic uart_ready;
    logic [7:0] uart_q;
    logic uart_rd;

    // 盤面表示モジュール用
    logic print_board_wr;
    logic print_board_ready;
    logic print_board_uart_wr;
    logic [7:0] print_board_uart_din;

    // ユーザ入力受付モジュールとの接続
    logic recv_req;
    logic recv_target_a;
    logic [ROWS*COLS-1:0] recv_board_a;
    logic [ROWS*COLS-1:0] recv_board_b;
    logic recv_ready;
    logic recv_error;
    logic recv_valid;
    logic recv_uart_wr;
    logic [7:0] recv_uart_din;

    // 手を決めるモジュールとの接続
    logic make_turn_req;
    logic make_turn_ready;
    logic make_turn_target_a;
    logic [ROWS*COLS-1:0] make_turn_board_a;
    logic [ROWS*COLS-1:0] make_turn_board_b;
    logic make_turn_valid;
    logic make_turn_error;

    // 盤面の終了判定をするモジュールとの接続
    logic make_judge_req;
    logic make_judge_ready;
    logic make_judge_valid;
    logic make_judge_end_of_game;
    logic make_judge_win_a;
    logic make_judge_win_b;

    /////////////////////////////////////////////////////////////////////////
    // システムクロックの生成
    // cf. https://www.acri.c.titech.ac.jp/wordpress/archives/45
    /////////////////////////////////////////////////////////////////////////
    wire locked;
    clk_wiz_0 clk_wiz_0_i(.clk_out1(sysclk),
			  .reset(RESET),
			  .locked(locked),
			  .clk_in1(CLK100));
    assign sysrst = ~locked; // クロックがロックしたらリセットを0に(解除)する
    /////////////////////////////////////////////////////////////////////////
    
    
    /////////////////////////////////////////////////////////////////////////
    // UARTで文字を出力するモジュール
    /////////////////////////////////////////////////////////////////////////
    uart_tx#(.SYS_CLK(SYS_CLK_FREQ), .RATE(UART_RATE))
    uart_tx_i(.clk(sysclk),
	      .reset(sysrst),
	      .wr(uart_wr),
	      .din(uart_din),
	      .dout(TXD),
	      .ready(uart_ready)
	      );
    /////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////
    // UARTで文字を受理するモジュール
    /////////////////////////////////////////////////////////////////////////
    uart_rx#(.SYS_CLK(SYS_CLK_FREQ), .RATE(UART_RATE))
    uart_rx_i(.clk(sysclk),
	      .reset(sysrst),
	      .din(RXD),
	      .rd(uart_rd),
	      .dout(uart_q));
    /////////////////////////////////////////////////////////////////////////

    
    /////////////////////////////////////////////////////////////////////////
    // UART文字出力モジュールを排他的に利用するため
    /////////////////////////////////////////////////////////////////////////
    assign uart_wr = print_board_uart_wr || recv_uart_wr;
    assign uart_din = recv_uart_wr == 1 ? recv_uart_din :
		      print_board_uart_wr == 1 ? print_board_uart_din :
		      0;
    /////////////////////////////////////////////////////////////////////////
    

    /////////////////////////////////////////////////////////////////////////
    // ゲームの進行を管理するモジュールのインスタンス生成
    /////////////////////////////////////////////////////////////////////////
    game_manager game_manager_i(
		 .clk(sysclk),
		 .reset(sysrst),
		 .kick_game(kick_game),
		 .my_target_a(my_target_a),
		 .print_board_wr(print_board_wr),
		 .print_board_ready(print_board_ready),
		 .make_turn_req(make_turn_req),
		 .make_turn_ready(make_turn_ready),
		 .recv_req(recv_req),
		 .recv_ready(recv_ready),
		 .make_judge_req(make_judge_req),
		 .make_judge_ready(make_judge_ready),
		 .end_of_game(make_judge_end_of_game),
		 .win_a(make_judge_win_a),
		 .win_b(make_judge_win_b)
		 );

    /////////////////////////////////////////////////////////////////////////
    // ゲームの盤面を表示するモジュールのインスタンス生成
    /////////////////////////////////////////////////////////////////////////
    print_board#(.ROWS(ROWS), .COLS(COLS))
    print_board_i(.clk(sysclk),
		  .reset(sysrst), // リセット
		  .wr(print_board_wr),    // 送信要求
		  .board_a(board_a),
		  .board_b(board_b),
		  .ready(print_board_ready), // 送信要求を受け付けることができるかどうか
		  .uart_wr(print_board_uart_wr),
		  .uart_din(print_board_uart_din),
		  .uart_ready(uart_ready)
		  );
    /////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////
    // ユーザ入力を受け付けるモジュールのインスタンス生成
    /////////////////////////////////////////////////////////////////////////
    recv_user_input#(.ROWS(ROWS), .COLS(COLS))
    recv_user_input_i(.clk(sysclk),
		      .reset(sysrst),
		      .req(recv_req),
		      .target_a(recv_target_a), // ターゲットがaであることを示すフラグ．
		      .board_a(board_a),
		      .board_b(board_b),
		      .board_a_out(recv_board_a),
		      .board_b_out(recv_board_b),
		      .ready(recv_ready),
		      .error_flag(recv_error),
		      .valid(recv_valid),
		      .uart_rd(uart_rd),
		      .uart_q(uart_q),
		      .uart_wr(recv_uart_wr),
		      .uart_d(recv_uart_din),
		      .uart_ready(uart_ready)
		      );
    assign recv_target_a = ~my_target_a;
    /////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////
    // 手を決めるモジュールのインスタンス生成
    /////////////////////////////////////////////////////////////////////////
    make_turn#(.ROWS(ROWS), .COLS(COLS))
    make_turn_i(.clk(sysclk),
		.reset(sysrst),
		.req(make_turn_req),
		.ready(make_turn_ready),
		.target_a(make_turn_target_a), // 自分のボードがaならば1
		.board_a(board_a),
		.board_b(board_b),
		.board_a_out(make_turn_board_a),
		.board_b_out(make_turn_board_b),
		.valid(make_turn_valid),
		.error(make_turn_error)
		);
    assign make_turn_target_a = ~my_target_a;
    /////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////
    // ゲームの終了判定をするインスタンスの生成
    /////////////////////////////////////////////////////////////////////////
    make_judge#(.ROWS(ROWS), .COLS(COLS))
    make_judge_i(.clk(sysclk),
		 .reset(sysrst),
		 .req(make_judge_req),
		 .ready(make_judge_ready),
		 .board_a(board_a),
		 .board_b(board_b),
		 .valid(make_judge_valid), // 手を確定した時に1
		 .end_of_game(make_judge_end_of_game), // ゲームが終了したフラグ
		 .win_a(make_judge_win_a), // aが勝ったフラグ
		 .win_b(make_judge_win_b)  // bが勝ったフラグ
		 );


    /////////////////////////////////////////////////////////////////////////
    // FPGAが動いていることを確認するためのカウンタ
    /////////////////////////////////////////////////////////////////////////
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
    /////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////
    // 実機がなくてもILAで確認できるようvioにつないでおく
    // cf. https://www.acri.c.titech.ac.jp/wordpress/archives/43
    /////////////////////////////////////////////////////////////////////////
    vio_0 vio_0_i(.clk(sysclk),
		  .probe_in0(heart_beat_counter[31:24]),
		  .probe_out0({kick_game})
		  );
    /////////////////////////////////////////////////////////////////////////

endmodule // main

