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
	#(parameter INST_ADDR_WIDTH = 8)

   (input clk,
	 input en,
	 input reset,
	 input wen,
	 input [INST_ADDR_WIDTH - 1:0] 	pc_in,
    output reg [INST_ADDR_WIDTH + 1:0] pc_out
	 );
   
always @ (posedge clk)
 begin : COUNTER 
   if (reset == 1'b1) begin
     pc_out <=   'd0;
   end
   else if (en == 1'b1) begin
		if (wen) 	pc_out[INST_ADDR_WIDTH + 1 :2] <= pc_in;
		else 			pc_out 	<= pc_out + 1;
   end
end
	
endmodule
