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
	
	(input 		clk,
    input 		reset,
	 input 		en,
    input 		[MEM_ADDR_WIDTH-1:0] mem_addr_in,
    input 		[DATAPATH_WIDTH-1:0] mem_data_in,
    input 		setup_mem,
	 input 		verify_mem,
	 input 		enable_mem,
    output 		[DATAPATH_WIDTH-1:0] mem_data_out
    );
	 
wire one ;
wire zero;

assign zero = 0;
assign one = 1;
/////////////////////////////////////// wires pc_incrementor //////////////////////////////////////

wire [INST_ADDR_WIDTH-1:0] 						pc_out;
wire [MEM_ADDR_WIDTH-1:0] pc_out_extended 	= {zero, pc_out};
wire  													branch_true;
wire  [INST_ADDR_WIDTH-1:0]						pc_in;

//////////////////////////////////////// wires dualport_mem1 ///////////////////////////////////

wire 	[MEM_ADDR_WIDTH-1:0] porta_addr_in;
wire 	[DATAPATH_WIDTH-1:0]	porta_data_in;
wire	porta_we_in;
wire 	[DATAPATH_WIDTH-1:0]	porta_data_out;

wire 	[MEM_ADDR_WIDTH-1:0]	portb_addr_in;
wire 	[DATAPATH_WIDTH-1:0]	portb_data_in;
wire 	portb_we_in;
wire	[DATAPATH_WIDTH-1:0]	portb_data_out;

//////////////////////////////////////// wires pipe_fetch_decode ///////////////////////////////////
							  
wire 	[31:0] 						pipe_fd_inst_in;
wire 	[31:0] 						pipe_fd_inst_out;
wire 	[INST_ADDR_WIDTH-1:0]	pipe_fd_pc_in;
wire	[INST_ADDR_WIDTH-1:0]	pipe_fd_pc_out;

//////////////////////////////////////// wires decoder ///////////////////////////////////

wire 	[31:0]							decoder_inst_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_R1_addr_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_R2_addr_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	decoder_WR_addr_out;

wire 	[3:0]								decoder_alu_ctrl_out;
wire	[INST_ADDR_WIDTH-1:0]		decoder_branch_offset_out;
wire	[63:0]							decoder_imm_out;

wire 										decoder_WR_en_out;
wire 										decoder_mem_reg_sel_out;
wire 										decoder_imm_sel_out;
wire 										decoder_beq_out;
wire 										decoder_bneq_out;
wire 										decoder_mem_write_out;
wire 										decoder_halt_cpu_out;

//////////////////////////////////////// wires register_file /////////////////////////////////// 
		 
wire 	[REGFILE_ADDR_WIDTH-1:0]	rf_R1_addr_in;	
wire 	[DATAPATH_WIDTH-1:0]			rf_R1_data_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	rf_R2_addr_in;
wire 	[DATAPATH_WIDTH-1:0]			rf_R2_data_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	rf_WR_addr_in;
wire 	[DATAPATH_WIDTH-1:0]			rf_WR_data_in;
wire 	rf_wena_in;

//////////////////////////////////////// wires pipe_decode_execute /////////////////////////////////// 
	
wire 	[INST_ADDR_WIDTH-1:0]		pipe_de_pc_in;
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R1_data_in;	
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R2_data_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_store_data_in;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_WR_addr_in;
wire [3:0]								pipe_de_alu_ctrl_in;
wire [INST_ADDR_WIDTH-1:0]			pipe_de_branch_offset_in;
wire [4:0]								pipe_de_alu_shift_value_in;


wire										pipe_de_WR_en_in;
wire 										pipe_de_mem_reg_sel_in;
wire 										pipe_de_beq_in;
wire										pipe_de_bneq_in;
wire 										pipe_de_mem_write_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_de_store_data_in;

wire 	[INST_ADDR_WIDTH-1:0]		pipe_de_pc_out;
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R1_data_out;	
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R2_data_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_store_data_out;
wire	[REGFILE_ADDR_WIDTH-1:0]	pipe_de_WR_addr_out;
wire [3:0]								pipe_de_alu_ctrl_out;
wire [INST_ADDR_WIDTH-1:0]			pipe_de_branch_offset_out;
wire [4:0]								pipe_de_alu_shift_value_out;

wire										pipe_de_WR_en_out;
wire 										pipe_de_mem_reg_sel_out;
wire 										pipe_de_beq_out;
wire										pipe_de_bneq_out;
wire 										pipe_de_mem_write_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_de_store_data_out;
//////////////////////////////////////// wires alu /////////////////////////////////// 

