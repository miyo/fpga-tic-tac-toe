// -*- coding: utf-8 -*-
// ゲームが終了しているかどうかを判定する

`default_nettype none

module make_judge#(parameter ROWS = 3, parameter COLS = 3)
    (
     input wire clk,
     input wire reset,
     input wire req,
     output wire ready,
     input wire [ROWS*COLS-1:0] board_a,
     input wire [ROWS*COLS-1:0] board_b,
     output reg valid, // 手を確定した時に1
     output reg end_of_game, // ゲームが終了したフラグ
     output reg win_a, // aが勝ったフラグ
     output reg win_b  // bが勝ったフラグ
     );

    function [0:0] check_win(input [ROWS*COLS-1:0] board);
	if({board[0], board[1], board[2]} == 3'b111 ||
	   {board[3], board[4], board[5]} == 3'b111 ||
	   {board[6], board[7], board[8]} == 3'b111 ||
	   {board[0], board[3], board[6]} == 3'b111 ||
	   {board[1], board[4], board[7]} == 3'b111 ||
	   {board[2], board[5], board[8]} == 3'b111 ||
	   {board[0], board[4], board[8]} == 3'b111 ||
	   {board[2], board[4], board[6]} == 3'b111) begin
	    check_win = 1'b1;
	end else begin
	    check_win = 1'b0;
	end
    endfunction : check_win

    enum {IDLE, CHECK, EMIT} state;
    logic busy;

    assign ready = (req == 0 && busy == 0) ? 1 : 0;

    always @(posedge clk) begin
	if(reset == 1) begin
	    state <= IDLE;
	    busy <= 1;
	    valid <= 0;
	end else begin
	    case(state)
		IDLE: begin
		    if(req == 1) begin
			busy <= 1;
			state <= CHECK;
			end_of_game <= 0;
			win_a <= 0;
			win_b <= 0;
		    end else begin
			busy <= 0;
		    end
		    valid <= 0;
		end
		CHECK: begin
		    state <= EMIT;
		    if(check_win(board_a) == 1) begin
			win_a <= 1;
			win_b <= 0;
			end_of_game <= 1;
		    end else if(check_win(board_b) == 1) begin
			win_a <= 0;
			win_b <= 1;
			end_of_game <= 1;
		    end else if(&(board_a | board_b) == 1) begin
			// 全てのマスが埋まったのに勝敗が決していないのでドロー
			win_a <= 0;
			win_b <= 0;
			end_of_game <= 1;
		    end else begin
			win_a <= 0;
			win_b <= 1;
			end_of_game <= 0;
		    end
		end
		EMIT: begin
		    valid <= 1;
		    state <= IDLE;
		end
		default: begin
		    state <= IDLE;
		    busy <= 1;
		    valid <= 0;
		end
	    endcase
	end      
    end

endmodule // make_judge

`default_nettype wire

