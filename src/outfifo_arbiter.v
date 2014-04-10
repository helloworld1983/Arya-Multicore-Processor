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
	parameter			NUM_THREADS = 8
)(
    input clk,
    input reset,
    input [NUM_THREADS-1:0] thread_done,
    input [NUM_THREADS*64-1:0] 	df_out_data_in,
    input [NUM_THREADS*8-1:0] 	df_out_ctrl_in,
    input [NUM_THREADS-1:0]		df_out_wr_in,
    output reg [63:0] out_data_out,
    output reg [7:0] out_ctrl_out,
    output reg out_wr_out,
	
	output reg [NUM_THREADS-1:0]	fifo_start_read_next
    );
	 
	
	parameter		ZERO 		= 4'b0000;
	parameter		ONE 		= 4'b0001;
	parameter		TWO 		= 4'b0010;
	parameter		THREE 		= 4'b0011;
	parameter		FOUR		= 4'b0100;
	parameter		FIVE		= 4'b0101;
	parameter		SIX			= 4'b0110;
	parameter		SEVEN		= 4'b0111;
	parameter 		RESET 		= 4'b1111;
	
	reg [3:0] state, state_next;
	reg [NUM_THREADS-1:0]	fifo_start_read;
	reg [NUM_THREADS-1:0]	fifo_rdy;
	reg [NUM_THREADS-1:0]	fifo_rdy_reset;
	
	
		always @(*) begin
		fifo_start_read_next = fifo_start_read;
		state_next = state;
		
		case(state)
			RESET: begin
				out_data_out = df_out_data_in[63:0];
				out_ctrl_out = df_out_ctrl_in[7:0];
				out_wr_out	= df_out_wr_in[0];
				if (fifo_rdy[0]) begin
					state_next = ZERO;
					fifo_start_read_next[0] = 1;
					fifo_rdy_reset[0] = 1;
				end
			end
			ZERO: begin
				fifo_start_read_next[0] = 0;
				fifo_rdy_reset[1] = 0;
				out_data_out = df_out_data_in[63:0];
				out_ctrl_out = df_out_ctrl_in[7:0];
				out_wr_out	= df_out_wr_in[0];
				if (fifo_rdy[1] && ~df_out_wr_in[0]) begin
					state_next = ONE;
					fifo_start_read_next[1] = 1;
					fifo_rdy_reset[1] = 1;
				end
			end
			ONE: begin
				fifo_start_read_next[1] = 0;
				fifo_rdy_reset[2] = 0;
				out_data_out = df_out_data_in[127:64];
				out_ctrl_out = df_out_ctrl_in[15:8];
				out_wr_out	= df_out_wr_in[1];
				if (fifo_rdy[2] && ~df_out_wr_in[1]) begin
					state_next = TWO;
					fifo_start_read_next[2] = 1;
					fifo_rdy_reset[2] = 1;
				end
			
			end
			TWO: begin
				fifo_start_read_next[2] = 0;
				fifo_rdy_reset[3] = 0;
				out_data_out = df_out_data_in[191:128];
				out_ctrl_out = df_out_ctrl_in[23:16];
				out_wr_out	= df_out_wr_in[2];
				if (fifo_rdy[3] && ~df_out_wr_in[2]) begin
					state_next = THREE;
					fifo_start_read_next[3] = 1;
					fifo_rdy_reset[3] = 1;
				end
			
			end
			THREE: begin
				fifo_start_read_next[3] = 0;
				fifo_rdy_reset[4] = 0;
				out_data_out = df_out_data_in[255:192];
				out_ctrl_out = df_out_ctrl_in[31:24];
				out_wr_out	= df_out_wr_in[3];
				if (fifo_rdy[4] && ~df_out_wr_in[3]) begin
					state_next = FOUR;
					fifo_start_read_next[4] = 1;
					fifo_rdy_reset[4] = 1;
				end
			end
			FOUR: begin
				fifo_start_read_next[4] = 0;
				fifo_rdy_reset[5] = 0;
				out_data_out = df_out_data_in[319:256];
				out_ctrl_out = df_out_ctrl_in[39:32];
				out_wr_out	= df_out_wr_in[4];
				if (fifo_rdy[5] && ~df_out_wr_in[4]) begin
					state_next = FIVE;
					fifo_start_read_next[5] = 1;
					fifo_rdy_reset[5] = 1;
				end
			end
			FIVE: begin
				fifo_start_read_next[5] = 0;
				fifo_rdy_reset[6] = 0;
				out_data_out = df_out_data_in[383:320];
				out_ctrl_out = df_out_ctrl_in[47:40];
				out_wr_out	= df_out_wr_in[5];
				if (fifo_rdy[6] && ~df_out_wr_in[5]) begin
					state_next = SIX;
					fifo_start_read_next[6] = 1;
					fifo_rdy_reset[6] = 1;
				end
			end
			SIX: begin
				fifo_start_read_next[6] = 0;
				fifo_rdy_reset[7] = 0;
				out_data_out = df_out_data_in[447:384];
				out_ctrl_out = df_out_ctrl_in[55:48];
				out_wr_out	= df_out_wr_in[6];
				if (fifo_rdy[7] && ~df_out_wr_in[6]) begin
					state_next = SEVEN;
					fifo_start_read_next[7] = 1;
					fifo_rdy_reset[7] = 1;
				end
			end
			SEVEN: begin
				fifo_start_read_next[7] = 0;
				fifo_rdy_reset[0] = 0;
				out_data_out = df_out_data_in[511:448];
				out_ctrl_out = df_out_ctrl_in[63:56];
				out_wr_out	= df_out_wr_in[7];
				if (fifo_rdy[0] && ~df_out_wr_in[7]) begin
					state_next = ZERO;
					fifo_start_read_next[0] = 1;
					fifo_rdy_reset[0] = 1;
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
		end 
		else begin// if !reset	
			fifo_start_read <= fifo_start_read_next;
			state <= state_next;
		end // else if not reset
	end // always
	
	genvar i;
	generate
	for (i=0; i< NUM_THREADS; i=i+1) begin : sequential
	always @(posedge clk) begin
	if (~reset) begin
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
	
endmodule
