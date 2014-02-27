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

`define INST_WIDTH 32
`define REGFILE_ADDR 3
`define DATAPATH_WIDTH 64
`define INST_MEM_ADDR 9
`define DATA_MEM_ADDR 9
`define INST_MEM_START 0
`define DATA_MEM_START 512

module inst_decoder(clk, reset, en, inst_in, r0addr_out, r1addr_out, WRegEn_out, WMemEn_out, WReg1_out);
	 input clk;
	 input reset;
	 input en;
    input [`INST_WIDTH-1:0] inst_in;
    output [`REGFILE_ADDR-1:0] r0addr_out;
    output [`REGFILE_ADDR-1:0] r1addr_out;
    output WRegEn_out;
    output WMemEn_out;
    output [`REGFILE_ADDR-1:0] WReg1_out;
    
	 reg [`REGFILE_ADDR-1:0] r0addr_out;
    reg [`REGFILE_ADDR-1:0] r1addr_out;
    reg WRegEn_out;
    reg WMemEn_out;
    reg [`REGFILE_ADDR-1:0] WReg1_out;
	 
always @ (posedge clk)
   begin
		if (reset) begin
    		r0addr_out <= 'd0;
			r1addr_out <= 'd0;
			WRegEn_out <= 'd0;
			WMemEn_out <= 'd0;
			WReg1_out <= 'd0;
		end
		else if (en) begin
			WMemEn_out <= inst_in[15];
			WRegEn_out <= inst_in[14];
			r0addr_out <= inst_in[13:11];
			r1addr_out <= inst_in[10:8];
			WReg1_out <= inst_in[7:5];
		end
	end
endmodule
