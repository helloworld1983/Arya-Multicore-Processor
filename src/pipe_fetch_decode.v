`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:48:12 02/23/2014 
// Design Name: 
// Module Name:    pipe_fetch_decode 
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

module pipe_fetch_decode(inst_in,clk,en,reset,inst_out);
    input [`INST_WIDTH-1:0] inst_in;
	 input clk;
	 input en;
	 input reset; 
    output [`INST_WIDTH-1:0] inst_out;
	 
	 reg [`INST_WIDTH-1:0] inst_out;
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		inst_out <= 'd0;
	 end
	 else if (en) begin
		inst_out <= inst_in;
	 end
  end
endmodule
