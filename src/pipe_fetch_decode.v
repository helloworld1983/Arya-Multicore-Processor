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


module pipe_fetch_decode
   #(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter INST_ADDR_WIDTH = 9,
	  parameter THREAD_BITS = 2)

   (input [31:0] inst_in,
	 input [THREAD_BITS-1:0] thread_id_in,
	 input clk,
	 input en,
	 input reset, 
	 input [INST_ADDR_WIDTH-1:0] pc_in,
    output reg [31:0] inst_out,
	 output reg [INST_ADDR_WIDTH-1:0] pc_out,
	 output reg [THREAD_BITS-1:0]	thread_id_out);
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		inst_out <= 'd0;
		pc_out <= 'd0;
		thread_id_out <= 'd0;
	 end
	 else if (en) begin
		inst_out <= inst_in;
		pc_out <= pc_in;
		thread_id_out <= thread_id_in;
	 end
  end
endmodule
