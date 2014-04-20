`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:09:05 04/09/2014 
// Design Name: 
// Module Name:    Source_IP_Matcher 
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
module accelerator #(
	parameter FT_ADDR_WIDTH = 4,
	parameter FT_DEPTH		= 16,
	parameter NUM_ACTIONS	= 4
) (
    input clk,
	input reset,
    input [31:0] ip_in,
    input [2:0] thread_id_in,
    input start_in,
	input [FT_ADDR_WIDTH-1:0] counter_rd_addr_in,
	input read_counter,
	input [31:0] ft_ip ,
	input [NUM_ACTIONS-1:0] ft_action,
	input [FT_ADDR_WIDTH-1:0] ft_addr,
	input setup_ft,
	
    output [NUM_ACTIONS-1:0] action_out,
    output reg [2:0] thread_id_out,
    output reg acc_done,
	output [31:0] count_out,
	output match_true
    );

wire [FT_ADDR_WIDTH-1:0] counter_write_addr_in;
wire  counter_match_in;
wire tcam_match_out;
wire [FT_ADDR_WIDTH-1:0] tcam_addr_out;
wire [FT_ADDR_WIDTH-1:0] dram_rd_addr_in;
wire [31:0] ipmatch_in;
reg [2:0] thread_id_d1, thread_id_d2;
reg acc_done_d2, acc_done_d1;
assign counter_write_addr_in = tcam_addr_out;
assign counter_match_in = tcam_match_out;
assign dram_rd_addr_in = tcam_addr_out;
assign ipmatch_in = setup_ft ? ft_ip : ip_in;
assign match_true = tcam_match_out;

counter ctr (
    .clk					(clk), 
	 .reset					(reset),
    .write_addr_in			(counter_write_addr_in), 
    .count_rd_addr_in		(counter_rd_addr_in), 
    .match_in				(counter_match_in), 
    .read_counter			(read_counter), 
    .count_out				(count_out)
    );
	 
action_lookup action_lookup1 (
    .clka					(clk), 
    .dina					(ft_action), 
    .addra					(ft_addr), 
    .wea					(setup_ft), 
    .clkb					(clk), 
    .addrb					(dram_rd_addr_in), 
    .doutb					(action_out)
    );


ipmatch ipmatch1 (
    .clk					(clk), 
    .din					(ipmatch_in), 
    .we						(setup_ft), 	
    .wr_addr				(ft_addr), 
    .busy					(), 
    .match					(tcam_match_out), 
    .match_addr				(tcam_addr_out)
    );

always @ (posedge clk) begin
	if (reset) begin
	thread_id_d1 <= 0;
	thread_id_d2 <= 0;
	thread_id_out <=0;
	acc_done <=0;
	acc_done_d1 <=0;
	acc_done_d2 <=0;
	end else begin
	thread_id_d1 <= thread_id_in;
	thread_id_d2 <= thread_id_d1;
	thread_id_out <= thread_id_d2;
	acc_done_d1 <= start_in;
	acc_done_d2 <= acc_done_d1;
	acc_done <= acc_done_d2;
	end // else
end	 
endmodule
