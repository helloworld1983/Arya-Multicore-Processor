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
	parameter	NUM_THREADS			= 8,
	parameter	NUM_THREADS_PER_CORE	= 4
	)	(
	input 		clk,
	input 		reset,
	input 		en,
	input			[NUM_THREADS_PER_CORE-1:0]			start_thread,	
	input			[NUM_THREADS_PER_CORE-1:0]			debug_commands,
	input			debug_on,
	
	output 		reg [NUM_THREADS_PER_CORE-1:0]	thread_busy,
	output 		reg [NUM_THREADS_PER_CORE-1:0]	thread_done
    );

	parameter 		START = 1'b0;
	parameter		BUSY  = 1'b1;
	
	reg		[NUM_THREADS_PER_CORE-1:0]	state ;
	reg		[NUM_THREADS_PER_CORE-1:0]	state_next;
	reg 	[NUM_THREADS_PER_CORE*10-1:0]	count ;
	reg 	[NUM_THREADS_PER_CORE-1:0] counter_reset;
	reg		[NUM_THREADS_PER_CORE-1:0] thread_busy_next;

	reg		[NUM_THREADS_PER_CORE-1:0]	debug_state ;
	reg		[NUM_THREADS_PER_CORE-1:0]	debug_state_next;
	wire	[NUM_THREADS_PER_CORE-1:0]	cpu_done_trigger;
	reg		[NUM_THREADS_PER_CORE-1:0]	manual_trigger;
	reg		[NUM_THREADS_PER_CORE-1:0]	manual_trigger_next;
	reg		[NUM_THREADS_PER_CORE-1:0]	counter_trigger;
	
	
	
	genvar i;
	generate
	for (i=0; i<NUM_THREADS_PER_CORE ;i=i+1) begin: combinational

	assign cpu_done_trigger[i] = debug_on ? manual_trigger[i] : counter_trigger[i];

	always @(*) begin

	state_next[i] = state[i];
	thread_busy_next[i] = thread_busy[i];
	
	// state machine below for CPU operation
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
			if (cpu_done_trigger[i]) begin
				counter_reset[i] = 1;
				state_next[i] = START;
				thread_busy_next[i] = 0;
				thread_done[i] = 1;
			end // if (count == 10) 
			end // BUSY
		endcase
		
		// state machine below to get the manual trigger generated
		debug_state_next[i] = debug_state[i];
		manual_trigger_next[i] = manual_trigger[i];
		
		case (debug_state[i])
			START:begin
				manual_trigger_next[i] = 0;
				if (1 == debug_commands[i]) begin
					debug_state_next[i] = BUSY;
					manual_trigger_next[i] = 1;
				end // if 
			end // START
			BUSY: begin
				if (0 == debug_commands[i]) begin
					debug_state_next[i] = START;
					manual_trigger_next[i] = 0;
				end // if
				else begin
					manual_trigger_next[i] = 0;
				end // else
			end // BUSY
		endcase
	end // always
	end// for
	endgenerate

	
	generate
	for (i=0; i<NUM_THREADS_PER_CORE ;i=i+1) begin: sequential
	always @(posedge clk) begin
		if(reset) begin
			state[i] <= START;
			debug_state[i] <= START;
			count[i*10] 	<= 0;
			count[i*10+1] 	<= 0;
			count[i*10+2] 	<= 0;
			count[i*10+3] 	<= 0;
			count[i*10+4] 	<= 0;
			count[i*10+5] 	<= 0;
			count[i*10+6] 	<= 0;
			count[i*10+7] 	<= 0;
			count[i*10+8] 	<= 0;
			count[i*10+9] 	<= 0;
			thread_busy[i] <= 0;
			manual_trigger[i] <= 0;
		end // if (reset)
		else begin
			state[i] <= state_next[i];	
			thread_busy[i] <= thread_busy_next[i];
			if (counter_reset[i]) begin
				count[10*(i+1)-1:10*i] <= 10'b0000000000;
			end // if
			else begin
				count[10*(i+1)-1:10*i] <= count[10*(i+1)-1:10*i] + 1;
			end // else
			if (count[10*(i+1)-1:10*i] == 'b111111) begin
				counter_trigger[i] = 1;
			end else begin
				counter_trigger[i] = 0;
			end
			
			debug_state[i] <= debug_state_next[i];
			manual_trigger[i] <= manual_trigger_next[i]; 
		end // else if not reset
		
		
	end // always
	end //for
	endgenerate
endmodule
