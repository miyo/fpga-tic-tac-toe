`default_nettype none

module clk_div
  (
   input wire clk,
   input wire rst,
   input wire [15:0] div,
   output reg clk_out
   );

    logic [15:0] counter = 16'h0000;

    always @(posedge clk) begin
	if(rst == 1) begin
            counter <= 0;
	end else if (counter == div) begin
            counter <= 0;
            clk_out <= 1;
	end else begin
            counter <= counter + 1;
            clk_out <= 0;
	end
    end

endmodule // clk_div

`default_nettype wire
