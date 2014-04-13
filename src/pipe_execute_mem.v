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
	  parameter INST_ADDR_WIDTH = 9,
	  parameter THREAD_BITS = 2)

   (input [INST_ADDR_WIDTH-1:0] branch_target_in,
    input [DATAPATH_WIDTH-1:0] accum_in,
    input [DATAPATH_WIDTH-1:0] store_data_in,
    input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
	 input WR_en_in,
	 input beq_in,
	 input bneq_in,
	 input mem_write_in,
	 input zero_in,
	 input mem_reg_sel_in,
	 input [THREAD_BITS-1:0] thread_id_in,
    input clk,
    input en,
	 input reset,
	 
    output reg [INST_ADDR_WIDTH-1:0] branch_target_out,
    output reg [DATAPATH_WIDTH-1:0] accum_out,
    output reg [DATAPATH_WIDTH-1:0] store_data_out,
    output reg [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 output reg [THREAD_BITS-1:0]	thread_id_out,
	 output reg WR_en_out,

	 output reg beq_out,
	 output reg bneq_out,
	 output reg mem_write_out,
	 output reg zero_out,

	 output reg mem_reg_sel_out
	 );
	 
always @ (posedge clk) 
  begin
	 if (reset) begin
		branch_target_out <= 'd0;
		accum_out 		<= 'd0;
		store_data_out <= 'd0;
		WR_addr_out 	<= 'd0;
		WR_en_out		<= 'd0;
		beq_out			<= 'd0;
		bneq_out			<= 'd0;
		mem_write_out	<= 'd0;
		zero_out			<= 'd0;
		mem_reg_sel_out <= 'd0;
		thread_id_out <= 'd0;
	 end
	 else if (en) begin
		branch_target_out 	<= branch_target_in;
		accum_out 		<= accum_in;
		store_data_out <= store_data_in;
		WR_addr_out 	<= WR_addr_in;
		WR_en_out		<= WR_en_in;
		beq_out			<= beq_in;
		bneq_out			<= bneq_in;
		mem_write_out	<= mem_write_in;
		zero_out			<= zero_in;
		mem_reg_sel_out<= mem_reg_sel_in;
		thread_id_out <= thread_id_in;
	 end
	end	 
endmodule



