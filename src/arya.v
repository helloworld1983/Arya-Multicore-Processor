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

module arya #(
	parameter 	REGFILE_ADDR_WIDTH 	= 5,
	parameter 	DATAPATH_WIDTH	 		= 64,
	parameter 	MEM_ADDR_WIDTH			= 10,
	parameter 	INST_ADDR_WIDTH		= 9
	)
(
    input 		clk,
    input 		reset,
	 input 		en,
    input 		[MEM_ADDR_WIDTH-1:0] mem_addr_in,
    input 		[DATAPATH_WIDTH-1:0] mem_data_in,
    input 		setup_mem,
	 input 		verify_mem,
    output 		[DATAPATH_WIDTH-1:0] mem_data_out
    );

wire [INST_ADDR_WIDTH-1:0] pc_out;
wire one = 1'b1;
wire zero = 1'b0;

pc_incrementor #(
			.INST_ADDR_WIDTH	(INST_ADDR_WIDTH)
	) pc (
		.clk			(clk), 
		.en			(en), 
		.reset		(reset), 
		.pc_out		(pc_out)
			);


wire [MEM_ADDR_WIDTH:0] pc_out_extended = {zero, pc_out};
wire enable_mem_debug;

wire 	[MEM_ADDR_WIDTH-1:0] porta_addr_in;
wire 	[DATAPATH_WIDTH-1:0]	porta_data_in;
wire	porta_we_in;
wire 	[DATAPATH_WIDTH-1:0]	porta_data_out;

wire 	[MEM_ADDR_WIDTH-1:0]	portb_addr_in;
wire 	[DATAPATH_WIDTH-1:0]	portb_data_in;
wire 	portb_we_in;
wire	[DATAPATH_WIDTH-1:0]	portb_data_out;

assign enable_mem_debug = setup_mem || verify_mem;
assign porta_addr_in = enable_mem_debug ? mem_addr_in : pc_out_extended;

dualport_mem1 memory (
		.addra			(porta_addr_in), 	// input
		.dina				(porta_data_in), 	// input
		.wea				(porta_we_in),		// input
		.douta			(porta_data_out), 	// output
		.addrb			(portb_addr_in), // input
		.dinb				(portb_data_in),  // input
		.web				(portb_we_in),  // input                   
		.doutb			(portb_data_out),		// output
		.clka				(clk), 				// input
		.clkb				(clk) 				// input
		 );
							  
wire 	[DATAPATH_WIDTH-1:0] 	pipe_fd_inst_in;
wire 	[DATAPATH_WIDTH-1:0] 	pipe_fd_inst_out;
wire 	[INST_ADDR_WIDTH-1:0]	pipe_fd_pc_in;

pipe_fetch_decode fetch_decode (
		.inst_in			(pipe_fd_inst_in), 	// input
		.pc_in			(fd_pc_in),
		.inst_out		(pipe_fd_inst_out),		// output
		.clk				(clk), 					// input
		.en				(en), 						// input
		.reset			(reset) 				// input
		);

wire 	[DATAPATH_WIDTH-1:0]			decoder_inst_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_R1_addr_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_R2_addr_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_WR_addr_out;
wire 	[INST_ADDR_WIDTH-1:0]		decoder_pc_out;	
wire 	[INST_ADDR_WIDTH-1:0]		decoder_pc_in;
	
inst_decoder #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)decoder (
		.inst_in			(decoder_inst_in), 		// input
		.pc_in			(decoder_pc_in),
		.R1_addr_out	(decoder_R1_addr_out), 	// output
		.R2_addr_out	(decoder_R2_addr_out), 	// output
		.WR_addr_out	(decoder_WR_addr_out),
		.pc_out			(decoder_pc_out),
		.clk				(clk), 
		.reset			(reset), 
		.en				(en)
		);
		 
