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
	parameter		NUM_THREADS = 4,
	parameter		THREAD_BITS = 2
)(
	input clk,
	input reset,
    input firstword_in,
    input fifowrite_in,
	input enable_cpu_in,
	input [THREAD_BITS-1:0] thread_sel,
	input [THREAD_BITS-1:0] thread_sel_next,
	input  [NUM_THREADS-1:0] fifo_done,
    output [NUM_THREADS-1:0] firstword_out,
    output [NUM_THREADS-1:0] fifowrite_out,
	output [NUM_THREADS-1:0] enable_cpu_out,	
	output 	reg stop_smallfifo_read
    );

	parameter ZERO = 1'b0;
	parameter ONE = 1'b1;
	wire [NUM_THREADS-1:0]	fifowrite_out_next;
	//reg  [NUM_THREADS-1:0]	fifowrite_out_d;
	
reg [NUM_THREADS-1:0]	fifo_state, fifo_state_next;
reg [NUM_THREADS-1:0]	fifo_busy_next, fifo_busy;

assign firstword_out[0] = firstword_in && ~thread_sel[0] && ~thread_sel[1];
assign fifowrite_out_next[0] = fifowrite_in && ~thread_sel[0] && ~thread_sel[1];
assign enable_cpu_out[3] = enable_cpu_in && ~thread_sel[0] && ~thread_sel[1]; 

assign firstword_out[1] = firstword_in && thread_sel[0] && ~thread_sel[1];
assign fifowrite_out_next[1] = fifowrite_in && thread_sel[0] && ~thread_sel[1];
assign enable_cpu_out[0] = enable_cpu_in && thread_sel[0] && ~thread_sel[1];

assign firstword_out[2] = firstword_in && ~thread_sel[0] && thread_sel[1];
assign fifowrite_out_next[2] = fifowrite_in && ~thread_sel[0] && thread_sel[1];
assign enable_cpu_out[1] = enable_cpu_in && ~thread_sel[0] && thread_sel[1];

assign firstword_out[3] = firstword_in && thread_sel[0] && thread_sel[1];
assign fifowrite_out_next[3] = fifowrite_in && thread_sel[0] && thread_sel[1];
assign enable_cpu_out[2] = enable_cpu_in && thread_sel[0] && thread_sel[1];


always @(*) begin
case(thread_sel_next)
	'b00: stop_smallfifo_read = fifo_busy[0];
	'b01: stop_smallfifo_read = fifo_busy[1];
	'b10: stop_smallfifo_read = fifo_busy[2];
	'b11: stop_smallfifo_read = fifo_busy[3];

	default: stop_smallfifo_read = 0;
endcase
end // always @*

genvar i;
generate
for (i=0; i< NUM_THREADS; i=i+1) begin: fifowrite

always @(*) begin

	fifo_state_next[i] = fifo_state[i];
	fifo_busy_next[i] = fifo_busy[i];
	case (fifo_state[i]) 
		ZERO: begin
			fifo_busy_next[i] = 0;
			if (1 == enable_cpu_out[i]) begin
				fifo_state_next[i] = ONE;
				fifo_busy_next[i] = 1;
			end // if
		end // ZERO
		ONE: begin
			fifo_busy_next[i] = 1;
			if (1 == fifo_done[i]) begin
				fifo_state_next[i] = ZERO;
				fifo_busy_next[i] = 0;
			end // if
		end // ONE
	endcase
end

always @(posedge clk) begin
if (reset) begin
	fifo_busy[i] <= 0;
	fifo_state[i] <= ZERO;
end 
else begin
	fifo_busy[i] <= fifo_busy_next[i];
	fifo_state[i] <= fifo_state_next[i];
end
end // always 

assign fifowrite_out[i] = fifowrite_out_next[i];
end // for
endgenerate

endmodule
