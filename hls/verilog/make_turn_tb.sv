// -*- coding: utf-8 -*-

`timescale 1ns/1ns
`default_nettype none

module make_turn_tb();

    logic ap_clk;
    logic ap_rst;

    logic board_a_ap_vld;
    logic board_b_ap_vld;
    logic turn_a_ap_vld;
    logic ap_start;
    logic ap_done;
    logic ap_idle;
    logic ap_ready;
    logic [31:0] ap_return;
    logic [31:0] board_a;
    logic [31:0] board_b;
    logic [31:0] turn_a;

    initial begin
	ap_clk = 0;
	ap_rst = 1;

	board_a_ap_vld = 0;
	board_b_ap_vld = 0;
	turn_a_ap_vld = 0;
	ap_start = 0;
	board_a = 0;
	board_b = 0;
	turn_a = 0;

	#100 ap_rst = 0;
    end

    always begin
	#5 ap_clk = ~ap_clk;
    end

    logic [31:0] counter;
    always @(posedge ap_clk) begin
	if(ap_rst == 1) begin
	    counter <= 0;
	end else begin
	    case(counter)
		100: begin
		    board_a_ap_vld <= 1;
		    board_a <= 1;
		    board_b_ap_vld <= 1;
		    board_b <= 2;
		    turn_a_ap_vld <= 1;
		    turn_a <= 1;
		    ap_start <= 1;
		    counter <= counter + 1;
		end
		101: begin
		    if(ap_ready == 1) begin
			ap_start <= 0;
		    end
		    if(ap_done == 1) begin
			counter <= counter + 1;
		    end
		end
		200: begin
		    $finish;
		end
		default: begin
		    counter <= counter + 1;
		end
	    endcase
	end
    end


    make_turn_0 make_turn_0_i (
			       .board_a_ap_vld(board_a_ap_vld),  // input wire board_a_ap_vld
			       .board_b_ap_vld(board_b_ap_vld),  // input wire board_b_ap_vld
			       .turn_a_ap_vld(turn_a_ap_vld),    // input wire turn_a_ap_vld
			       .ap_clk(ap_clk),                  // input wire ap_clk
			       .ap_rst(ap_rst),                  // input wire ap_rst
			       .ap_start(ap_start),              // input wire ap_start
			       .ap_done(ap_done),                // output wire ap_done
			       .ap_idle(ap_idle),                // output wire ap_idle
			       .ap_ready(ap_ready),              // output wire ap_ready
			       .ap_return(ap_return),            // output wire [31 : 0] ap_return
			       .board_a(board_a),                // input wire [31 : 0] board_a
			       .board_b(board_b),                // input wire [31 : 0] board_b
			       .turn_a(turn_a)                  // input wire [31 : 0] turn_a
			       );

endmodule // make_turn_tb

`default_nettype wire
