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
	parameter 	REGFILE_ADDR_WIDTH 	= 	5,
	parameter 	DATAPATH_WIDTH	 	= 	64,
	parameter	INST_WIDTH 			= 	32,
	parameter 	MEM_ADDR_WIDTH		= 	8,
	parameter 	INST_ADDR_WIDTH		= 	6,	
	parameter	THREAD_BITS			=	2,
	parameter 	NUM_THREADS			=	2**THREAD_BITS,
	parameter	NUM_THREADS_ARYA	=	2*NUM_THREADS,
	parameter 	NUM_ACTIONS 		= 	2
	)
	
	(input 		clk,
    input 		reset,
	input 		en,
    input 		[INST_ADDR_WIDTH + 1:0] inst_addr_in,
    input 		[INST_WIDTH-1:0] inst_data_in,
    input 		setup_mem,
	input		[DATAPATH_WIDTH-1:0] datamem_data_in,
	input			[NUM_THREADS-1:0]			start_thread,	
	input			[NUM_THREADS-1:0]			debug_commands,
	input		[NUM_ACTIONS-1:0]	action_data_in,
	input		action_wen,
	input		[THREAD_BITS-1:0] action_thread_id_in,
	
	output 		[INST_WIDTH-1:0] inst_data_out,
	output		reg [(8*NUM_THREADS)-1:0] datamem_addr_out,
	output		reg [(DATAPATH_WIDTH*NUM_THREADS)-1:0] datamem_data_out,
	output		reg [NUM_THREADS-1:0]datamem_we_out,
	output		[THREAD_BITS-1:0]			thread_id_out,
	output 		reg [NUM_THREADS-1:0]	thread_busy,
	output 		reg [NUM_THREADS-1:0]	thread_done,
	output		[31:0] halt_counter_out

    );
	 
reg [THREAD_BITS-1:0]thread_id;



/////////////////////////////////////// wires pc_incrementor //////////////////////////////////////

wire [INST_ADDR_WIDTH-1:0] 						pc_out[0:3];


wire  									branch_true;
wire  [INST_ADDR_WIDTH-1:0]		pc_in[0:3];
wire 	[3:0]pc_select;

//////////////////////////////////////// wires dualport_mem1 ///////////////////////////////////

wire 	[(INST_ADDR_WIDTH-1) + 2:0] porta_addr_in;
wire 	[INST_WIDTH-1:0]	porta_data_in;
wire	porta_we_in;
wire 	[INST_WIDTH-1:0]	porta_data_out;

wire 	[(INST_ADDR_WIDTH-1) + 2:0]	portb_addr_in;
wire 	[INST_WIDTH-1:0]	portb_data_in;
wire 	portb_we_in;
wire	[INST_WIDTH-1:0]	portb_data_out;


wire 	[MEM_ADDR_WIDTH-1:0]	df_portb_addr_in;
wire 	[DATAPATH_WIDTH-1:0]	df_portb_data_in;
wire 	df_portb_we_in;
wire	[DATAPATH_WIDTH-1:0]	df_portb_data_out;


//////////////////////////////////////// wires pipe_fetch_decode ///////////////////////////////////
							  
wire 	[INST_WIDTH-1:0] 						pipe_fd_inst_in;
wire 	[INST_WIDTH-1:0] 						pipe_fd_inst_out;
wire 	[INST_ADDR_WIDTH-1:0]	pipe_fd_pc_in;
wire	[INST_ADDR_WIDTH-1:0]	pipe_fd_pc_out;
wire [THREAD_BITS-1:0]			pipe_fd_thread_id_in;
wire [THREAD_BITS-1:0]			pipe_fd_thread_id_out;

//////////////////////////////////////// wires decoder ///////////////////////////////////

wire 	[INST_WIDTH-1:0]							decoder_inst_in;
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
wire [THREAD_BITS-1:0]				pipe_de_thread_id_in;

wire 	[INST_ADDR_WIDTH-1:0]		pipe_de_pc_out;
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R1_data_out;	
wire	[DATAPATH_WIDTH-1:0]			pipe_de_R2_data_out;
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
wire [THREAD_BITS-1:0]				pipe_de_thread_id_out;
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
wire [THREAD_BITS-1:0]				pipe_em_thread_id_in;

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
wire [THREAD_BITS-1:0]				pipe_em_thread_id_out;
//////////////////////////////////////// wires pipe memory wb /////////////////////////////////// 

wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_mem_data_in;
wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_accum_in;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_mw_WR_addr_in;
wire 										pipe_mw_WR_en_in;
wire 										pipe_mw_mem_reg_sel_in;
wire [THREAD_BITS-1:0]				pipe_mw_thread_id_in;


wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_mem_data_out;
wire 	[DATAPATH_WIDTH-1:0]			pipe_mw_accum_out;
wire 	[REGFILE_ADDR_WIDTH-1:0]	pipe_mw_WR_addr_out;
wire 										pipe_mw_WR_en_out;
wire 										pipe_mw_mem_reg_sel_out;
wire [THREAD_BITS-1:0]				pipe_mw_thread_id_out;




////// temp wires////

wire beq_taken, bneq_taken;
/////////////////////
assign global_enable = en;
assign cpu_done	= decoder_halt_cpu_out;
assign cpu_busy = global_enable;
///////////////////////////////pc incrementor module instantiation //////////////////////////////////
wire [NUM_THREADS-1:0]pc_en;
wire [NUM_THREADS-1:0]decoder_thread_done;
wire [NUM_THREADS-1:0]pc_clk;

assign pc_clk[0] = clk && ~thread_id[1] && ~thread_id[0];
assign pc_clk[1] = clk && ~thread_id[1] && thread_id[0];
assign pc_clk[2] = clk && thread_id[1] && ~thread_id[0];
assign pc_clk[3] = clk && thread_id[1] && thread_id[0];



genvar i;
	generate
		for (i=0; i< NUM_THREADS; i=i+1) begin : sequential
			assign pc_en[i] = en && thread_busy[i];

				pc_incrementor #(
						.INST_ADDR_WIDTH	(INST_ADDR_WIDTH)
				) pc (
				.clk			(clk), 
				.en			(pc_en[i]),
				//.wen			(pc_select[i]),
				// REMOVE BELOW HACK
				.wen			(0),
				.reset		(thread_done[i] || reset),
				.pc_in		(pc_in[i]),		
				.pc_out		(pc_out[i])
			);

		end// for
	endgenerate// endgenerate
//////////////////////////////////////// assigns ///////////////////////////////////

//porta
wire [(INST_ADDR_WIDTH - 1) + 2:0]mux1_out;
wire [(INST_ADDR_WIDTH - 1) + 2:0]mux2_out;
assign mux1_out = thread_id[0] ? {2'b01,pc_out[1]}:{2'b00,pc_out[0]};
assign mux2_out = thread_id[0] ? {2'b11,pc_out[3]}:{2'b10,pc_out[2]};
assign porta_addr_in = thread_id[1] ? mux2_out : mux1_out; 
assign porta_data_in 	= 0;
assign porta_we_in		= 0;

// Port for programming instructions
assign portb_addr_in 	= inst_addr_in;
assign portb_data_in		= inst_data_in;
assign portb_we_in		= setup_mem;
assign inst_data_out		= portb_data_out;

/////////////////////////////// module instantiation //////////////////////////////////

small_inst_mem memory (
//		.ena				(~decoder_halt_cpu_out || enable_mem),
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
assign mem_data_out		= portb_data_out;
assign pipe_fd_pc_in 	= porta_addr_in[INST_ADDR_WIDTH-1:0];
assign pipe_fd_thread_id_in = thread_id;
/////////////////////////////// module instantiation //////////////////////////////////

pipe_fetch_decode fetch_decode (
		.inst_in			(pipe_fd_inst_in), 	// input
		.pc_in			(pipe_fd_pc_in),
		.thread_id_in	(pipe_fd_thread_id_in),
		//outputs
		.inst_out		(pipe_fd_inst_out),		// output
		.pc_out   	 	(pipe_fd_pc_out),
		
		.clk				(clk), 					// input
		.en				(global_enable), 						// input
		.reset			(reset), 				// input
		.thread_id_out	(pipe_fd_thread_id_out)
		); 

//////////////////////////////////////// decoder assigns ///////////////////////////////////
// assign decoder_inst_in = pipe_fd_inst_out; 
// HACK - Since the memory takes address and returns data in the next clock,
// the decoder needs to take the instruction in directly from the memory and not from the 
// fetch-decode stage register.
assign decoder_inst_in = porta_data_out;

														
/////////////////////////////// module instantiation //////////////////////////////////

inst_decoder #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.INST_ADDR_WIDTH		(INST_ADDR_WIDTH),
		.INST_WIDTH				(INST_WIDTH)
)decoder (
		.inst_in			(decoder_inst_in), 		// input
		.reset			(reset),
		.clk				(clk),
		
		.thread_id		(pipe_fd_thread_id_out),
		.thread_done	(decoder_thread_done),
		
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
		.halt_counter	(halt_counter_out)
		);

