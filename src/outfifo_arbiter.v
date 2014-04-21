`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:36:13 04/08/2014 
// Design Name: 
// Module Name:    output_arbiter 
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
module outfifo_arbiter # (
	parameter			NUM_THREADS = 4,
	parameter			DATAPATH_WIDTH = 64,
	parameter			CTRL_WIDTH = 8,
	parameter			THREAD_BITS = 2
)(
    input clk,
    input reset,
    input [NUM_THREADS-1:0] thread_done,
    input [NUM_THREADS*DATAPATH_WIDTH-1:0] 	df_out_data_in,
    input [NUM_THREADS*CTRL_WIDTH-1:0] 	df_out_ctrl_in,
    input [NUM_THREADS-1:0]		df_out_wr_in,
    input [NUM_THREADS-1:0]		df_out_wr_early_in,
	input out_rdy,
    output reg [DATAPATH_WIDTH-1:0] out_data_out,
    output reg [CTRL_WIDTH-1:0] out_ctrl_out,
    output reg out_wr_out,
	output reg [NUM_THREADS-1:0]  fifo_read_done,
	
	output reg [NUM_THREADS-1:0]	fifo_start_read_next
    );

	parameter		ZERO 		= 0;
	parameter		ONE 		= 1;
	parameter		TWO 		= 2;
	parameter		THREE 		= 3;
	parameter 		RESET		= 6;
	
	reg [1:0] delay_counter;
	reg delayed_enough;
	reg [THREAD_BITS:0] state, state_next;
	reg [NUM_THREADS-1:0]	fifo_start_read;
	reg [NUM_THREADS-1:0]	fifo_rdy;
	reg [NUM_THREADS-1:0]	fifo_rdy_reset;
	reg [NUM_THREADS-1:0]	fifo_read_done_next;
	reg delay_reset_next, delay_reset;
	reg out_rdy_delayed;
	wire out_rdy_d;
	assign out_rdy_d = out_rdy_delayed || out_rdy;
	
	always @(*) begin
		fifo_start_read_next = fifo_start_read;
		fifo_read_done_next = fifo_read_done;
		delay_reset_next = delay_reset;
		state_next = state;
		
		case(state)
			RESET: begin
				delay_reset_next = 0;
				fifo_read_done_next[0] = 0;
				out_data_out = df_out_data_in[63:0];
				out_ctrl_out = df_out_ctrl_in[7:0];
				out_wr_out	= df_out_wr_in[0];
				if (fifo_rdy[0]) begin
					state_next = ZERO;
					fifo_start_read_next[0] = 1;
					fifo_rdy_reset[0] = 1;
					delay_reset_next = 1;
				end
			end
			ZERO: begin
				// to avoid glitch
				fifo_start_read_next[1] = 0;
				fifo_rdy_reset[1] = 0;
				fifo_read_done_next[0] = 0;  
				delay_reset_next = 0;
				
				delay_reset_next = 0;
				fifo_read_done_next[3] = 0;
				fifo_start_read_next[0] = 0;
				fifo_rdy_reset[0] = 0;
				out_data_out = df_out_data_in[63:0];
				out_ctrl_out = df_out_ctrl_in[7:0];
				out_wr_out	= df_out_wr_in[0];
				if (delayed_enough) begin
					if (fifo_rdy[1] && ~df_out_wr_early_in[0] && out_rdy_d) begin
						state_next = ONE;
						fifo_start_read_next[1] = 1;
						fifo_rdy_reset[1] = 1;
						fifo_read_done_next[0] = 1;  
						delay_reset_next = 1;
					end
				end
			end
			ONE: begin
				// to avoid glitch
				fifo_start_read_next[2] = 0;
				fifo_rdy_reset[2] = 0;
				fifo_read_done_next[1] = 0;  
				delay_reset_next = 0;
				
				delay_reset_next = 0;
				fifo_read_done_next[0] = 0;
				fifo_start_read_next[1] = 0;
				fifo_rdy_reset[1] = 0;
				out_data_out = df_out_data_in[127:64];
				out_ctrl_out = df_out_ctrl_in[15:8];
				out_wr_out	= df_out_wr_in[1];
				if (delayed_enough) begin
					if (fifo_rdy[2] && ~df_out_wr_early_in[1] && out_rdy_d) begin
						state_next = TWO;
						fifo_start_read_next[2] = 1;
						fifo_rdy_reset[2] = 1;
						fifo_read_done_next[1] = 1;
						delay_reset_next = 1;
					end
				end
			
			end
			TWO: begin
				// to avoid glitch
				fifo_start_read_next[3] = 0;
				fifo_rdy_reset[3] = 0;
				fifo_read_done_next[2] = 0;  
				delay_reset_next = 0;
				delay_reset_next = 0;
				fifo_read_done_next[1] = 0;
				fifo_start_read_next[2] = 0;
				fifo_rdy_reset[2] = 0;
				out_data_out = df_out_data_in[191:128];
				out_ctrl_out = df_out_ctrl_in[23:16];
				out_wr_out	= df_out_wr_in[2];
				if (delayed_enough) begin
					if (fifo_rdy[3] && ~df_out_wr_early_in[2] && out_rdy_d) begin
						state_next = THREE;
						fifo_start_read_next[3] = 1;
						fifo_rdy_reset[3] = 1;
						fifo_read_done_next[2] = 1;
						delay_reset_next = 1;
					end
				end
			end
			THREE: begin
				// to avoid glitch
				fifo_start_read_next[0] = 0;
				fifo_rdy_reset[0] = 0;
				fifo_read_done_next[3] = 0;  
				delay_reset_next = 0;
				delay_reset_next = 0;
				fifo_read_done_next[2] = 0;
				fifo_start_read_next[3] = 0;
				fifo_rdy_reset[3] = 0;
				out_data_out = df_out_data_in[255:192];
				out_ctrl_out = df_out_ctrl_in[31:24];
				out_wr_out	= df_out_wr_in[3];
				if (delayed_enough) begin
					if (fifo_rdy[0] && ~df_out_wr_early_in[3] && out_rdy_d) begin
						state_next = ZERO;
						fifo_start_read_next[0] = 1;
						fifo_rdy_reset[0] = 1;
						fifo_read_done_next[3] = 1;
						delay_reset_next = 1;
					end
				end
			end
			default: begin
				out_data_out = df_out_data_in[63:0];
				out_ctrl_out = df_out_ctrl_in[7:0];
				out_wr_out	= df_out_wr_in[0];
				fifo_rdy_reset = 0;
			end

		endcase
	end // always
	
	always @(posedge clk) begin
		if (reset) begin
			state <= RESET;
			fifo_start_read <=0;
		
			fifo_read_done <= 0;
		end 
		else begin// if !reset	
			fifo_start_read <= fifo_start_read_next;
			fifo_read_done <= fifo_read_done_next;
			state <= state_next;
		end // else if not reset
	end // always
	
	genvar i;
	generate
	for (i=0; i< NUM_THREADS; i=i+1) begin : sequential
	always @(posedge clk) begin
	if (reset) begin
		fifo_rdy[i] <= 0;
	end
	else begin
		if (fifo_rdy_reset[i]) begin
				fifo_rdy[i] <= 0;
			end // if (fifo_3_rdy_reset)
		else begin
			if (thread_done[i]) begin
				fifo_rdy[i] <= 1;
			end // if (thread_3_done)
		end // else	
		end // if ~reset
	end // always 
	end// for
	endgenerate// endgenerate
	
	
	always @(posedge clk) begin
	
	if (reset) begin
		delay_counter <= 0;
		out_rdy_delayed <= 0;
	end else begin
		out_rdy_delayed <= out_rdy;
		delay_reset <= delay_reset_next;
			if (delay_reset_next) begin
				delay_counter 	<= 0;
				delayed_enough <= 0;
			end else begin
				if (delay_counter >= 2) begin
					delayed_enough <= 1;
				end else begin
					delay_counter <= delay_counter + 1;
					delayed_enough <= 0;
				end // else
			end // else if (~delay_reset_next)
		end // else if (~reset)
	end // always
endmodule
