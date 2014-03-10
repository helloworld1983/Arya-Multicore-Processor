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


module pipe_mem_wb
	#(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5)

   (input [DATAPATH_WIDTH-1:0] mem_data_in,
    input [DATAPATH_WIDTH-1:0] accum_in,
    input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
	 input WR_en_in,
	 input mem_reg_sel_in,
    input clk,
    input en,
    input reset,
    output reg [DATAPATH_WIDTH-1:0] mem_data_out,
    output reg [DATAPATH_WIDTH-1:0] accum_out,
    output reg [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 output reg WR_en_out,
	 output reg mem_reg_sel_out
	 );
	 
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		mem_data_out 		<= 'd0;
		accum_out 			<= 'd0;
		WR_addr_out 		<= 'd0;	
		WR_en_out			<= 'd0;
		mem_reg_sel_out 	<= 'd0;
	 end
	 else if (en) begin
		mem_data_out 		<= mem_data_in;
		accum_out 			<= accum_in;
		WR_addr_out 		<= WR_addr_in;
		WR_en_out			<= WR_en_in;
		mem_reg_sel_out 	<= mem_reg_sel_in;
	 end
	end
endmodule
