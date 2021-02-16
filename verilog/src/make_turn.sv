// -*- coding: utf-8 -*-
// 自分の手を決める

`default_nettype none

module make_turn#(parameter ROWS = 3, parameter COLS = 3)
    (
     input wire clk,
     input wire reset,
     input wire req,
     output wire ready,
     input wire target_a, // 自分のボードがaならば1
     input wire [ROWS*COLS-1:0] board_a,
     input wire [ROWS*COLS-1:0] board_b,
     output reg [ROWS*COLS-1:0] board_a_out,
     output reg [ROWS*COLS-1:0] board_b_out,
     output reg valid, // 手を確定した時に1
     output reg error // 手がみつからなかったとき1
     );

    logic busy;
    enum {IDLE, CHECK, EMIT} state;

    logic [ROWS*COLS-1:0] board_a_r, board_b_r;
    logic target_a_r;

    logic [31:0] pt;
    
    assign ready = (req == 0 && busy == 0) ? 1 : 0;

    always @(posedge clk) begin
	if(reset == 1) begin
	    busy <= 1;
	    state <= IDLE;
	    pt <= 0;
	    error <= 0;
	end else begin
	    case(state)
		IDLE: begin
		    if(req == 1) begin
			busy <= 1;
			board_a_r <= board_a;
			board_b_r <= board_b;
			target_a_r <= target_a;
			pt <= 0;
			error <= 0;
			pt <= 0; // 愚直に0から探す
		    end else begin
			busy <= 0;
		    end
		    valid <= 0;
		end
		CHECK: begin
		    if(board_a_r[pt] == 0 && board_b_r[pt] == 0) begin
			if(target_a_r == 1) begin
			    board_a_r[pt] <= 1;
			end else begin
			    board_a_r[pt] <= 0;
			end
			state <= EMIT;
		    end else begin
			if(pt == COLS*ROWS-1) begin
			    // 最後の候補を試したのになかった
			    error <= 1;
			    state <= EMIT;
			end else begin
			    pt <= pt + 1; // 次の候補を試してみる
			end
		    end
		end
		EMIT: begin
		    board_a_out <= board_a_r;
		    board_b_out <= board_b_r;
		    valid <= 1;
		    state <= IDLE;
		end
		default: begin
		    busy <= 1;
		    state <= IDLE;
		    pt <= 0;
		    error <= 0;
		end
	    endcase
	end
    end
    
endmodule // make_turn

`default_nettype wire
