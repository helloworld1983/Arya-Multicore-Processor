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

`define INST_WIDTH 32
`define REGFILE_ADDR 3
`define DATAPATH_WIDTH 64
`define INST_MEM_ADDR 9
`define DATA_MEM_ADDR 9
`define INST_MEM_START 0
`define DATA_MEM_START 512

module pipe_mem_wb(WRegEn_in,Mem_data_in,WReg1_in,clk,en,reset,WReg1_out,WRegEn_out,Mem_data_out);
    input WRegEn_in;
    input [`DATAPATH_WIDTH-1:0] Mem_data_in;
    input [`REGFILE_ADDR-1:0] WReg1_in;
    input clk;
    input en;
    input reset;
    output [`REGFILE_ADDR-1:0] WReg1_out;
    output WRegEn_out;
    output [`DATAPATH_WIDTH-1:0] Mem_data_out;
	 
	 reg [`REGFILE_ADDR-1:0] WReg1_out;
    reg WRegEn_out;
    reg [`DATAPATH_WIDTH-1:0] Mem_data_out;
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		WReg1_out <= 'd0;
		WRegEn_out <= 'd0;
		Mem_data_out <= 'd0;		
	 end
	 else if (en) begin
		WReg1_out <= WReg1_in;
		WRegEn_out <= WRegEn_in;
		Mem_data_out <= Mem_data_in;
	 end
	end
endmodule
