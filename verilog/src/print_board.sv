// -*- coding: utf-8 -*-
// ROWS*COLS用の盤面を表示する
// 出力する行数 = ROWS * 2 + 1
// 出力する列数 = COLS * 2 + 1 + 2(CRLF)
// 出力例:
// +-+-+-+\r\n
// |o|x|o|\r\n
// +-+-+-+\r\n
// |o|x|o|\r\n
// +-+-+-+\r\n
// |o|x|o|\r\n
// +-+-+-+\r\n
//

`default_nettype none

module print_board
  #(parameter ROWS = 3,
    parameter COLS = 3
    )
    (
     input wire clk,   // クロック
     input wire reset, // リセット
     input wire wr,    // 送信要求
     input wire [COLS*ROWS-1:0] board_a,
     input wire [COLS*ROWS-1:0] board_b,
     output wire ready, // 送信要求を受け付けることができるかどうか
     output reg uart_wr,
     output reg [7:0] uart_din,
     input wire uart_ready
     );

    enum {IDLE, SEND_LINE, SEND_DATA, SEND_CR, SEND_LF} state;
    
    logic [9-1:0] board_a_r, board_b_r;
    logic busy;

    logic [31:0] row_counter;
    logic [31:0] col_counter;

    assign ready = (busy == 0 && wr == 0) ? 1 : 0;

    always @(posedge clk) begin
	if(reset == 1) begin
	    state <= IDLE;
	    busy <= 1;
	    uart_wr <= 0;
	    uart_din <= 0;
	end else begin
	    case(state)
		IDLE: begin
		    if(wr == 1) begin
			board_a_r <= board_a;
			board_b_r <= board_b;
			busy <= 1; // 動作中のビジーフラグをたてる
			state <= SEND_LINE;
		    end else begin
			busy <= 0;
		    end
		    row_counter <= 0;
		    col_counter <= 0;
		    uart_wr <= 0;
		    uart_din <= 0;
		end
		SEND_LINE: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			if(row_counter[0] == 0) begin // print separator
			    if(col_counter[0] == 0) begin
				uart_din <= 8'h2b; // '+'
			    end else begin
				uart_din <= 8'h2d; // '-'
			    end
			end else begin // print separator or data
			    if(col_counter[0] == 0) begin
				uart_din <= 8'h7c; // '|'
			    end else begin
				uart_din <= board_a_r[0] == 1 ? 8'h6f // 'o'
					  : board_b_r[0] == 1 ? 8'h78 // 'x'
					  : 8'h20; // ' '
				board_a_r <= {1'b0, board_a_r[COLS*ROWS-1:1]}; // consume
				board_b_r <= {1'b0, board_b_r[COLS*ROWS-1:1]}; // consume
			    end
			end
			if(col_counter == (2*COLS+1)-1) begin
			    state <= SEND_CR;
			end else begin
			    col_counter <= col_counter + 1;
			end
		    end else begin
			uart_wr <= 0;
		    end
		end
		SEND_CR: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_din <= 8'h0d;
			state <= SEND_LF;
		    end else begin
			uart_wr <= 0;
		    end
		end
		SEND_LF: begin
		    if(uart_ready == 1) begin
			uart_wr <= 1;
			uart_din <= 8'h0a;
			if(row_counter == (2*ROWS+1)-1) begin
			    state <= IDLE;
			end else begin
			    state <= SEND_LINE;
			    col_counter <= 0;
			    row_counter <= row_counter + 1;
			end
		    end else begin
			uart_wr <= 0;
		    end
		end
		default: begin
		    state <= IDLE;
		    busy <= 1;
		    uart_wr <= 0;
		    uart_din <= 0;
		end
	    endcase // case (state)
	end
    end

endmodule // print_board

`default_nettype wire

