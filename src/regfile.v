`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:16:29 02/23/2014 
// Design Name: 
// Module Name:    regfile 
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


module regfile
   #(parameter DATAPATH_WIDTH = 64,
	  parameter REGFILE_ADDR_WIDTH = 5)

   (input [REGFILE_ADDR_WIDTH-1:0] R1_addr_in,
    input [REGFILE_ADDR_WIDTH-1:0] R2_addr_in,
    input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
    input [DATAPATH_WIDTH-1:0] WR_data_in,
    output [DATAPATH_WIDTH-1:0] R1_data_out,
    output [DATAPATH_WIDTH-1:0] R2_data_out,
    input wena,
    input clk,
	 input reset
    );

reg [DATAPATH_WIDTH-1:0] regfile [0:(2 ** REGFILE_ADDR_WIDTH)-1 ];

//initial regfile[0] = 64'h0; 
//initial regfile[1] = 64'h0;
//initial regfile[2] = 64'h0;
//initial regfile[3] = 64'h0;
//initial regfile[4] = 64'h0;
//initial regfile[5] = 64'h0;
//initial regfile[6] = 64'h0;
//initial regfile[7] = 64'h0;



assign	R1_data_out = regfile[R1_addr_in];
assign	R2_data_out = regfile[R2_addr_in];
//wire [`DATAPATH_WIDTH-1:0] regfile_next [0:(2 ** `REGFILE_ADDR)-1 ];

integer i;
always @(posedge clk) begin
	if (reset) begin
			for(i = 0; i < (2 ** REGFILE_ADDR_WIDTH); i = i + 1) begin
				regfile[i] <= 'd0; //  HACK - MAKE THIS ZERO IF NOT!!!!!
			end
   end 
  else begin
	 if (wena) 
		regfile[WR_addr_in] <= WR_data_in;
    end
  end
  
endmodule
