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
module pc_incrementor(
    input clk,
	 input en,
	 input reset,
    output [9:0] pc_out
    );

reg [9:0] pc_out;

always @ (posedge clk)
 begin : COUNTER 
   if (reset == 1'b1) begin
     pc_out <=   10'd0;
   end
   else if (en == 1'b1) begin
     pc_out <=  pc_out + 1;
   end
end
	
endmodule
