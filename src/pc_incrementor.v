`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:09:25 02/23/2014 
// Design Name: 
// Module Name:    pc_incrementor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module pc_incrementor
	#(parameter INST_ADDR_WIDTH = 6)

   (input clk,
	 input en,
	 input reset,
	 input wen,
	 input [INST_ADDR_WIDTH - 1:0] 	pc_in,
    output reg [INST_ADDR_WIDTH + 1:0] pc_out
	 );
   
always @ (posedge clk)
 begin : COUNTER 
   if (reset) begin
     pc_out <=   'b0;
   end
   else if (en) begin
		if (wen) begin
			pc_out[INST_ADDR_WIDTH + 1 :2] <= pc_in;
		end
		else begin
			pc_out 	<= pc_out + 'b1;
		end // else
   end // else if not enable
end // always
	
endmodule
