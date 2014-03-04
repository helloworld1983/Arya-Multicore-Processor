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

	(input [DATAPATH_WIDTH-1:0] inst_in,
	 input [INST_ADDR_WIDTH-1:0] pc_in,
    output [REGFILE_ADDR_WIDTH-1:0] R1_addr_out,
    output [REGFILE_ADDR_WIDTH-1:0] R2_addr_out,
	 output [REGFILE_ADDR_WIDTH-1:0] WR_addr_out,
	 output reg WR_en_out,
	 output [INST_ADDR_WIDTH-1:0] pc_out,
	 output reg [3:0] alu_ctrl_out,
	 output [DATAPATH_WIDTH-1:0]imm_out,
	 output imm_sel_out,
	 output shift_sel_out
	 );
	 
wire [5:0] opcode;
wire [5:0] alu_func;

assign opcode = inst_in[31:26];
assign alu_func = inst_in[5:0];
assign R1_addr_out 	= inst_in[25:21];
assign R2_addr_out 	= inst_in[20:16];
assign WR_addr_out 	= inst_in[15:11];
assign pc_out 			= pc_in;

assign imm_sel_out		= opcode[3];
assign shift_sel_out	= opcode[2];
assign imm_out			= {48'd0,inst_in[15:0]};

always @(*)begin
	if (opcode == 6'b000000) begin
		case (alu_func)
		'b000000:	begin // NOP
						WR_en_out		= 0;
						alu_ctrl_out	= 0;
						end
		'b100000:	begin // ADD R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 0;
						end
		'b100010:	begin // SUBTRACT R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 1;
						end
		'b100100:	begin // AND R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 2;
						end
		'b100101:	begin // OR R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 3;
						end
		'b100111:	begin // NOT R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 4;
						end
		'b100110:	begin // EXOR R3, R1, R2
						WR_en_out		= 1;
						alu_ctrl_out	= 5;
						end
		default: 	begin
						WR_en_out		= 0;
						alu_ctrl_out	= 0;
						end
		endcase
	end else if (opcode == 6'b001000) begin
		WR_en_out			= 1;
		alu_ctrl_out		= 0;
	end else if (opcode == 6'b001100) begin
		case (alu_func)
		'b100000: begin
			WR_en_out			= 1;
			alu_ctrl_out		= 6;
			end
		'b000001: begin
			WR_en_out 			= 1;
			alu_ctrl_out		= 7;
			end
		endcase
	end // else if
end //always
endmodule