wire	[DATAPATH_WIDTH-1:0]			alu_accum_out;
wire 	[DATAPATH_WIDTH-1:0]			alu_a_in;	
wire 	[DATAPATH_WIDTH-1:0]			alu_b_in;
wire  [4:0]								alu_shift_value_in;
wire	[3:0]								alu_ctrl_in;
wire 										alu_zero_out;							
//////////////////////////////////////// wires branch_adder /////////////////////////////////// 
wire [INST_ADDR_WIDTH-1:0]			badd_pc_in;
wire [INST_ADDR_WIDTH-1:0]			badd_branch_offset_in;
wire [INST_ADDR_WIDTH-1:0]			badd_branch_target_out;
//////////////////////////////////////// wires pipe execute memory /////////////////////////////////// 

wire 	[INST_ADDR_WIDTH-1:0]		pipe_em_branch_target_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_accum_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_store_data_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_em_WR_addr_in;
wire										pipe_em_WR_en_in;
wire 										pipe_em_mem_reg_sel_in;
wire 										pipe_em_beq_in;
wire										pipe_em_bneq_in;
wire										pipe_em_zero_in;
wire 										pipe_em_mem_write_in;

wire 	[INST_ADDR_WIDTH-1:0]		pipe_em_branch_target_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_accum_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_em_store_data_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_em_WR_addr_out;
wire										pipe_em_WR_en_out;
wire 										pipe_em_mem_reg_sel_out;
wire 										pipe_em_beq_out;
wire										pipe_em_bneq_out;
wire 										pipe_em_zero_out;
wire 										pipe_em_mem_write_out;

//////////////////////////////////////// wires pipe memory wb /////////////////////////////////// 

wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_mem_data_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_accum_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_mw_WR_addr_in;
wire 										pipe_mw_WR_en_in;
wire 										pipe_mw_mem_reg_sel_in;


wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_mem_data_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_accum_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_mw_WR_addr_out;
wire 										pipe_mw_WR_en_out;
wire 										pipe_mw_mem_reg_sel_out;



////// temp wires////

wire beq_taken, bneq_taken;
/////////////////////
/////////////////////////////// module instantiation //////////////////////////////////

pc_incrementor #(
			.INST_ADDR_WIDTH	(INST_ADDR_WIDTH)
	) pc (
		.clk			(clk), 
		.en			(~decoder_halt_cpu_out),
		.wen			(branch_true),
		.reset		(reset),
		.pc_in		(pc_in),		
		.pc_out		(pc_out)
			);

//////////////////////////////////////// assigns ///////////////////////////////////

//porta
wire debug_mem;
assign debug_mem = setup_mem | verify_mem;
assign porta_addr_in 	= debug_mem ? mem_addr_in : pc_out_extended;
assign porta_data_in		= mem_data_in;
assign porta_we_in		= setup_mem;
/////////////////////////////// module instantiation //////////////////////////////////

dualport_mem1 memory (
		.ena				(~decoder_halt_cpu_out || enable_mem),
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
		 
//////////////////////////////////////// assigns ///////////////////////////////////
assign pipe_fd_inst_in 	= porta_data_out;
assign mem_data_out		= porta_data_out;
assign pipe_fd_pc_in 	= pc_out;
/////////////////////////////// module instantiation //////////////////////////////////

pipe_fetch_decode fetch_decode (
		.inst_in			(pipe_fd_inst_in), 	// input
		.pc_in			(pipe_fd_pc_in),
		
		//outputs
		.inst_out		(pipe_fd_inst_out),		// output
		.pc_out   	 	(pipe_fd_pc_out),
		
		.clk				(clk), 					// input
		.en				(~decoder_halt_cpu_out), 						// input
		.reset			(reset) 				// input
		);

//////////////////////////////////////// decoder assigns ///////////////////////////////////
// assign decoder_inst_in = pipe_fd_inst_out; 
// HACK - Since the memory takes address and returns data in the next clock,
// the decoder needs to take the instruction in directly from the memory and not from the 
// fetch-decode stage register.
assign decoder_inst_in = debug_mem ? 'hFFFFFFFF : porta_data_out;

														
/////////////////////////////// module instantiation //////////////////////////////////

inst_decoder #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)decoder (
		.inst_in			(decoder_inst_in), 		// input
		
		.R1_addr_out	(decoder_R1_addr_out), 	// output
		.R2_addr_out	(decoder_R2_addr_out), 	// output
		.WR_addr_out	(decoder_WR_addr_out),
		
		.imm_out			(decoder_imm_out),		
		.branch_offset	(decoder_branch_offset_out),
		.alu_ctrl_out	(decoder_alu_ctrl_out),

		.WR_en_out		(decoder_WR_en_out),
		.beq_out			(decoder_beq_out),
		.bneq_out		(decoder_bneq_out),
		.imm_sel_out	(decoder_imm_sel_out),
		.mem_write_out	(decoder_mem_write_out),
		.mem_reg_sel	(decoder_mem_reg_sel_out),
		.halt_cpu_out	(decoder_halt_cpu_out)
		);

