
`timescale 1ns/1ns
`default_nettype none

module make_turn_tb#(parameter ROWS = 3, parameter COLS = 3)();

    logic clk;
    logic reset;
    logic req;
    logic ready;
    logic target_a;
    logic [ROWS*COLS-1:0] board_a;
    logic [ROWS*COLS-1:0] board_b;
    logic [ROWS*COLS-1:0] board_a_out;
    logic [ROWS*COLS-1:0] board_b_out;
    logic valid;
    logic error;

    initial begin
	clk = 0;
	reset = 1;
	req = 0;
	target_a = 1;
	board_a = 0;
	board_b = 0;
	#100 reset = 0;
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
		    target_a <= 1;
		    counter <= counter + 1;
		end
		101: begin
		    req <= 0;
		    if(ready == 1) begin
			if(board_a_out == 9'b000000001 && board_b_out == 9'b000000000 && error == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @101");
			    $finish;
			end
		    end
		end

		200: begin
		    req <= 1;
		    board_a <= 9'b000010101;
		    board_b <= 9'b000101010;
		    target_a <= 0; // board_bを更新させる
		    counter <= counter + 1;
		end
		201: begin
		    req <= 0;
		    if(ready == 1) begin
			if(board_a_out == 9'b000010101 && board_b_out == 9'b001101010 && error == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @201");
			    $finish;
			end
		    end
		end
		
		300: begin
		    req <= 1;
		    board_a <= 9'b111010101;
		    board_b <= 9'b000101010;
		    target_a <= 0; // board_bを更新させる
		    counter <= counter + 1;
		end
		301: begin
		    req <= 0;
		    if(ready == 1) begin
			if(board_a_out == 9'b111010101 && board_b_out == 9'b000101010 && error == 1) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @301");
			    $finish;
			end
		    end
		end

		1000: begin
		    $finish;
		end

		default: begin
		    counter <= counter + 1;
		end
	    endcase
	end
    end

    make_turn#(.ROWS(3), .COLS(3))
    make_turn_i(.clk(clk),
		.reset(reset),
		.req(req),
		.ready(ready),
		.target_a(target_a), // 自分のボードがaならば1
		.board_a(board_a),
		.board_b(board_b),
		.board_a_out(board_a_out),
		.board_b_out(board_b_out),
		.valid(valid), // 手を確定した時に1
		.error(error) // 手がみつからなかったとき1
		);

endmodule // make_turn_tb