/////////////////////////////// module instantiation //////////////////////////////////

regfile #(
		.DATAPATH_WIDTH		(DATAPATH_WIDTH),
		.REGFILE_ADDR_WIDTH	(REGFILE_ADDR_WIDTH),
		.NUM_ACTIONS		(NUM_ACTIONS),
		.THREAD_BITS		(THREAD_BITS)
)rf (

		.R1_addr_in				(rf_R1_addr_in), 		// input
		.R1_data_out			(rf_R1_data_out), 	// output
		.R2_addr_in				(rf_R2_addr_in), 		// input
		.R2_data_out			(rf_R2_data_out), 	// output
		.WR_addr_in				(rf_WR_addr_in), 		// input
		.WR_data_in				(rf_WR_data_in), 		// input
		.wena					(rf_wena_in), 				// input
		.clk					(clk), 					// input
		.action_data_in			(action_data_in),
		.action_wen				(action_wen),
		.action_thread_id_in	(action_thread_id_in),
		.reset					(reset)					// input
		);
	
//////////////////////////////////////// regfile assigns ///////////////////////////////////

assign rf_R1_addr_in = decoder_R1_addr_out;
assign rf_R2_addr_in = decoder_R2_addr_out;
//assign rf_WR_data_in = pipe_mw_mem_reg_sel_out ? pipe_mw_mem_data_out : pipe_mw_accum_out; // TIMING FIX
assign rf_WR_data_in	= pipe_mw_mem_reg_sel_out ? df_portb_data_out : pipe_mw_accum_out;
assign rf_WR_addr_in = pipe_mw_WR_addr_out;
assign rf_wena_in		= pipe_mw_WR_en_out && global_enable;

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

assign pipe_de_thread_id_in = pipe_fd_thread_id_out;

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
		.thread_id_in		(pipe_de_thread_id_in),
		
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
		.thread_id_out		(pipe_de_thread_id_out),

		.clk(clk), 
		.en(global_enable), 
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

assign pipe_em_thread_id_in 		= pipe_de_thread_id_out;
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
		.thread_id_in	(pipe_em_thread_id_in),
		
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
		.thread_id_out	(pipe_em_thread_id_out),
		
		.clk				(clk), 
		.en				(global_enable), 
		.reset			(reset)
    );



//////////////////////////////////////// assigns ///////////////////////////////////
// branch logic
assign beq_taken 		=  pipe_em_beq_out && pipe_em_zero_out;
assign bneq_taken		= 	pipe_em_bneq_out && ~pipe_em_zero_out;
assign branch_true	=	beq_taken | bneq_taken;

assign pc_select = (branch_true) ? (1 << thread_id) : 4'b0 ;

assign pc_in[3]	=pipe_em_branch_target_out;
assign pc_in[2]	=pipe_em_branch_target_out;
assign pc_in[1]	=pipe_em_branch_target_out;
assign pc_in[0]	=pipe_em_branch_target_out;


// to memory
//assign portb_addr_in 		= {one,alu_accum_out[8:0]}; // TIMING FIX
//assign portb_data_in 		= pipe_de_store_data_out; // TIMING FIX
assign df_portb_addr_in			= pipe_em_accum_out[MEM_ADDR_WIDTH-1:0];
assign df_portb_data_in			= pipe_em_store_data_out;
assign df_portb_we_in 			= pipe_em_mem_write_out;

	always @(*) begin
if (pipe_em_thread_id_out == 0) begin
	datamem_addr_out[7:0]		= df_portb_addr_in;
	datamem_data_out[63:0]		= df_portb_data_in;
	datamem_we_out[0]				= df_portb_we_in;
end
else begin
	datamem_addr_out[7:0]			= 'b0;
	datamem_data_out[63:0]		= 'b0;
	datamem_we_out[0]				= 'b0;
	end
	