/////////////////////////////// module instantiation //////////////////////////////////

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
		.wena				(rf_wena_in), 				// input
		.clk				(clk), 					// input
		.reset			(reset)					// input
		);
	
//////////////////////////////////////// regfile assigns ///////////////////////////////////

assign rf_R1_addr_in = decoder_R1_addr_out;
assign rf_R2_addr_in = decoder_R2_addr_out;
//assign rf_WR_data_in = pipe_mw_mem_reg_sel_out ? pipe_mw_mem_data_out : pipe_mw_accum_out; // TIMING FIX
assign rf_WR_data_in	= pipe_mw_mem_reg_sel_out ? portb_data_out : pipe_mw_accum_out;
assign rf_WR_addr_in = pipe_mw_WR_addr_out;
assign rf_wena_in		= pipe_mw_WR_en_out && ~decoder_halt_cpu_out;

// to next pipe
assign pipe_de_pc_in			= pipe_fd_pc_out;
assign pipe_de_alu_ctrl_in	= decoder_alu_ctrl_out;
assign pipe_de_R1_data_in	= rf_R1_data_out;
assign pipe_de_WR_addr_in 	= decoder_imm_sel_out ? decoder_R2_addr_out : decoder_WR_addr_out;
assign pipe_de_branch_offset_in = decoder_branch_offset_out;
// control signals
assign pipe_de_R2_data_in	= decoder_imm_sel_out ? decoder_imm_out : rf_R2_data_out;
assign pipe_de_WR_en_in 	= decoder_WR_en_out;
assign pipe_de_mem_write_in = decoder_mem_write_out;
assign pipe_de_mem_reg_sel_in 	= decoder_mem_reg_sel_out;
assign pipe_de_beq_in		= decoder_beq_out;
assign pipe_de_bneq_in		= decoder_bneq_out;
assign pipe_de_store_data_in = rf_R2_data_out;
assign pipe_de_alu_shift_value_in	=	decoder_imm_out[10:6];


/////////////////////////////// module instantiation //////////////////////////////////

pipe_decode_execute #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)decode_execute (
		// input ports
		.pc_in				(pipe_de_pc_in),
		.R1_data_in			(pipe_de_R1_data_in),
		.R2_data_in			(pipe_de_R2_data_in),
		.store_data_in		(pipe_de_store_data_in),
		.WR_addr_in			(pipe_de_WR_addr_in),
		.branch_offset_in	(pipe_de_branch_offset_in),
		.alu_ctrl_in		(pipe_de_alu_ctrl_in),
		.alu_shift_value_in (pipe_de_alu_shift_value_in),
		// control signals
		.WR_en_in			(pipe_de_WR_en_in),
		.mem_reg_sel_in	(pipe_de_mem_reg_sel_in),
		.beq_in				(pipe_de_beq_in),
		.bneq_in				(pipe_de_bneq_in),
		.mem_write_in		(pipe_de_mem_write_in),

		
		// output ports
		.pc_out				(pipe_de_pc_out),
		.R1_data_out		(pipe_de_R1_data_out),
		.R2_data_out		(pipe_de_R2_data_out),
		.store_data_out	(pipe_de_store_data_out),
		.WR_addr_out		(pipe_de_WR_addr_out),
		.alu_ctrl_out		(pipe_de_alu_ctrl_out),
		.WR_en_out			(pipe_de_WR_en_out),
		.mem_reg_sel_out	(pipe_de_mem_reg_sel_out),
		.beq_out				(pipe_de_beq_out),
		.bneq_out			(pipe_de_bneq_out),
		.mem_write_out		(pipe_de_mem_write_out),
		.branch_offset_out	(pipe_de_branch_offset_out),
		.alu_shift_value_out (pipe_de_alu_shift_value_out),

		.clk(clk), 
		.en(~decoder_halt_cpu_out), 
		.reset(reset)
    );


/////////////////////////////// module instantiation //////////////////////////////////

alu #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH)
		
) alu1 (.a_in				(alu_a_in),
		  .b_in				(alu_b_in),
		  .alu_ctrl_in		(alu_ctrl_in),
		  //.shift_value		(alu_shift_value_in),
		  .accum_out		(alu_accum_out),
		  .zero_out			(alu_zero_out)
		  );
		  
 

/////////////////////////////// module instantiation //////////////////////////////////

