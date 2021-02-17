// -*- coding: utf-8 -*-
// ゲーム全体の進行をする

`default_nettype none

module game_manager#(parameter ROWS=3, parameter COLS=3)
  (
   input wire clk,
   input wire reset,
   input wire kick_game,
   input wire my_target_a,
   output reg print_board_wr,
   input wire print_board_ready,
   output reg make_turn_req,
   input wire make_turn_ready,
   output reg recv_req,
   input wire recv_ready,
   input wire recv_error,
   output reg make_judge_req,
   input wire make_judge_ready,
   input wire end_of_game,
   input wire win_a,
   input wire win_b,
   output wire [ROWS*COLS-1:0] board_a,
   output wire [ROWS*COLS-1:0] board_b,
   input wire [ROWS*COLS-1:0] make_turn_board_a,
   input wire [ROWS*COLS-1:0] make_turn_board_b,
   input wire [ROWS*COLS-1:0] recv_board_a,
   input wire [ROWS*COLS-1:0] recv_board_b
   );

    // 盤面を保持するレジスタ
    logic [ROWS*COLS-1:0] cur_board_a;
    logic [ROWS*COLS-1:0] cur_board_b;

    assign board_a = cur_board_a;
    assign board_b = cur_board_b;

    enum {IDLE,
	  PRINT_BOARD, PRINT_BOARD_WAIT,
	  JUDGE_BOARD, JUDGE_BOARD_WAIT,
	  MY_TURN, MY_TURN_WAIT,
	  OPPOSITE_TURN, OPPOSITE_TURN_WAIT}
	 state, post_state;

    logic kick_game_d;

    always @(posedge clk) begin
	if(reset) begin
	    state <= IDLE;
	    post_state <= IDLE;
	    kick_game_d <= 1;
	    print_board_wr <= 0;
	    make_turn_req <= 0;
	    recv_req <= 0;
	    make_judge_req <= 0;
	    cur_board_a <= 0;
	    cur_board_b <= 0;
	end else begin
	    kick_game_d <= kick_game;
	    case(state)
		IDLE: begin
		    if(kick_game == 1 && kick_game_d == 0) begin
			state <= PRINT_BOARD;
			if(my_target_a == 1) begin
			    post_state <= MY_TURN; // 先攻がFPGA(=my)
			end else begin
			    post_state <= OPPOSITE_TURN; // 先攻がユーザ
			end
		    end
		    print_board_wr <= 0;
		    make_turn_req <= 0;
		    recv_req <= 0;
		    make_judge_req <= 0;
		    cur_board_a <= 0;
		    cur_board_b <= 0;
		end

		PRINT_BOARD: begin
		    if(print_board_ready == 1) begin
			print_board_wr <= 1;
			state <= PRINT_BOARD_WAIT;
		    end else begin
			print_board_wr <= 0;
		    end
		end
		PRINT_BOARD_WAIT: begin
		    print_board_wr <= 0;
		    if(print_board_ready == 1) begin
			state <= JUDGE_BOARD;
		    end
		end

		JUDGE_BOARD: begin
		    if(make_judge_ready == 1) begin
			make_judge_req <= 1;
			state <= JUDGE_BOARD_WAIT;
		    end else begin
			make_judge_req <= 0;
		    end
		end
		JUDGE_BOARD_WAIT: begin
		    make_judge_req <= 0;
		    if(make_judge_ready == 1) begin
			if(end_of_game == 1) begin
			    state <= IDLE;
			end else begin
			    state <= post_state;
			end
		    end
		end

		MY_TURN: begin
		    if(make_turn_ready == 1) begin
			make_turn_req <= 1;
			state <= MY_TURN_WAIT;
		    end else begin
			make_turn_req <= 0;
		    end
		end
		MY_TURN_WAIT: begin
		    make_turn_req <= 0;
		    if(make_turn_ready == 1) begin
			state <= PRINT_BOARD;
			post_state <= OPPOSITE_TURN;
			cur_board_a <= make_turn_board_a;
			cur_board_b <= make_turn_board_b;
		    end
		end

		OPPOSITE_TURN: begin
		    if(recv_ready == 1) begin
			recv_req <= 1;
			state <= OPPOSITE_TURN_WAIT;
		    end else begin
			recv_req <= 0;
		    end
		end
		OPPOSITE_TURN_WAIT: begin
		    recv_req <= 0;
		    if(recv_ready == 1) begin
			if(recv_error == 1) begin
			    state <= OPPOSITE_TURN;
			end else begin
			    state <= PRINT_BOARD;
			    post_state <= MY_TURN;
			    cur_board_a <= recv_board_a;
			    cur_board_b <= recv_board_b;
			end
		    end
		end

		default: begin
		    state <= IDLE;
		    post_state <= IDLE;
		    kick_game_d <= 1;
		    print_board_wr <= 0;
		    make_turn_req <= 0;
		    recv_req <= 0;
		    make_judge_req <= 0;
		    cur_board_a <= 0;
		    cur_board_b <= 0;
		end

	    endcase // case (state)
	end
    end

endmodule // game_manager

`default_nettype wire
