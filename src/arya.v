`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:07:18 02/26/2014 
// Design Name: 
// Module Name:    arya 
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
`define INST_WIDTH 32
`define REGFILE_ADDR 3
`define DATAPATH_WIDTH 64
`define MEM_ADDR_WIDTH 10
`define INST_MEM_START 0
`define DATA_MEM_START 512
`define NUM_COUNTERS 0
`define NUM_SOFTWARE_REGS 4
`define NUM_HARDWARE_REGS 3

module arya(
    input clk,
    input reset,
	 input en,
    input [`MEM_ADDR_WIDTH-1:0] mem_addr_in,
    input [`DATAPATH_WIDTH-1:0] mem_data_in,
    input setup_mem,
	 input verify_mem,
    output [`DATAPATH_WIDTH-1:0] mem_data_out
    );
wire [9:0] pc_out;
pc_incrementor pc (
    .clk(clk), 
    .en(en), 
    .reset(reset), 
    .pc_out(pc_out)
    );

wire enable_mem_debug;
wire [`MEM_ADDR_WIDTH-1:0] wr_addr_in;
assign enable_mem_debug = setup_mem || verify_mem;
assign wr_addr_in = enable_mem_debug ? mem_addr_in : pc_out;
wire [63:0]um_inst_out;
wire [63:0] write_data;
wire [63:0] em_R1out_out;
wire [63:0] em_R2out_out;
wire em_WMemEn_out;
wire one = 0'b1;

unified_memory memory (.addra(wr_addr_in), 	// input
							  .dina(mem_data_in), 	// input
							  .clka(clk), 				// input
							  .wea(setup_mem),		// input
                       .addrb({one,em_R1out_out[8:0]}), // input
                       .dinb(em_R2out_out),  // input
                       .clkb(clk), 				// input
                       .web(em_WMemEn_out),  // input                   
                       .douta(um_inst_out), 	// output
                       .doutb(write_data)		// output
							  );
							  
wire [63:0] fd_inst_out;

pipe_fetch_decode fetch_decode (
    .inst_in(um_inst_out), 	// input
    .clk(clk), 					// input
    .en(en), 						// input
    .reset(reset), 				// input
    .inst_out(fd_inst_out)		// output
    );

	
wire 	[2:0]  d_r0addr_out;
wire 	[2:0]  d_r1addr_out;
wire 	d_WRegEn_out;
wire 	d_WMemEn_out;
wire 	[2:0]	d_WReg1_out;


inst_decoder decoder (
    .clk(clk), 
    .reset(reset), 
    .en(en), 
    .inst_in(fd_inst_out), 		// input
    .r0addr_out(d_r0addr_out), 	// output
    .r1addr_out(d_r1addr_out), 	// output
    .WRegEn_out(d_WRegEn_out), 	// output
    .WMemEn_out(d_WMemEn_out), 	// output
    .WReg1_out(d_WReg1_out) 		// output
    );
		 
wire [63:0] r0data;
wire [63:0] r1data;

wire [2:0] mw_WReg1_out;
wire [63:0] mw_Mem_data_out;
wire mw_WRegEn_out;


regfile rf (
    .r0addr(d_r0addr_out), 		// input
    .r1addr(d_r1addr_out), 		// input
    .waddr(mw_WReg1_out), 			// input
    .wdata(mw_Mem_data_out), 		// input
    .r0data(r0data), 				// output
    .r1data(r1data), 				// output
    .wena(mw_WRegEn_out), 			// input
    .clk(clk), 						// input
    .reset(reset)						// input
    );
	
wire de_WregEn_out;
wire de_WMemEn_out;
wire [63:0]	de_R1out_out;
wire [63:0]	de_R2out_out;
wire [2:0] 	de_WReg1_out;

pipe_decode_execute decode_execute (
    .WRegEn_in(d_WRegEn_out), 	// input
    .WMemEn_in(d_WMemEn_out), 
    .R1out_in(r0data), 
    .R2out_in(r1data), 
    .WReg1_in(d_WReg1_out), 
    .clk(clk), 
    .en(en), 
    .reset(reset), 
    .WRegEn_out(de_WRegEn_out), // output
    .WMemEn_out(de_WMemEn_out), 
    .R1out_out(de_R1out_out), 
    .R2out_out(de_R2out_out), 
    .WReg1_out(de_WReg1_out)
    );
 
 
wire em_WRegEn_out ;
wire [2:0]	em_WReg1_out;
pipe_execute_mem execute_mem (
    .WRegEn_in(de_WRegEn_out), 
    .WMemEn_in(de_WMemEn_out), 
    .R1out_in(de_R1out_out), 
    .R2out_in(de_R2out_out), 
    .WReg1_in(de_WReg1_out), 
    .clk(clk), 
    .en(en), 
    .reset(reset), 
    .WRegEn_out(em_WRegEn_out), 
    .WMemEn_out(em_WMemEn_out), 
    .R1out_out(em_R1out_out), 
    .R2out_out(em_R2out_out), 
    .WReg1_out(em_WReg1_out)
    );

pipe_mem_wb mem_wb (
    .WRegEn_in(em_WRegEn_out), 		// input
    .Mem_data_in(write_data), 
    .WReg1_in(em_WReg1_out), 
    .clk(clk), 
    .en(en), 
    .reset(reset), 
    .WReg1_out(mw_WReg1_out), 		// output
    .WRegEn_out(mw_WRegEn_out), 
    .Mem_data_out(mw_Mem_data_out)
    );





endmodule
