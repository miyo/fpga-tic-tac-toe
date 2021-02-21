`timescale 1ns/1ns
`default_nettype none

module game_manager_tb();

    localparam ROWS = 3;
    localparam COLS = 3;

    logic clk;
    logic reset;
    logic kick_game;
    logic my_target_a;
    logic print_board_wr;
    logic print_board_ready;
    logic make_turn_req;
    logic make_turn_ready;
    logic recv_req;
    logic recv_ready;
    logic recv_error;
    logic make_judge_req;
    logic make_judge_ready;
    logic end_of_game;
    logic win_a;
    logic win_b;
    logic [ROWS*COLS-1:0] board_a;
    logic [ROWS*COLS-1:0] board_b;
    logic [ROWS*COLS-1:0] make_turn_board_a;
    logic [ROWS*COLS-1:0] make_turn_board_b;
    logic [ROWS*COLS-1:0] recv_board_a;
    logic [ROWS*COLS-1:0] recv_board_b;
    logic print_result_req;
    logic print_result_ready;
    logic print_result_win_a;
    logic print_result_win_b;

    initial begin
	clk = 0;
	reset = 1;
	kick_game = 0;
	my_target_a = 1;
	print_board_ready = 1;
	make_turn_ready = 1;
	print_result_ready = 1;
	recv_ready = 1;
	recv_error = 0;
	make_judge_ready = 1;
	make_turn_board_a = 0;
	make_turn_board_b = 0;
	recv_board_a = 0;
	recv_board_b = 0;
	end_of_game = 0;
	win_a = 0;
	win_b = 1;
	#100;
	reset = 0;
	#20;
	kick_game = 1;
	#1000;
	end_of_game = 1;
	#100;
	$finish;
    end

    always begin
	#5; clk = ~clk;
    end

    game_manager#(.ROWS(3), .COLS(3))
    game_manager_i(.clk(clk),
		   .reset(reset),
		   .kick_game(kick_game),
		   .my_target_a(my_target_a),
		   .print_board_wr(print_board_wr),
		   .print_board_ready(print_board_ready),
		   .make_turn_req(make_turn_req),
		   .make_turn_ready(make_turn_ready),
		   .recv_req(recv_req),
		   .recv_ready(recv_ready),
		   .recv_error(recv_error),
		   .make_judge_req(make_judge_req),
		   .make_judge_ready(make_judge_ready),
		   .end_of_game(end_of_game),
		   .win_a(win_a),
		   .win_b(win_b),
		   .board_a(board_a),
		   .board_b(board_b),
		   .make_turn_board_a(make_turn_board_a),
		   .make_turn_board_b(make_turn_board_b),
		   .recv_board_a(recv_board_a),
		   .recv_board_b(recv_board_b),
		   .print_result_req(print_result_req),
		   .print_result_ready(print_result_ready),
		   .print_result_win_a(print_result_win_a),
		   .print_result_win_b(print_result_win_b)
		   );

endmodule // game_manager_tb

