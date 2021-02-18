`default_nettype none

module print_result
  (
   input wire clk,
   input wire reset,

   input wire req,
   output wire ready,
   input wire win_a,
   input wire win_b,

   output reg uart_wr,
   output reg [7:0] uart_d,
   input wire uart_ready
   );

    logic [7:0] message0[11] = {8'h47, // G
				8'h61, // a
				8'h6d, // m
				8'h65, // e
				8'h20, //  
				8'h45, // E
				8'h6e, // n
				8'h64, // d
				8'h3a, // :
				8'h20,
				8'h00};
    logic [7:0] message1[7] = {8'h20, // 
			       8'h57, // W
			       8'h69, // i
			       8'h6e, // n,
			       8'h0d,
			       8'h0a,
			       8'h00
			       };
    logic [7:0] message2[7] = {8'h44, // D
			       8'h72, // r
			       8'h61, // a
			       8'h77, // w
			       8'h0d,
			       8'h0a,
			       8'h00
			       };

    enum {IDLE, MESSAGE0, WINNER, MESSAGE1, DRAW} state;
    logic busy;
    logic [15:0] mesg_index;

    assign ready = (busy == 0 || req == 0) ? 1 : 0;

    always @(posedge clk) begin
	if(reset == 1) begin
	    state <= IDLE;
	    uart_wr <= 0;
	    uart_d <= 0;
	    busy <= 1;
	    mesg_index <= 0;
	end else begin
	    case(state)
		IDLE: begin
		    if(req == 1) begin
			state <= MESSAGE0;
			busy <= 1;
		    end else begin
			busy <= 0;
		    end
		    uart_wr <= 0;
		    mesg_index <= 0;
		end

		MESSAGE0: begin
		    if(uart_ready == 1) begin
			if(message0[mesg_index] == 8'h00) begin
			    uart_wr <= 0;
			    mesg_index <= 0;
			    if(win_a == 1 || win_b == 1) begin
				state <= WINNER;
			    end else begin
				state <= DRAW;
			    end
			end else begin
			    uart_wr <= 1;
			    uart_d <= message0[mesg_index];
			    mesg_index <= mesg_index + 1;
			end
		    end else begin
			uart_wr <= 0;
		    end
		end
		
		WINNER: begin
		    if(win_a == 1) begin
			uart_wr <= 1;
			uart_d <= 8'h31;
		    end else begin
			uart_wr <= 1;
			uart_d <= 8'h32;
		    end
		    state <= MESSAGE1;
		end

		MESSAGE1: begin
		    if(uart_ready == 1) begin
			if(message1[mesg_index] == 8'h00) begin
			    uart_wr <= 0;
			    mesg_index <= 0;
			    state <= IDLE;
			end else begin
			    uart_wr <= 1;
			    uart_d <= message1[mesg_index];
			    mesg_index <= mesg_index + 1;
			end
		    end else begin
			uart_wr <= 0;
		    end
		end

		DRAW: begin
		    if(uart_ready == 1) begin
			if(message2[mesg_index] == 8'h00) begin
			    uart_wr <= 0;
			    mesg_index <= 0;
			    state <= IDLE;
			end else begin
			    uart_wr <= 1;
			    uart_d <= message2[mesg_index];
			    mesg_index <= mesg_index + 1;
			end
		    end else begin
			uart_wr <= 0;
		    end
		end

		default: begin
		    state <= IDLE;
		    uart_wr <= 0;
		    uart_d <= 0;
		    busy <= 1;
		end
	    endcase
	end
    end

endmodule // print_result

`default_nettype wire
