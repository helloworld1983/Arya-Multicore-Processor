`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:18:55 03/19/2014 
// Design Name: 
// Module Name:    cpu 
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
module cpu(
    input clk,
	 input reset,
    output reg cpu_done
    );

reg [6:0] count;
always @(posedge clk) begin
if (reset) begin
	count <= 0;
	cpu_done <= 0;
end // if (reset)
else begin
	count <= count + 1;
	if (count == 0) begin
		cpu_done <= 1'b1;
	end
	else begin
		cpu_done <= 1'b0;
	end
end // else !reset	
end// always 

endmodule
