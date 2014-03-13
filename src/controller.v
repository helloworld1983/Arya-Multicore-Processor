`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:22 03/13/2014 
// Design Name: 
// Module Name:    controller 
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
module controller(
    input in_wr,
    input [7:0] in_ctrl,
    input [63:0] in_data,
    input out_rdy,
    input proc_done,
    input clk,
	 input reset,
    output reg out_wr,
    output reg [7:0] out_ctrl,
    output reg [63:0] out_data,
    output reg [7:0] out_wr_addr,
	 output reg [7:0] out_rd_addr,
    output reg mem_wen,
    output reg in_rdy,
    output reg packet_rdy,
    output reg [7:0] packet_start_addr,
    output reg [7:0] packet_end_addr
    );


	reg [1:0]state;
  // local parameter
   parameter                     START 	= 2'b00;
   parameter                     PACKET 	= 2'b01;
   parameter                     PROCESS 	= 2'b10;
   parameter                    	READ	 	= 2'b11;

always @(posedge clk) begin

if (reset) begin
	out_wr 		<= 0;
	out_ctrl 	<= 0;
	out_data 	<= 0;
	out_wr_addr <=0;
	out_rd_addr	<=0;
	mem_wen		<=0;
	in_rdy		<=0;
	packet_rdy	<=0;
	packet_start_addr	<=0;
	packet_end_addr	<=0;
	state 		<=0;
end // if (reset) 
else begin
	case(state)
		START: begin
		if (in_wr && in_ctrl) begin
			state <= PACKET;
			out_wr_addr <= out_wr_addr + 1;
			packet_start_addr <= out_wr_addr + 1;
			out_data <= in_data;
			out_ctrl <= in_ctrl;
			mem_wen <= 1;
		end
		end
		
		PACKET: begin
			if (in_wr) begin
				out_wr_addr <= out_wr_addr + 1;
				out_ctrl <= in_ctrl;
				out_data <= in_data;
			end
			if (in_wr && in_ctrl)begin
				packet_end_addr	<= out_wr_addr + 1;
				packet_rdy	<= 1;
				in_rdy <= 0;
				state <= PROCESS;
			end
		end
		
		PROCESS: begin
			mem_wen <= 0;
			packet_rdy <= 0;
			if (proc_done) begin
				state <= READ;
			end
		end
			
		READ: begin
		if (out_rdy) begin
			if (~(out_rd_addr == packet_end_addr)) begin
				out_rd_addr <= out_rd_addr + 1;
				out_wr <= 1;
			end else begin
				state <= START;
				in_rdy <= 1;
				out_wr <= 0;
			end // else
		end// if (out_rdy)
		end // READ
	endcase	
	end// else if (!reset)
end
endmodule
