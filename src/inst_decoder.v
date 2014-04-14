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
		parameter INST_WIDTH = 32,
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter INST_ADDR_WIDTH = 9,
	  parameter THREAD_BITS = 2,
	  parameter NUM_THREADS = 4)

	(input [INST_WIDTH-1:0] inst_in,
	input			reset,
	input	[THREAD_BITS-1:0]	thread_id,
	input clk,
	
	 //// OUTPUTS////
	 output [REGFILE_ADDR_WIDTH-1:0]	R1_addr_out,
	 output [REGFILE_ADDR_WIDTH-1:0]	R2_addr_out,
	 output [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 
	// immediate offsets
	 output [DATAPATH_WIDTH-1:0]	imm_out,
	 output [INST_ADDR_WIDTH-1:0]	branch_offset,

	// alu ctrl
	 output reg [3:0] 				alu_ctrl_out,	 
	 // control signals
	 output reg WR_en_out,
	 output reg beq_out,
	 output reg bneq_out,
	 output reg imm_sel_out,
	 output reg mem_write_out,
	 output reg mem_reg_sel,
	 output reg [NUM_THREADS-1:0]thread_done,
	 output reg [31:0] halt_counter
	 //output reg halt_cpu_out
	 );
	 
wire [5:0] opcode;
wire [3:0] alu_func;
wire [47:0]sign_extend;
 
assign opcode 			= inst_in[31:26];
assign alu_func 		= inst_in[3:0]; // taking two bits from opcode and 4 bits from inst_in.
assign R1_addr_out 	= inst_in[25:21];
assign R2_addr_out 	= inst_in[20:16];
assign WR_addr_out 	= inst_in[15:11];

assign sign_extend 		= $signed(inst_in[15]); 
assign imm_out			= {sign_extend,inst_in[15:0]};
assign branch_offset	= inst_in[8:0];

/* Causing spurious branches
///////////////// DATAPATH control signals //////////////////////
assign 	WR_en_out		= opcode[5];
assign	beq_out			= opcode[4];
assign	bneq_out			= opcode[3];
assign	imm_sel_out		= opcode[2];
assign	mem_write_out 	= opcode[1];
assign	mem_reg_sel		= opcode[0];
///////////////// ALU control signals ////////////////////////////
*/

wire halt;
assign halt = (opcode == 'b111111) ? 1 : 0;
 
always @(*) begin
	if (reset) begin
		WR_en_out		= 0;
		beq_out			= 0;
		bneq_out		= 0;
		imm_sel_out		= 0;
		mem_write_out 	= 0;
		mem_reg_sel		= 0;
		alu_ctrl_out = 0;
	end
	else begin

		if (~halt) begin
			WR_en_out		= opcode[5];
			beq_out			= opcode[4];
			bneq_out		= opcode[3];
			imm_sel_out		= opcode[2];
			mem_write_out 	= opcode[1];
			mem_reg_sel		= opcode[0];
		end else begin
			WR_en_out		= 0;
			beq_out			= 0;
			bneq_out		= 0;
			imm_sel_out		= 0;
			mem_write_out 	= 0;
			mem_reg_sel		= 0;
		end // else if not halt
	end // if not reset


		if (imm_sel_out) begin 
			alu_ctrl_out	=	'd1; // ALU does add
		end else if (beq_out || bneq_out) begin
			alu_ctrl_out 	= 'd2; // ALU does sub
		end
		else begin
		alu_ctrl_out	=	alu_func;
		end
///////////////// DATAPATH control signals //////////////////////
///////////////// ALU control signals ////////////////////////////

end //always

always @(posedge clk) begin
	if (reset) begin
		thread_done <= 0;
		halt_counter <= 0;
	end
	else if (halt) begin
		halt_counter <= halt_counter + 1;
	case (thread_id)
		'b00: begin
			thread_done[0] <= 1;
		end
		'b01: begin
			thread_done[1] <= 1;
		end
		'b10: begin
			thread_done[2] <= 1;
		end
		'b11: begin
			thread_done[3] <= 1;
		end
	endcase
	end
	else begin
	thread_done <= 0;
	end
end
endmodule
