`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:07 04/07/2014 
// Design Name: 
// Module Name:    dummy_arya 
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
module dummy_arya#(
	parameter 	REGFILE_ADDR_WIDTH 	= 5,
	parameter 	DATAPATH_WIDTH	 	= 64,
	parameter 	MEM_ADDR_WIDTH		= 8,
	parameter 	INST_ADDR_WIDTH		= 8,
	parameter	NUM_THREADS			= 8
	)	(
	input 		clk,
   input 		reset,
	input 		en,
	input			[NUM_THREADS-1:0]			start_thread,	
	
	output 		reg [NUM_THREADS-1:0]	thread_busy,
	output 		reg [NUM_THREADS-1:0]	thread_done
    );

	parameter 		START = 1'b0;
	parameter		BUSY  = 1'b1;
	
	reg		[NUM_THREADS-1:0]	state ;
	reg		[NUM_THREADS-1:0]	state_next;
	reg 		[NUM_THREADS*5-1:0]	count ;
	reg 		[NUM_THREADS-1:0] counter_reset;
	reg		[NUM_THREADS-1:0] thread_busy_next;
	
	genvar i;
	generate
	for (i=0; i<NUM_THREADS ;i=i+1) begin: combinational
	always @(*) begin

	state_next[i] = state[i];
	thread_busy_next[i] = thread_busy[i];
		case (state[i])
			START: begin
			thread_done[i] = 0;
			thread_busy_next[i] = 0;
			counter_reset[i] = 1;
			if (start_thread[i]) begin
				counter_reset[i] = 0;
				state_next[i] = BUSY;
				thread_busy_next[i] = 1;
			end // if (start_thread_0)
			end // START
			BUSY: begin
			if (count[5*(i+1)-1:5*i] == 5'b11111) begin
				counter_reset[i] = 1;
				state_next[i] = START;
				thread_busy_next[i] = 0;
				thread_done[i] = 1;
			end // if (count == 10) 
			end // BUSY
		endcase
	end // always
	end// for
	endgenerate

	
	generate
	for (i=0; i<NUM_THREADS ;i=i+1) begin: sequential
	always @(posedge clk) begin
		if(reset) begin
			state[i] <= START;
			count[i*5] 		<= 0;
			count[i*5+1] 	<= 0;
			count[i*5+2] 	<= 0;
			count[i*5+3] 	<= 0;
			count[i*5+4] 	<= 0;
			thread_busy[i] <= 0;
		end // if (reset)
		else begin
			state[i] <= state_next[i];	
			thread_busy[i] <= thread_busy_next[i];
			if (counter_reset[i]) begin
				count[5*(i+1)-1:5*i] <= 5'b00000;
			end // if
			else begin
				count[5*(i+1)-1:5*i] <= count[5*(i+1)-1:5*i] + 1;
			end // else
		end // else if not reset
	end // always
	end //for
	endgenerate
endmodule
