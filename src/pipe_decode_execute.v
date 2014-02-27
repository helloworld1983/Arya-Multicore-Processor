`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:39:42 02/23/2014 
// Design Name: 
// Module Name:    pipe_decode_execute 
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
module pipe_decode_execute(WRegEn_in,WMemEn_in,R1out_in,R2out_in,WReg1_in,clk,en,reset,WRegEn_out,WMemEn_out,R1out_out,R2out_out,WReg1_out);
    input WRegEn_in;
    input WMemEn_in;
    input [63:0] R1out_in;
    input [63:0] R2out_in;
    input [2:0] WReg1_in;
    input clk;
    input en;
	 input reset;
    output WRegEn_out;
    output WMemEn_out;
    output [63:0] R1out_out;
    output [63:0] R2out_out;
    output [2:0] WReg1_out;
	 
    


endmodule