wire 	[MEM_ADDR_WIDTH-1:0]		rf_R1_addr_in;	
wire 	[DATAPATH_WIDTH-1:0]		rf_R1_data_out;
wire 	[MEM_ADDR_WIDTH-1:0]		rf_R2_addr_in;
wire 	[DATAPATH_WIDTH-1:0]		rf_R2_data_out;
wire 	[MEM_ADDR_WIDTH-1:0]		rf_WR_addr_in;
wire 	[DATAPATH_WIDTH-1:0]		rf_WR_data_in;
wire 	rf_wena;

regfile #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH)
)rf (

		.R1_addr_in		(rf_R1_addr_in), 		// input
		.R1_data_out	(rf_R1_data_out), 	// output
		.R2_addr_in		(rf_R2_addr_in), 		// input
		.R2_data_out	(rf_R2_data_out), 	// output
		.WR_addr_in		(rf_WR_addr_in), 		// input
		.WR_data_in		(rf_WR_data_in), 		// input
		.wena				(rf_wena), 				// input
		.clk				(clk), 					// input
		.reset			(reset)					// input
		);
	
	
wire 	[INST_ADDR_WIDTH-1:0]		pipe_de_pc_in;
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R1_data_in;	
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R2_data_in;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_R1_addr_in;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_R2_addr_in;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_WR_addr_in;

wire 	[INST_ADDR_WIDTH-1:0]		pipe_de_pc_out;
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R1_data_out;	
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R2_data_out;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_R1_addr_out;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_R2_addr_out;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_WR_addr_out;

pipe_decode_execute #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)decode_execute (
		// input ports
		.pc_in			(pipe_de_pc_in),
		.R1_data_in		(pipe_de_R1_data_in),
		.R2_data_in		(pipe_de_R2_data_in),
		.R1_addr_in		(pipe_de_R1_addr_in),
		.R2_addr_in		(pipe_de_R2_addr_in),
		.WR_addr_in		(pipe_de_WR_addr_in),
		
		// output ports
		.pc_out			(pipe_de_pc_out),
		.R1_data_out	(pipe_de_R1_data_out),
		.R2_data_out	(pipe_de_R2_data_out),
		.R1_addr_out	(pipe_de_R1_addr_out),
		.R2_addr_out	(pipe_de_R2_addr_out),
		.WR_addr_out	(pipe_de_WR_addr_out),

		.clk(clk), 
		.en(en), 
		.reset(reset)
    );
 
 
wire 	[INST_ADDR_WIDTH-1:0]		pipe_em_pc_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_accum_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_store_data_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_em_WR_addr_in;

wire 	[INST_ADDR_WIDTH-1:0]		pipe_em_pc_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_accum_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_store_data_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_em_WR_addr_out;


pipe_execute_mem #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)execute_mem (
		.pc_in			(pipe_em_pc_in),
		.accum_in		(pipe_em_accum_in),
		.store_data_in	(pipe_em_store_data_in),
		.WR_addr_in		(pipe_em_WR_addr_in),
		
		.pc_out			(pipe_em_pc_out),
		.accum_out		(pipe_em_accum_out),
		.store_data_out(pipe_em_store_data_out),
		.WR_addr_out	(pipe_em_WR_addr_out),
		
		.clk				(clk), 
		.en				(en), 
		.reset			(reset)
    );

wire 	[DATAPATH_WIDTH-1:0]			pipe_wb_mem_data_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_wb_accum_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_wb_WR_addr_in;

wire 	[DATAPATH_WIDTH-1:0]			pipe_wb_mem_data_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_wb_accum_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_wb_WR_addr_out;


pipe_mem_wb #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH)
)mem_wb (
		.mem_data_in	(pipe_mw_mem_data_in),
		.accum_in		(pipe_mw_accum_in),
		.WR_addr_in		(pipe_mw_WR_addr_in),
		
		.mem_data_out	(pipe_mw_mem_data_out),
		.accum_out		(pipe_mw_accum_out),
		.WR_addr_out	(pipe_mw_WR_addr_out),
		
		.clk				(clk), 
		.en				(en), 
		.reset			(reset)
    );
	 
endmodule
