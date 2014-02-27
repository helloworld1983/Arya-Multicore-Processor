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
module regfile(
    input [2:0] r0addr,
    input [2:0] r1addr,
    input [2:0] waddr,
    input [63:0] wdata,
    output [63:0] r0data,
    output [63:0] r1data,
    input wena,
    input clk,
	 input reset
    );

reg [63:0] regfile [0:7];

assign r0data = regfile[r0addr];
assign r1data = regfile[r1addr];

always @(posedge clk) begin
  if (reset) begin
	 regfile[0] <= 0'h00000000;
	 regfile[1] <= 0'h00000000;
	 regfile[2] <= 0'h00000000;
	 regfile[3] <= 0'h00000000;
	 regfile[4] <= 0'h00000000;
	 regfile[5] <= 0'h00000000;
	 regfile[6] <= 0'h00000000;
	 regfile[7] <= 0'h00000000;
    end 
  else begin
	 if (wena) 
		regfile[waddr] <= wdata;
    end
  end
endmodule