if (pipe_em_thread_id_out == 1) begin
	datamem_addr_out[15:8]		= df_portb_addr_in;
	datamem_data_out[127:64]		= df_portb_data_in;
	datamem_we_out[1]				= df_portb_we_in;
	end
else begin
	datamem_addr_out[15:8]			= 'b0;
	datamem_data_out[127:64]		= 'b0;
	datamem_we_out[1]				= 'b0;
	end

if (pipe_em_thread_id_out== 2) begin
	datamem_addr_out[23:16]		= df_portb_addr_in;
	datamem_data_out[191:128]		= df_portb_data_in;
	datamem_we_out[2]				= df_portb_we_in;
	end
else begin
	datamem_addr_out[23:16]			= 'b0;
	datamem_data_out[191:128]		= 'b0;
	datamem_we_out[2]				= 'b0;
	end


if (pipe_em_thread_id_out == 3) begin
	datamem_addr_out[31:24]		= df_portb_addr_in;
	datamem_data_out[255:192]		= df_portb_data_in;
	datamem_we_out[3]				= df_portb_we_in;
	end
else begin
	datamem_addr_out[31:24]			= 'b0;
	datamem_data_out[255:192]		= 'b0;
	datamem_we_out[3]				= 'b0;
		end
end // always
assign df_portb_data_out		= datamem_data_in;

// to next pipe
//assign pipe_mw_mem_data_in 	= portb_data_out;
assign pipe_mw_mem_data_in		= datamem_data_in; // initially df_portb_data_out
assign pipe_mw_WR_en_in 		= pipe_em_WR_en_out; 
assign pipe_mw_WR_addr_in		= pipe_em_WR_addr_out;
assign pipe_mw_accum_in			= pipe_em_accum_out;
assign pipe_mw_mem_reg_sel_in = pipe_em_mem_reg_sel_out;
assign pipe_mw_thread_id_in 	= pipe_em_thread_id_out;


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
		.thread_id_in	(pipe_mw_thread_id_in),
		
		.mem_data_out	(pipe_mw_mem_data_out),
		.accum_out		(pipe_mw_accum_out),
		.WR_addr_out	(pipe_mw_WR_addr_out),
		.WR_en_out		(pipe_mw_WR_en_out),
		.mem_reg_sel_out(pipe_mw_mem_reg_sel_out),
		.thread_id_out	(pipe_mw_thread_id_out),
		
		.clk				(clk), 
		.en				(global_enable), 
		.reset			(reset)
    );
	 
	 
//////////////////////////////////////// assigns ///////////////////////////////////

assign thread_id_out = pipe_mw_thread_id_out ;

///////////////////////////////////////dummy arya state machine instantiation/////////////

	parameter 		START = 1'b0;
	parameter		BUSY  = 1'b1;
	
	reg		[NUM_THREADS-1:0]	state ;
	reg		[NUM_THREADS-1:0]	state_next;
	reg 	[NUM_THREADS*10-1:0]	count ;
	reg 	[NUM_THREADS-1:0] counter_reset;
	reg		[NUM_THREADS-1:0] thread_busy_next;

	reg		[NUM_THREADS-1:0]	debug_state ;
	reg		[NUM_THREADS-1:0]	debug_state_next;
	wire	[NUM_THREADS-1:0]	cpu_done_trigger;
	reg		[NUM_THREADS-1:0]	manual_trigger;
	reg		[NUM_THREADS-1:0]	manual_trigger_next;
	reg		[NUM_THREADS-1:0]	counter_trigger;


    /// GENERATE BLOCK ////
	generate
	for (i=0; i<NUM_THREADS ;i=i+1) begin: combinational
	//assign cpu_done_trigger[i] = decoder_thread_done[i];
	assign cpu_done_trigger[i] = counter_trigger[i];
	//assign cpu_done_trigger[i] = pc_thread_trigger[i];
	//assign cpu_done_trigger[i] = debug_on ? counter_trigger[i] : decoder_thread_done[i];
	//assign cpu_done_trigger[i] = debug_on ? manual_trigger[i] : counter_trigger[i];

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
	for (i=0; i<NUM_THREADS ;i=i+1) begin: sequen
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
			thread_id<=0;
		end // if (reset)
		else begin
			thread_id<=thread_id + 1;
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
