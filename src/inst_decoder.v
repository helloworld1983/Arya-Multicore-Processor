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
	 output reg [3:0] alu_ctrl_out);
	 
wire [5:0] opcode;
wire [5:0] alu_func;

assign opcode = inst_in[31:26];
assign alu_func = inst_in[5:0];
assign R1_addr_out 	= inst_in[25:21];
assign R2_addr_out 	= inst_in[20:16];
assign WR_addr_out 	= inst_in[15:11];
assign pc_out 			= pc_in;

always @(*)begin
	if (opcode == 6'b000000) begin
		case (alu_func)
		'b000000:	begin
						WR_en_out		= 0;
						alu_ctrl_out	= 0;
						end
		'b100000:	begin
						WR_en_out		= 1;
						alu_ctrl_out	= 0;
						end
		default: 	begin
						WR_en_out		= 0;
						alu_ctrl_out	= 0;
						end
		endcase
	end
end //always
endmodule
