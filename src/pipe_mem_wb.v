`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:05:13 02/23/2014 
// Design Name: 
// Module Name:    pipe_mem_wb 
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
module pipe_mem_wb(WRegEn_in,Mem_data_in,WReg1_in,clk,en,reset,WReg1_out,WRegEn_out,Mem_data_out);
    input WRegEn_in;
    input [63:0] Mem_data_in;
    input [2:0] WReg1_in;
    input clk;
    input en;
    input reset;
    output [2:0] WReg1_out;
    output WRegEn_out;
    output [63:0] Mem_data_out;
    
endmodule
