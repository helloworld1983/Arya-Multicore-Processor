`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:59:20 02/23/2014 
// Design Name: 
// Module Name:    pipe_execute_mem 
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


module pipe_execute_mem
   #(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter INST_ADDR_WIDTH = 9)

   (input [INST_ADDR_WIDTH-1:0] pc_in,
    input [DATAPATH_WIDTH-1:0] accum_in,
    input [DATAPATH_WIDTH-1:0] store_data_in,
    input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
    input clk,
    input en,
	 input reset,
    output reg [INST_ADDR_WIDTH-1:0] pc_out,
    output reg [DATAPATH_WIDTH-1:0] accum_out,
    output reg [DATAPATH_WIDTH-1:0] store_data_out,
    output reg [REGFILE_ADDR_WIDTH-1:0] WR_addr_out);
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		pc_out <= 'd0;
		accum_out <= 'd0;
		store_data_out <= 'd0;
		WR_addr_out <= 'd0;
	 end
	 else if (en) begin
		pc_out <= pc_in;
		accum_out <= accum_in;
		store_data_out <= store_data_in;
		WR_addr_out <= WR_addr_in;
	 end
	end	 
endmodule



