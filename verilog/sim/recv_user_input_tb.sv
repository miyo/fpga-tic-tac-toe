
`timescale 1ns/1ns
`default_nettype none

module recv_user_input_tb#(parameter ROWS = 3, parameter COLS = 3)();

    logic clk;
    logic reset;
    logic req;
    logic target_a;
    logic [ROWS*COLS-1:0] board_a;
    logic [ROWS*COLS-1:0] board_b;
    logic [ROWS*COLS-1:0] board_a_out;
    logic [ROWS*COLS-1:0] board_b_out;
    logic ready;
    logic error_flag;
    logic valid;
    logic uart_rd;
    logic [7:0] uart_q;
    logic uart_wr;
    logic [7:0] uart_d;
    logic uart_ready;

    initial begin
	clk = 0;
	reset = 1;
	req = 0;
	target_a = 0;
	board_a = 9'b000000000;
	board_b = 9'b000000000;
	uart_rd = 0;
	uart_q = 0;
	uart_ready = 1;
	#100 reset = 0;
    end

    always begin
	#5 clk <= ~clk;
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
		    target_a <= 0;
		    counter <= counter + 1;
		end
		101: begin
		    req <= 0;
		    counter <= counter + 1;
		end
		110: begin
		    uart_q <= 8'h30;
		    uart_rd <= 1;
		    counter <= counter + 1;
		end
		111: begin
		    uart_rd <= 0;
		    counter <= counter + 1;
		end
		130: begin
		    uart_q <= 8'h31;
		    uart_rd <= 1;
		    counter <= counter + 1;
		end
		131: begin
		    uart_rd <= 0;
		    counter <= counter + 1;
		end
		132: begin
		    if(ready == 1) begin
			if(board_a_out == 9'b000000000 && board_b_out == 9'b000001000 && error_flag == 0) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @132");
			    $finish;
			end
		    end
		end

		200: begin
		    req <= 1;
		    board_a <= 9'b000001000;
		    board_b <= 9'b000000000;
		    target_a <= 0;
		    counter <= counter + 1;
		end
		201: begin
		    req <= 0;
		    counter <= counter + 1;
		end
		210: begin
		    uart_q <= 8'h30;
		    uart_rd <= 1;
		    counter <= counter + 1;
		end
		211: begin
		    uart_rd <= 0;
		    counter <= counter + 1;
		end
		230: begin
		    uart_q <= 8'h31;
		    uart_rd <= 1;
		    counter <= counter + 1;
		end
		231: begin
		    uart_rd <= 0;
		    counter <= counter + 1;
		end
		232: begin
		    if(ready == 1) begin
			if(board_a_out == 9'b000001000 && board_b_out == 9'b000000000 && error_flag == 1) begin
			    counter <= counter + 1;
			end else begin
			    $display("error @232");
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

    recv_user_input#(.ROWS(ROWS), .COLS(COLS))
    recv_user_input_i(
		      .clk(clk),   // クロック
		      .reset(reset), // リセット
		      .req(req),    // 受信開始要求
		      .target_a(target_a), // ターゲットがaであることを示すフラグ．
		      .board_a(board_a),
		      .board_b(board_b),
		      .board_a_out(board_a_out),
		      .board_b_out(board_b_out),
		      .ready(ready), // 送信要求を受け付けることができるかどうか
		      .error_flag(error_flag), // 入力が無効だったことを示すフラグ
		      .valid(valid), // 結果が確定したことを示すフラグ
		      .uart_rd(uart_rd), // UART受信モジュールのデータ確定フラグ
		      .uart_q(uart_q), // UART受信モジュールの出力
		      .uart_wr(uart_wr), // UART送信モジュールの書き込みフラグ
		      .uart_d(uart_d), // UART送信モジュールへのデータ
		      .uart_ready(uart_ready)
		      );

endmodule // recv_user_input_tb
