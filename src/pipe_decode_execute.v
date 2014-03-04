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


module pipe_decode_execute
   #(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter INST_ADDR_WIDTH = 9)

	(input [INST_ADDR_WIDTH-1:0] pc_in,
    input [DATAPATH_WIDTH-1:0] R1_data_in,
    input [DATAPATH_WIDTH-1:0] R2_data_in,
    input [REGFILE_ADDR_WIDTH-1:0] R1_addr_in,
	 input [REGFILE_ADDR_WIDTH-1:0] R2_addr_in,
	 input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
	 input [3:0] alu_ctrl_in,
	 input WR_en_in,
    input clk,
    input en,
	 input reset,
	 
    output reg [INST_ADDR_WIDTH-1:0] pc_out,
    output reg [DATAPATH_WIDTH-1:0] R1_data_out,
    output reg [DATAPATH_WIDTH-1:0] R2_data_out,
    output reg [REGFILE_ADDR_WIDTH-1:0] R1_addr_out,
	 output reg [REGFILE_ADDR_WIDTH-1:0] R2_addr_out,
	 output reg [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 output reg WR_en_out,
	 output reg [3:0] alu_ctrl_out
	 );	
	 
	
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		pc_out <= 'd0;
		R1_data_out <= 'd0;
		R2_data_out <= 'd0;
		R1_addr_out <= 'd0;
		R2_addr_out <= 'd0;
		WR_addr_out <= 'd0;
		WR_en_out	<= 'd0;
		alu_ctrl_out<= 'd0;
	 end
	 else if (en) begin
		pc_out <= pc_in;
		R1_data_out <= R1_data_in;
		R2_data_out <= R2_data_in;
		R1_addr_out <= R1_addr_in;
		R2_addr_out <= R2_addr_in;
		WR_addr_out <= WR_addr_in;
		WR_en_out	<= WR_en_in;
		alu_ctrl_out<= alu_ctrl_in;
		
	 end
	end
endmodule
