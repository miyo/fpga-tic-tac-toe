
`timescale 1ns/1ns
`default_nettype none

module make_judge_tb();

    localparam ROWS = 3;
    localparam COLS = 3;

    logic clk;
    logic reset;
    logic req;
    logic ready;
    logic [ROWS*COLS-1:0] board_a;
    logic [ROWS*COLS-1:0] board_b;
    logic valid;
    logic end_of_game;
    logic win_a;
    logic win_b;

    initial begin
	clk = 0;
	reset = 1;
	req = 0;
	board_a = 0;
	board_b = 0;
	#200 reset = 0;
    end

    always begin
	#5 clk = ~clk;
    end

    logic [31:0] counter;
    always @(posedge clk) begin
	if(reset == 1) begin
	    counter <= 0;
	end else begin
	    case(counter)
		100: begin
		    req <= 1;
		    board_a <= 9'b000000000;
		    board_b <= 9'b000000000;
		    counter <= counter + 1;
		end
		101: begin
		    req <= 0;
		    if(ready == 1) begin
			if(end_of_game == 0 && win_a == 0 && win_b == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @101");
			    $finish;
			end
		    end
		end

		200: begin
		    req <= 1;
		    board_a <= 9'b111000000;
		    board_b <= 9'b000000000;
		    counter <= counter + 1;
		end
		201: begin
		    req <= 0;
		    if(ready == 1) begin
			if(end_of_game == 1 && win_a == 1 && win_b == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @201");
			    $finish;
			end
		    end
		end
		300: begin
		    req <= 1;
		    board_a <= 9'b000000000;
		    board_b <= 9'b000111000;
		    counter <= counter + 1;
		end
		301: begin
		    req <= 0;
		    if(ready == 1) begin
			if(end_of_game == 1 && win_a == 0 && win_b == 1) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @301");
			    $finish;
			end
		    end
		end
		400: begin
		    req <= 1;
		    board_a <= 9'b110001110;
		    board_b <= 9'b001110001;
		    counter <= counter + 1;
		end
		401: begin
		    req <= 0;
		    if(ready == 1) begin
			if(end_of_game == 1 && win_a == 0 && win_b == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @401");
			    $finish;
			end
		    end
		end
		1000: begin
		    $display("no error");
		    $finish;
		end
		default: begin
		    counter <= counter + 1;
		end
	    endcase
	end
    end

    make_judge#(.ROWS(ROWS), .COLS(COLS))
    make_judge_i(.clk(clk),
		 .reset(reset),
		 .req(req),
		 .ready(ready),
		 .board_a(board_a),
		 .board_b(board_b),
		 .valid(valid), // 手を確定した時に1
		 .end_of_game(end_of_game), // ゲームが終了したフラグ
		 .win_a(win_a), // aが勝ったフラグ
		 .win_b(win_b)  // bが勝ったフラグ
		 );

endmodule // make_judge_tb
