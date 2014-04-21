`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:25:46 04/19/2014 
// Design Name: 
// Module Name:    accelerator_box 
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
module accelerator_box(
    input [63:0] header_in,
    input [31:0] compare_value,
    input start_in,
	input [2:0] thread_id_in,
	input clk,
	input reset,
    output reg action_done,
    output reg [3:0] action,
	output reg [2:0] thread_id_out
	);
    
	wire [31:0] ip_in;
	assign ip_in = header_in[47:16];
	
always@(posedge clk)begin
	if (reset) begin
		action_done <= 0;
		action <= 0;
		thread_id_out <= 0;
	end else begin
		action_done <= start_in;
		thread_id_out <= thread_id_in;
		if(ip_in == compare_value) begin
			action <= 4'b1111;
		end else begin
			action <= 4'b0000;
		end // else if
	end //  if not reset
end // always
endmodule
