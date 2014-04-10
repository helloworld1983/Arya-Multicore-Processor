`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:13:56 04/07/2014 
// Design Name: 
// Module Name:    arbiter 
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
module infifo_arbiter # (
	parameter		NUM_THREADS = 8
)(
	input clk,
    input firstword_in,
    input fifowrite_in,
	input enable_cpu_in,
	input [2:0] thread_sel,
    output [NUM_THREADS-1:0] firstword_out,
    output [NUM_THREADS-1:0] fifowrite_out,
	output [NUM_THREADS-1:0] enable_cpu_out	
    );

	wire [NUM_THREADS-1:0]	fifowrite_out_next;
	reg  [NUM_THREADS-1:0]	fifowrite_out_d;
	
assign firstword_out[0] = firstword_in && ~thread_sel[0] && ~thread_sel[1] && ~thread_sel[2];
assign fifowrite_out_next[0] = fifowrite_in && ~thread_sel[0] && ~thread_sel[1] && ~thread_sel[2];
assign enable_cpu_out[7] = enable_cpu_in && ~thread_sel[0] && ~thread_sel[1] && ~thread_sel[2]; 

assign firstword_out[1] = firstword_in && thread_sel[0] && ~thread_sel[1] && ~thread_sel[2];
assign fifowrite_out_next[1] = fifowrite_in && thread_sel[0] && ~thread_sel[1] && ~thread_sel[2];
assign enable_cpu_out[0] = enable_cpu_in && thread_sel[0] && ~thread_sel[1] && ~thread_sel[2];

assign firstword_out[2] = firstword_in && ~thread_sel[0] && thread_sel[1] && ~thread_sel[2];
assign fifowrite_out_next[2] = fifowrite_in && ~thread_sel[0] && thread_sel[1] && ~thread_sel[2];
assign enable_cpu_out[1] = enable_cpu_in && ~thread_sel[0] && thread_sel[1] && ~thread_sel[2];

assign firstword_out[3] = firstword_in && thread_sel[0] && thread_sel[1] && ~thread_sel[2];
assign fifowrite_out_next[3] = fifowrite_in && thread_sel[0] && thread_sel[1] && ~thread_sel[2];
assign enable_cpu_out[2] = enable_cpu_in && thread_sel[0] && thread_sel[1] && ~thread_sel[2];

assign firstword_out[4] = firstword_in && ~thread_sel[0] && ~thread_sel[1] && thread_sel[2];
assign fifowrite_out_next[4] = fifowrite_in && ~thread_sel[0] && ~thread_sel[1] && thread_sel[2];
assign enable_cpu_out[3] = enable_cpu_in && ~thread_sel[0] && ~thread_sel[1] && thread_sel[2]; 

assign firstword_out[5] = firstword_in && thread_sel[0] && ~thread_sel[1] && thread_sel[2];
assign fifowrite_out_next[5] = fifowrite_in && thread_sel[0] && ~thread_sel[1] && thread_sel[2];
assign enable_cpu_out[4] = enable_cpu_in && thread_sel[0] && ~thread_sel[1] && thread_sel[2];

assign firstword_out[6] = firstword_in && ~thread_sel[0] && thread_sel[1] && thread_sel[2];
assign fifowrite_out_next[6] = fifowrite_in && ~thread_sel[0] && thread_sel[1] && thread_sel[2];
assign enable_cpu_out[5] = enable_cpu_in && ~thread_sel[0] && thread_sel[1] && thread_sel[2];

assign firstword_out[7] = firstword_in && thread_sel[0] && thread_sel[1] && thread_sel[2];
assign fifowrite_out_next[7] = fifowrite_in && thread_sel[0] && thread_sel[1] && thread_sel[2];
assign enable_cpu_out[6] = enable_cpu_in && thread_sel[0] && thread_sel[1] && thread_sel[2];



genvar i;
generate
for (i=0; i< NUM_THREADS; i=i+1) begin: fifowrite


	always @(posedge clk) begin
		fifowrite_out_d[i] <= fifowrite_out_next[i];
	end
	assign fifowrite_out[i] = fifowrite_out_d[i] || fifowrite_out_next[i];
end // for
endgenerate

endmodule
