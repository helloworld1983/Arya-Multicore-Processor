`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:19:55 03/04/2014 
// Design Name: 
// Module Name:    branch_adder 
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
module branch_adder # (
	parameter INST_ADDR_WIDTH = 9
)(
    input 	[INST_ADDR_WIDTH-1:0] 	branch_offset,
    output 	[INST_ADDR_WIDTH-1:0] 	branch_target
    );

//assign branch_target = pc_in + branch_offset; // Removed because branches are actually jumps
assign branch_target = branch_offset;

endmodule
