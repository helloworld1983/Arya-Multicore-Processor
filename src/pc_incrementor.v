`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:09:25 02/23/2014 
// Design Name: 
// Module Name:    pc_incrementor 
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
`define MEM_ADDR_WIDTH 10
`define INST_MEM_START 0
`define DATA_MEM_START 512
`define NUM_COUNTERS 0
`define NUM_SOFTWARE_REGS 4
`define NUM_HARDWARE_REGS 3

module pc_incrementor(clk, en, reset, pc_out);
    input clk;
	 input en;
	 input reset;
    output [`MEM_ADDR_WIDTH-1:0] pc_out;
   
	 reg [`MEM_ADDR_WIDTH-1:0] pc_out;

always @ (posedge clk)
 begin : COUNTER 
   if (reset == 1'b1) begin
     pc_out <=   'd0;
   end
   else if (en == 1'b1) begin
     pc_out <=  pc_out + 1;
   end
end
	
endmodule
