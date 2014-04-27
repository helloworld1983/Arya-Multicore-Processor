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
	  parameter REGFILE_ADDR_WIDTH = 5,
	  parameter NUM_ACTIONS = 8,
	  parameter THREAD_BITS = 2
	  )

   (input [REGFILE_ADDR_WIDTH-1:0] R1_addr_in,
    input [REGFILE_ADDR_WIDTH-1:0] R2_addr_in,
    input [REGFILE_ADDR_WIDTH-1:0] WR_addr_in,
    input [DATAPATH_WIDTH-1:0] WR_data_in,
    output [DATAPATH_WIDTH-1:0] R1_data_out,
    output [DATAPATH_WIDTH-1:0] R2_data_out,
    input wena,
    input clk,
	input [NUM_ACTIONS-1:0]	action_data_in,
	input action_wen,
	input [THREAD_BITS-1:0] action_thread_id_in,
	 input reset
    );

reg [DATAPATH_WIDTH-1:0] regfile [0:(2 ** REGFILE_ADDR_WIDTH)-1 ];

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
	 if (wena) begin 
		regfile[WR_addr_in] <= WR_data_in;
    end else if (action_wen) begin
		case (action_thread_id_in)
			0: begin
				regfile[7] <= {8'h00,action_data_in,48'h00000000000000};
				regfile[6] <= 64'hFF00FFFFFFFFFFFF;
			end
			1: begin
				regfile[15] <= {8'h00,action_data_in,48'h00000000000000};
				regfile[14] <= 64'hFF00FFFFFFFFFFFF;
			end
			default: begin
				regfile[7] <= 0;
				regfile[15] <= 0;
				end // defauly
		endcase 
	end // else if action wen
  end // else if not reset
end // always
  
endmodule
