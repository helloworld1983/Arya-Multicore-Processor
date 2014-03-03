`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:46:34 02/27/2014 
// Design Name: 
// Module Name:    inst_decoder 
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


module inst_decoder
   #(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter INST_ADDR_WIDTH = 9)

	(input clk,
	 input reset,
	 input en,
    input [DATAPATH_WIDTH-1:0] inst_in,
	 input [INST_ADDR_WIDTH-1:0] pc_in,
    output reg [REGFILE_ADDR_WIDTH-1:0] R1_addr_out,
    output reg [REGFILE_ADDR_WIDTH-1:0] R2_addr_out,
	 output reg [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 output reg [INST_ADDR_WIDTH-1:0] pc_out);
//    output WRegEn_out;
//    output WMemEn_out;
//    output [REGFILE_ADDR_WIDTH-1:0] WReg1_out;
	 
always @ (posedge clk)
   begin
//		if (reset) begin
//    		r0addr_out <= 'd0;
//			r1addr_out <= 'd0;
//			WRegEn_out <= 'd0;
//			WMemEn_out <= 'd0;
//			WReg1_out <= 'd0;
//		end
//		else if (en) begin
//			WMemEn_out <= inst_in[15];
//			WRegEn_out <= inst_in[14];
//			r0addr_out <= inst_in[13:11];
//			r1addr_out <= inst_in[10:8];
//			WReg1_out <= inst_in[7:5];
//		end
	end
endmodule
