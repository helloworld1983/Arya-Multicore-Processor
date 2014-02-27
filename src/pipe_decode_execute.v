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

`define INST_WIDTH 32
`define REGFILE_ADDR 3
`define DATAPATH_WIDTH 64
`define MEM_ADDR_WIDTH 10
`define INST_MEM_START 0
`define DATA_MEM_START 512

module pipe_decode_execute(WRegEn_in,WMemEn_in,R1out_in,R2out_in,WReg1_in,clk,en,reset,WRegEn_out,WMemEn_out,R1out_out,R2out_out,WReg1_out);
    input WRegEn_in;
    input WMemEn_in;
    input [`DATAPATH_WIDTH-1:0] R1out_in;
    input [`DATAPATH_WIDTH-1:0] R2out_in;
    input [`REGFILE_ADDR-1:0] WReg1_in;
    input clk;
    input en;
	 input reset;
    output WRegEn_out;
    output WMemEn_out;
    output [`DATAPATH_WIDTH-1:0] R1out_out;
    output [`DATAPATH_WIDTH-1:0] R2out_out;
    output [`REGFILE_ADDR-1:0] WReg1_out;
	 
	 reg WRegEn_out;
    reg WMemEn_out;
    reg [`DATAPATH_WIDTH-1:0] R1out_out;
    reg [`DATAPATH_WIDTH-1:0] R2out_out;
    reg [`REGFILE_ADDR-1:0] WReg1_out;
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		WRegEn_out <= 'd0;
		WMemEn_out <= 'd0;
		R1out_out <= 'd0;
		R2out_out <= 'd0;
		WReg1_out <= 'd0;
	 end
	 else if (en) begin
		WRegEn_out <= WRegEn_in;
		WMemEn_out <= WMemEn_in;
		R1out_out <= R1out_in;
		R2out_out <= R2out_in;
		WReg1_out <= WReg1_in;
	 end
	end
endmodule
