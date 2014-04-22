`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:41:23 04/09/2014 
// Design Name: 
// Module Name:    counter 
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
module counter(
	 input clk,
	 input reset,
    input [3:0] write_addr_in,
    input [3:0] count_rd_addr_in,
    input match_in,
	 input read_counter,
    output [31:0] count_out
    );
	
	wire [31:0] count_out_next;
	reg [3:0] write_addr_in_next;
	reg wen_next;
	wire counter_wen;
	wire [3:0] rd_addr_in_next;

counter_dram dram_ctr (
    .clka(clk), 
    .dina(count_out_next), 
    .addra(write_addr_in_next), 
    .wea(counter_wen),  
    .clkb(clk), 
    .addrb(rd_addr_in_next), 
    .doutb(count_out)
    );

assign rd_addr_in_next = read_counter ? count_rd_addr_in : write_addr_in;
assign count_out_next = count_out + 1;
assign counter_wen = read_counter ? 0 : wen_next;


always @ (posedge clk) begin
	if (reset) begin
		write_addr_in_next <= 0;
		wen_next <= 0;
	end else begin
		write_addr_in_next <= write_addr_in;
		wen_next <= match_in;
	end // else
end // always
endmodule