branch_adder #(
.INST_ADDR_WIDTH (INST_ADDR_WIDTH)
) ba (
		.pc_in				(badd_pc_in),
		.branch_offset		(badd_branch_offset_in),
		.branch_target		(badd_branch_target_out)  
);
//////////////////////////////////////// alu assigns ///////////////////////////////////
assign alu_a_in 		= pipe_de_R1_data_out;
assign alu_b_in 		= pipe_de_R2_data_out;
assign alu_ctrl_in 	= pipe_de_alu_ctrl_out;
assign alu_shift_value_in	=	pipe_de_alu_shift_value_out;
//////////////////////////////////////// branch_adder assigns ///////////////////////////////////
assign badd_pc_in						= pipe_de_pc_out;
assign badd_branch_offset_in		= pipe_de_branch_offset_out;
//////////////////////////////////////// assigns to next pipe ///////////////////////////////////
//from alu
assign pipe_em_accum_in 			= alu_accum_out;
assign pipe_em_zero_in				= alu_zero_out;
//from badd
assign pipe_em_branch_target_in 	= badd_branch_target_out;


// from previous pipe
assign pipe_em_WR_en_in 			= pipe_de_WR_en_out;
assign pipe_em_WR_addr_in 			= pipe_de_WR_addr_out;
assign pipe_em_store_data_in 		= pipe_de_store_data_out;
assign pipe_em_mem_reg_sel_in 	= pipe_de_mem_reg_sel_out;
assign pipe_em_beq_in				= pipe_de_beq_out;
assign pipe_em_bneq_in				= pipe_de_bneq_out;
assign pipe_em_mem_write_in 		= pipe_de_mem_write_out;
/////////////////////////////// module instantiation //////////////////////////////////

pipe_execute_mem #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH)
)execute_mem (
		.accum_in		(pipe_em_accum_in),
		.store_data_in	(pipe_em_store_data_in),
		.WR_addr_in		(pipe_em_WR_addr_in),
		.WR_en_in		(pipe_em_WR_en_in),
		.beq_in			(pipe_em_beq_in),
		.bneq_in			(pipe_em_bneq_in),
		.mem_write_in	(pipe_em_mem_write_in),
		.branch_target_in (pipe_em_branch_target_in),
		.zero_in			(pipe_em_zero_in),
		.mem_reg_sel_in(pipe_em_mem_reg_sel_in),
		
		.accum_out		(pipe_em_accum_out),
		.store_data_out(pipe_em_store_data_out),
		.WR_addr_out	(pipe_em_WR_addr_out),
		.WR_en_out		(pipe_em_WR_en_out),
		.beq_out			(pipe_em_beq_out),
		.bneq_out		(pipe_em_bneq_out),
		.mem_write_out	(pipe_em_mem_write_out),
		.branch_target_out (pipe_em_branch_target_out),
		.zero_out		(pipe_em_zero_out),
		.mem_reg_sel_out(pipe_em_mem_reg_sel_out),
		
		.clk				(clk), 
		.en				(~decoder_halt_cpu_out), 
		.reset			(reset)
    );



//////////////////////////////////////// assigns ///////////////////////////////////
// branch logic
assign beq_taken 		=  pipe_em_beq_out && pipe_em_zero_out;
assign bneq_taken		= 	pipe_em_bneq_out && ~pipe_em_zero_out;
assign branch_true	=	beq_taken | bneq_taken;
assign pc_in			=	branch_true ? pipe_em_branch_target_out : pc_out;
// to memory
//assign portb_addr_in 		= {one,alu_accum_out[8:0]}; // TIMING FIX
//assign portb_data_in 		= pipe_de_store_data_out; // TIMING FIX
assign portb_addr_in			= {one, pipe_em_accum_out[8:0]};
assign portb_data_in			= (pipe_em_store_data_out);
assign portb_we_in 			= pipe_em_mem_write_out;


// to next pipe
assign pipe_mw_mem_data_in 	= portb_data_out;
assign pipe_mw_WR_en_in 		= pipe_em_WR_en_out; 
assign pipe_mw_WR_addr_in		= pipe_em_WR_addr_out;
assign pipe_mw_accum_in			= pipe_em_accum_out;
assign pipe_mw_mem_reg_sel_in = pipe_em_mem_reg_sel_out;

/////////////////////////////// module instantiation //////////////////////////////////

pipe_mem_wb #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH)
)mem_wb (
		.mem_data_in	(pipe_mw_mem_data_in),
		.accum_in		(pipe_mw_accum_in),
		.WR_addr_in		(pipe_mw_WR_addr_in),
		.WR_en_in		(pipe_mw_WR_en_in),
		.mem_reg_sel_in(pipe_mw_mem_reg_sel_in),
		
		.mem_data_out	(pipe_mw_mem_data_out),
		.accum_out		(pipe_mw_accum_out),
		.WR_addr_out	(pipe_mw_WR_addr_out),
		.WR_en_out		(pipe_mw_WR_en_out),
		.mem_reg_sel_out(pipe_mw_mem_reg_sel_out),
		
		.clk				(clk), 
		.en				(~decoder_halt_cpu_out), 
		.reset			(reset)
    );
	 
	 
//////////////////////////////////////// assigns ///////////////////////////////////





endmodule
