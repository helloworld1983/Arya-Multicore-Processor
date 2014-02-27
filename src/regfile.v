`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:16:29 02/23/2014 
// Design Name: 
// Module Name:    regfile 
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

module regfile(
    input [`REGFILE_ADDR-1:0] r0addr,
    input [`REGFILE_ADDR-1:0] r1addr,
    input [`REGFILE_ADDR-1:0] waddr,
    input [`DATAPATH_WIDTH-1:0] wdata,
    output [`DATAPATH_WIDTH-1:0] r0data,
    output [`DATAPATH_WIDTH-1:0] r1data,
    input wena,
    input clk,
	 input reset
    );

reg [`DATAPATH_WIDTH-1:0] regfile [0:(2 ** `REGFILE_ADDR)-1 ];

assign r0data = regfile[r0addr];
assign r1data = regfile[r1addr];

always @(posedge clk) begin
  if (reset) begin
	 regfile[0] <= 'd0;
	 regfile[1] <= 'd0;
	 regfile[2] <= 'd0;
	 regfile[3] <= 'd0;
	 regfile[4] <= 'd0;
	 regfile[5] <= 'd0;
	 regfile[6] <= 'd0;
	 regfile[7] <= 'd0;
    end 
  else begin
	 if (wena) 
		regfile[waddr] <= wdata;
    end
  end
endmodule
