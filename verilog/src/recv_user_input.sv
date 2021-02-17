// -*- coding: utf-8 -*-
// ユーザ入力をうけつける

`default_nettype none

module recv_user_input#(parameter ROWS = 3, parameter COLS = 3)
    (
     input wire clk,   // クロック
     input wire reset, // リセット
     input wire req,    // 受信開始要求
     input wire target_a, // ターゲットがaであることを示すフラグ．
     input wire [COLS*ROWS-1:0] board_a,
     input wire [COLS*ROWS-1:0] board_b,
     output wire [COLS*ROWS-1:0] board_a_out,
     output wire [COLS*ROWS-1:0] board_b_out,
     output wire ready, // 送信要求を受け付けることができるかどうか
     output reg error_flag, // 入力が無効だったことを示すフラグ
     output reg valid, // 結果が確定したことを示すフラグ
     input wire uart_rd, // UART受信モジュールのデータ確定フラグ
     input wire [7:0] uart_q, // UART受信モジュールの出力
     output reg uart_wr, // UART送信モジュールの書き込みフラグ
     output reg [7:0] uart_d, // UART送信モジュールへのデータ
     input wire uart_ready 
     );

    enum {IDLE, PROMPT0, RECV0, PROMPT1, RECV1, GET_INDEX, EMIT, CR, LF} state;
    logic busy;
    logic target_a_r;
    logic [7:0] col, row; // 入力された列・行の保存用
    logic [15:0] index;

    logic [COLS*ROWS-1:0] board_a_r;
    logic [COLS*ROWS-1:0] board_b_r;

    logic uart_rd_d;

    assign ready = (req == 0 && busy == 0) ? 1 : 0;

    always @(posedge clk) begin
	if(reset == 1) begin
	    state <= IDLE;
	    busy <= 1;
	    valid <= 0;
	    error_flag <= 0;
	    uart_wr <= 0;
	    board_a_r <= 0;
	    board_b_r <= 0;
	    uart_d <= 0;
	    col <= 0;
	    row <= 0;
	    index <= 0;
	    target_a_r <= 0;
	    uart_rd_d <= 1;
	end else begin
	    uart_rd_d <= uart_rd;
	    case(state)
		IDLE: begin
		    if(req == 1) begin
			busy <= 1;
			error_flag <= 0; // 次のアクション開始でエラーフラグをリセット
			state <= PROMPT0;
			target_a_r <= target_a;
			board_a_r <= board_a;
			board_b_r <= board_b;
		    end else begin
			busy <= 0;
		    end
		    valid <= 0;
		    uart_wr <= 0;
		end
		PROMPT0: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_d <= 8'h3f; // '?'
			state <= RECV0;
		    end else begin
			uart_wr <= 0;
		    end
		end
		RECV0: begin
		    uart_wr <= 0;
		    if(uart_rd == 1 && uart_rd_d == 0) begin
			if(uart_q < 8'h30 || 8'h32 < uart_q) begin
			    // 入力文字列が0-2の範囲外なのでエラー
			    valid <= 1;
			    error_flag <= 1;
			    state <= IDLE;
			end else begin
			    col <= uart_q - 8'h30;
			    state <= PROMPT1;
			end
		    end
		end
		PROMPT1: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_d <= 8'h3f; // '?'
			state <= RECV1;
		    end else begin
			uart_wr <= 0;
		    end
		end
		RECV1: begin
		    uart_wr <= 0;
		    if(uart_rd == 1 && uart_rd_d == 0) begin
			if(uart_q < 8'h30 || 8'h32 < uart_q) begin
			    // 入力文字列が0-2の範囲外なのでエラー
			    valid <= 1;
			    error_flag <= 1;
			    state <= IDLE;
			end else begin
			    row <= uart_q - 8'h30;
			    state <= GET_INDEX;
			end
		    end
		end
		GET_INDEX: begin
		    index <= row * COLS + col;
		    state <= EMIT;
		end
		EMIT: begin
		    if(board_a_r[index] == 0 && board_b_r[index] == 0) begin
			// どちらも未着手の場所だった場合のみ有効
			if(target_a_r == 1) begin
			    board_a_r[index] <= 1;
			end else begin
			    board_b_r[index] <= 1;
			end
			error_flag <= 0; // エラーではない
		    end else begin
			// どちらかが着手済みの場合は無効
			error_flag <= 1; // エラーフラグをたてる
		    end
		    valid <= 1; // 結果確定フラグを立てる
		    state <= CR;
		end
		CR: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_d <= 8'h0d; // '\r'
			state <= LF;
		    end else begin
			uart_wr <= 0;
		    end
		end
		LF: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_d <= 8'h0a; // '\n'
			state <= IDLE;
		    end else begin
			uart_wr <= 0;
		    end
		end
		default: begin
		    state <= IDLE;
		    busy <= 1;
		    valid <= 0;
		    error_flag <= 0;
		end
	    endcase
	end
    end
    assign board_a_out = board_a_r;
    assign board_b_out = board_b_r;

endmodule // recv_user_input

`default_nettype wire
