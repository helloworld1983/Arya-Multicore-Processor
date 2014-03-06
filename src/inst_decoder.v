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

	(input [31:0] inst_in,
	
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
	 output WR_en_out,
	 output beq_out,
	 output bneq_out,
	 output imm_sel_out,
	 output mem_write_out,
	 output mem_reg_sel,
	 output reg halt_cpu_out
	 );
	 
wire [5:0] opcode;
wire [3:0] alu_func;

assign opcode 			= inst_in[31:26];
assign alu_func 		= inst_in[3:0]; // taking two bits from opcode and 4 bits from inst_in.
assign R1_addr_out 	= inst_in[25:21];
assign R2_addr_out 	= inst_in[20:16];
assign WR_addr_out 	= inst_in[15:11];

assign imm_out			= {48'd0,inst_in[15:0]};
assign branch_offset	= inst_in[8:0];

///////////////// DATAPATH control signals //////////////////////
assign 	WR_en_out		= opcode[5];
assign	beq_out			= opcode[4];
assign	bneq_out			= opcode[3];
assign	imm_sel_out		= opcode[2];
assign	mem_write_out 	= opcode[1];
assign	mem_reg_sel		= opcode[0];
///////////////// ALU control signals ////////////////////////////

always @(*) begin
	if (opcode == 'b111111) halt_cpu_out = 1;
	else halt_cpu_out	= 0;
		
	if (imm_sel_out) begin
		alu_ctrl_out	=	'd1; // ALU does add
	end else if (beq_out || bneq_out) begin
		alu_ctrl_out 	= 'd2; // ALU does sub
	end
	else begin
		alu_ctrl_out	=	alu_func;
	end
end //always

endmodule
