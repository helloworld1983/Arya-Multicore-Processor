//////////////////////////////////
////// SOFTWARE REGS ////////////
//////////////////////////////////
// dbs_cmd [0] 	= send a reset
// dbs_cmd [1] 	= setup memory
// dbs_cmd [2] 	= verify mem
// dbs_cmd [3]  = set debug mode on
// dbs_cmd [4] 	= enable stepinto
// dbs_cmd [5] 	= stepvalue bit 0
// dbs_cmd [6] 	= stepvalue bit 1
// dbs_cmd [7] 	= stepvalue bit 2
// dbs_cmd [8] 	= reset step count
// dbs_cmd [9] 	= enable mem
// dbs_cmd [10] = unused
// dbs_cmd [11] = unused
// dbs_cmd [12] = unused
	// dbs_cmd [13] = unused
// dbs_cmd [23] = datamem_debug_on
// dbs_cmd [31:24] = manual_trigger
////////////////////////////////////
// [31:0] 	dbs_input_data_high 	= upper 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_data_low 	= lower 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_data_addr 			= memory address to program
////////////////////////////////////
// [31:0] 	dbs_input_inst_high 	= upper 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_inst_low 	= lower 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_inst_addr 			= memory address to program
///////////////////////////////////


/////////////////////////////////////
///// HARDWARE REGS//////////////////
////////////////////////////////////
// [31:0]	dbh_output_data_high		= upper 32 bits of data read from mem
/////////////////////////////////////
// [31:0]	dbh_output_data_low		= lower 32 bits of data read from mem
////////////////////////////////////
// [31:0]	dbh_output_inst_high		= upper 32 bits of data read from mem
/////////////////////////////////////
// [31:0]	dbh_output_inst_low		= lower 32 bits of data read from mem
////////////////////////////////////
// [31:0]	dbh_step_count		 	= Number of steps the simulation has run
////////////////////////////////////


`timescale 1ns/1ps
// defines

`define REGFILE_ADDR_WIDTH 	5
`define MEM_ADDR_WIDTH 			8
`define INST_ADDR_WIDTH 		8
`define NUM_COUNTERS 			0
`define NUM_SOFTWARE_REGS 		1
`define NUM_HARDWARE_REGS 		0
`define NUM_THREADS				8
`define	NUM_CORES				2
`define NUM_THREADS_PER_CORE	4

module ids
#(
	parameter DATA_WIDTH = 64,
	parameter CTRL_WIDTH = DATA_WIDTH/8,
	parameter UDP_REG_SRC_WIDTH = 2
)
(
	input  [DATA_WIDTH-1:0]             in_data,
	input  [CTRL_WIDTH-1:0]             in_ctrl,
	input                               in_wr,
	output                              in_rdy,

	output [DATA_WIDTH-1:0]             out_data,
	output [CTRL_WIDTH-1:0]             out_ctrl,
	output                              out_wr,
	input                               out_rdy,
	
	// --- Register interface
	input                               reg_req_in,
	input                               reg_ack_in,
	input                               reg_rd_wr_L_in,
	input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
	input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
	input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

	output                              reg_req_out,
	output                              reg_ack_out,
	output                              reg_rd_wr_L_out,
	output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
	output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
	output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

	// misc
	input                                reset,
	input                                clk
);

//------------------------- Signals-------------------------------

wire [DATA_WIDTH-1:0]         	in_fifo_data_p;
wire [CTRL_WIDTH-1:0]         	in_fifo_ctrl_p;
wire							cpu_done;
	
reg [DATA_WIDTH-1:0]         	in_fifo_data;
reg [CTRL_WIDTH-1:0]         	in_fifo_ctrl;

wire                          	in_fifo_nearly_full;
wire                          	in_fifo_empty;
reg                           	in_fifo_rd_en;
wire								stop_smallfifo_rd;
reg                           	out_wr_int;

reg			         			out_wr_int_next;

wire [31:0] 					memory_output_data_high;
wire [31:0] 					memory_output_data_low;
wire [31:0] 					memory_output_inst_high;
wire [31:0] 					memory_output_inst_low;
reg								enable_cpu_next, enable_cpu, enable_cpu_1, enable_cpu_2;
reg								reset_cpu_next, reset_cpu;
wire							final_dropfifo_write;
reg								dropfifo_write, dropfifo_write_next;
reg								dropfifo_write_1;
reg								dropfifo_write_2;
reg	[2:0]						current_thread_next, current_thread, current_thread_1;


// software registers 
wire [31:0]                   	dbs_cmd;
/*
wire [31:0]                   	dbs_input_inst[0:1];
wire [31:0]				    	dbs_input_inst_addr;
wire [31:0]						dbs_input_cam_entry;
wire [31:0]						dbs_input_dram_entry;
wire [31:0]						dbs_input_cam_dram_addr;
*/

// hardware registers
/*
reg [31:0]                    	dbh_output_inst[0:1];
reg [31:0]						dbh_output_cam_entry;
reg [31:0]						dbh_output_dram_entry;
reg [31:0]						dbh_datamem_data_high[0:`NUM_THREADS-1];
reg [31:0]						dbh_datamem_data_low[0:`NUM_THREADS-1];
reg	[31:0]						dbh_datamem_addr[0:`NUM_THREADS-1];
*/


// internal state
reg [1:0]                     	state, state_next;
reg                           	begin_pkt, begin_pkt_next;
reg [2:0]                     	header_counter, header_counter_next;

// local parameter
parameter                     	START = 2'b00;
parameter                     	HEADER = 2'b01;
parameter                     	PAYLOAD = 2'b10;
parameter								PROCESS = 2'b11;


//------------------------- Local assignments -------------------------------

assign in_rdy     = !in_fifo_nearly_full;
	
assign input_fifo_rd_en = in_fifo_rd_en && ~stop_smallfifo_rd;
assign final_dropfifo_write = dropfifo_write || dropfifo_write_2;
//------------------------- Modules-------------------------------

wire 	[`NUM_THREADS-1:0]	df_fifowrite;
wire 	[`NUM_THREADS-1:0]	df_begin_pkt;
wire 	[`NUM_THREADS-1:0]	df_startread;
wire 	[7:0]	df_out_ctrl [0:`NUM_THREADS-1];
wire 	[63:0]	df_out_data [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_out_wr;
wire 	[`NUM_THREADS-1:0]	df_out_wr_early;
wire 	[7:0]	df_datamem_first_addr_out [0:`NUM_THREADS-1];
wire 	[7:0]	df_datamem_last_addr_out [0:`NUM_THREADS-1];
wire 	[7:0]	df_datamem_addr_in [0:`NUM_THREADS-1];
wire 	[7:0]	temp_datamem_addr_in [0:`NUM_THREADS-1];
wire 	[63:0]	df_datamem_data_in [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_datamem_we_in ;
wire 	[63:0]	df_datamem_data_out [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_fifo_as_mem_in;
wire 	[`NUM_THREADS-1:0]	arya_start_thread;
wire 	[`NUM_THREADS-1:0]	arya_thread_busy;
wire 	[`NUM_THREADS-1:0]	arya_thread_done;
wire 	[`NUM_THREADS-1:0]	fifo_read_done;


assign df_fifo_as_mem_in = arya_thread_busy;

fallthrough_small_fifo #(
	.WIDTH(CTRL_WIDTH+DATA_WIDTH),
	.MAX_DEPTH_BITS(2)
) input_fifo (
	.din           ({in_ctrl, in_data}),   // Data in
	.wr_en         (in_wr),                // Write enable
	.rd_en         (input_fifo_rd_en),        // Read the next word 
	.dout          ({in_fifo_ctrl_p, in_fifo_data_p}),
	.full          (),
	.nearly_full   (in_fifo_nearly_full),
	.empty         (in_fifo_empty),
	.reset         (reset),
	.clk           (clk)
);
infifo_arbiter #(
	.NUM_THREADS							(`NUM_THREADS)
)in_arb(
	.clk									(clk),
	.reset								(reset),
	.firstword_in							(begin_pkt),
	.fifowrite_in							(dropfifo_write && out_wr_int),
	.enable_cpu_in							(enable_cpu_2),
	.thread_sel								(current_thread_1),
	.thread_sel_next						(current_thread),
	.thread_busy							(arya_thread_busy),
	.fifo_done								(fifo_read_done),
	.firstword_out							(df_begin_pkt),
	.fifowrite_out							(df_fifowrite),
	.enable_cpu_out							(arya_start_thread),
	.stop_smallfifo_read					(stop_smallfifo_rd)
);

wire [`NUM_THREADS*DATA_WIDTH-1:0] 	rdf_out_data;
wire [`NUM_THREADS*CTRL_WIDTH-1:0]	rdf_out_ctrl;

assign rdf_out_data = {df_out_data[7],df_out_data[6],df_out_data[5],df_out_data[4],df_out_data[3],df_out_data[2],df_out_data[1],df_out_data[0]};
assign rdf_out_ctrl = {df_out_ctrl[7],df_out_ctrl[6],df_out_ctrl[5],df_out_ctrl[4],df_out_ctrl[3],df_out_ctrl[2],df_out_ctrl[1],df_out_ctrl[0]};

outfifo_arbiter out_arb(
    .clk									(clk),
    .reset									(reset),
	.thread_done							(arya_thread_done),
    .df_out_data_in							(rdf_out_data),
    .df_out_ctrl_in							(rdf_out_ctrl),
    .df_out_wr_in							(df_out_wr),
	.df_out_wr_early_in						(df_out_wr_early),
	.fifo_start_read_next					(df_startread),
    .out_data_out							(out_data),
    .out_ctrl_out							(out_ctrl),
    .out_wr_out								(out_wr),
	.out_rdy								(out_rdy),
	.fifo_read_done								(fifo_read_done)
    );

reg [DATA_WIDTH-1:0]arya_datamem_data_in [0:1];
wire [1:0] arya_thread_id_out [0:1];
wire [1:0] previous_thread_id_out [0:1];

assign previous_thread_id_out[0] = arya_thread_id_out[0];
assign previous_thread_id_out[1] = arya_thread_id_out[1];

 
	genvar j;
	generate
		for (j=0; j<`NUM_CORES; j=j+1) begin : cpu
		arya #(
		.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH					(DATA_WIDTH),
		.MEM_ADDR_WIDTH					(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH				(`REGFILE_ADDR_WIDTH),
		.NUM_THREADS			(`NUM_THREADS_PER_CORE)
		) core (
		.clk							(clk),
		.en								(1),			// Forcing it to be one.
		.reset							(reset),
		.debug_commands					(dbs_cmd[(j+7)*`NUM_THREADS_PER_CORE-1:(j+6)*`NUM_THREADS_PER_CORE]),
//		.debug_on						(dbs_cmd[23]),
		.debug_on						(0),
		// For all threads
		.start_thread					(arya_start_thread[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//input pulse
		.thread_busy					(arya_thread_busy[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//output high
		.thread_done					(arya_thread_done[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//output pulse to use as lastword
		.inst_addr_in					(),
		.inst_data_in					(),
		.setup_mem						(),
		.verify_mem						(),
		.inst_data_out					(),
		.datamem_data_in				(arya_datamem_data_in[j]),
		.datamem_addr_out				({temp_datamem_addr_in[j*4 + 3],temp_datamem_addr_in[j*4 + 2],temp_datamem_addr_in[j*4 + 1],temp_datamem_addr_in[j*4 + 0]}),
		.datamem_data_out				({df_datamem_data_in[j*4 + 3],df_datamem_data_in[j*4 + 2],df_datamem_data_in[j*4 + 1],df_datamem_data_in[j*4 + 0]}),
		.datamem_we_out				({df_datamem_we_in[j*4 + 3],df_datamem_we_in[j*4 + 2],df_datamem_we_in[j*4 + 1],df_datamem_we_in[j*4 + 0]}),
		.thread_id_out					(arya_thread_id_out[j])
		);
		

		end // for
	endgenerate

	always @(previous_thread_id_out[0]) begin
	case (previous_thread_id_out[0])
		'b00: begin
			arya_datamem_data_in[0] = df_datamem_data_out[0];
		end
		'b01: begin
			arya_datamem_data_in[0] = df_datamem_data_out[1];
		end
		'b10: begin
			arya_datamem_data_in[0] = df_datamem_data_out[2];
		end
		'b11: begin
			arya_datamem_data_in[0] = df_datamem_data_out[3];
		end
	endcase
end

always @(previous_thread_id_out[1]) begin
	case (previous_thread_id_out[1])
		'b00: begin
			arya_datamem_data_in[1] = df_datamem_data_out[4];
		end
		'b01: begin
			arya_datamem_data_in[1] = df_datamem_data_out[5];
		end
		'b10: begin
			arya_datamem_data_in[1] = df_datamem_data_out[6];
		end
		'b11: begin
			arya_datamem_data_in[1] = df_datamem_data_out[7];
		end
	endcase
end

	genvar i;
	generate
		for (i=0; i<`NUM_THREADS; i=i+1) begin: fifo
		
		
 assign df_datamem_addr_in[i] = temp_datamem_addr_in[i] + df_datamem_first_addr_out[i];
		
		dropfifo  #(
		.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH				(DATA_WIDTH),
		.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
		) df (
		.clk           				(clk), 
		.drop_pkt      				(0),  		// Functionality not required
		.fiforead      				(out_rdy), 
		.fifowrite     				(df_fifowrite[i]), 
		.firstword     				(df_begin_pkt[i]), 
		.in_fifo       				({in_fifo_ctrl,in_fifo_data}), 
		.lastword					(df_startread[i]),
		.rst           				(reset), 
		.out_fifo      				({df_out_ctrl[i],df_out_data[i]}), 
		.valid_data    				(df_out_wr[i]),
		.valid_data_early			(df_out_wr_early[i]),
		.datamem_first_addr			(df_datamem_first_addr_out[i]),
		.datamem_last_addr			(df_datamem_last_addr_out[i]),
		.datamem_addr_in			(df_datamem_addr_in[i]),
		.datamem_data_in			(df_datamem_data_in[i]),
		.datamem_we					(df_datamem_we_in[i]),
		.datamem_data_out			(df_datamem_data_out[i]),
		.fifo_as_mem				(df_fifo_as_mem_in[i])			// Signal to muxes
		//.fifo_as_mem				(0)
		);	
		end
	endgenerate

	generic_regs
#( 
	.UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
	.TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
	.REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
	.NUM_COUNTERS        (`NUM_COUNTERS),                 // Number of counters
	.NUM_SOFTWARE_REGS   (`NUM_SOFTWARE_REGS),                 // Number of sw regs
	.NUM_HARDWARE_REGS   (`NUM_HARDWARE_REGS)                  // Number of hw regs
) module_regs (
	.reg_req_in       (reg_req_in),
	.reg_ack_in       (reg_ack_in),
	.reg_rd_wr_L_in   (reg_rd_wr_L_in),
	.reg_addr_in      (reg_addr_in),
	.reg_data_in      (reg_data_in),
	.reg_src_in       (reg_src_in),

	.reg_req_out      (reg_req_out),
	.reg_ack_out      (reg_ack_out),
	.reg_rd_wr_L_out  (reg_rd_wr_L_out),
	.reg_addr_out     (reg_addr_out),
	.reg_data_out     (reg_data_out),
	.reg_src_out      (reg_src_out),

	// --- counters interface
	.counter_updates  (),
	.counter_decrement(),

	// --- SW regs interface
	.software_regs    ({dbs_cmd}),

	// --- HW regs interface
	.hardware_regs    (),


	.clk              (clk),
	.reset            (reset)
	);

//------------------------- Logic-------------------------------

always @(*) begin
	state_next = state;
	header_counter_next = header_counter;
	in_fifo_rd_en = 0;
	out_wr_int_next = 0;
	begin_pkt_next = begin_pkt;
	enable_cpu_next = enable_cpu;
	reset_cpu_next = reset_cpu;
	dropfifo_write_next = dropfifo_write;
	current_thread_next = current_thread;
	
	if (!in_fifo_empty && out_rdy) begin
		out_wr_int_next = 1;
		in_fifo_rd_en = 1;
		//out_data = in_fifo_data;
		
		case(state)
			START: begin
			enable_cpu_next = 0;
			dropfifo_write_next = 0;
			if (~stop_smallfifo_rd) begin
			if (in_fifo_ctrl_p != 0) begin
				state_next = HEADER;
				begin_pkt_next = 1;
				dropfifo_write_next = 1;
			end // if (in_fifo_ctrl_p != 0)
			end // if (~stop_smallfifo_rd)
			end // START
			HEADER: begin
			begin_pkt_next = 0;
			if (in_fifo_ctrl_p == 0) begin
				header_counter_next = header_counter + 1'b1;
				if (header_counter_next == 3) begin
					state_next = PAYLOAD;
				end
			end
			end // HEADER
			PAYLOAD: begin
			if (in_fifo_ctrl_p != 0) begin
				state_next = START;
				header_counter_next = 0;
				enable_cpu_next = 1;
				current_thread_next = current_thread_next + 1;
			end // if (in_fifo_ctrl_p !=0)
			end // PAYLOAD
		endcase // case(state)
	end
end // always @ (*)

always @(posedge clk) begin
	if(reset) begin
		header_counter <= 0;
		state <= START;
		begin_pkt <= 0;
		in_fifo_ctrl <= 0;
		in_fifo_data <= 0;
		enable_cpu <= 0;
		enable_cpu_1 <= 0;
		enable_cpu_2 <= 0;
		reset_cpu <= 0;
		dropfifo_write <= 0;
		dropfifo_write_1 <= 0;
		dropfifo_write_2 <= 0;
		current_thread <= 0;
		current_thread_1 <= 0; 
	end
	else begin
		//if (dbs_cmd[0]) dbh_step_count <= 0;
		//else dbh_step_count <= dbh_step_count + 1;
		header_counter <= header_counter_next;
		state <= state_next;
		begin_pkt <= begin_pkt_next;
		begin_pkt <= begin_pkt_next;
		begin_pkt <= begin_pkt_next;
		in_fifo_ctrl <= in_fifo_ctrl_p;
		in_fifo_data <= in_fifo_data_p;
		out_wr_int <= out_wr_int_next;
		enable_cpu <= enable_cpu_next;
		enable_cpu_1 <= enable_cpu;
		enable_cpu_2 <= enable_cpu_1;
		reset_cpu <= reset_cpu_next;
		dropfifo_write <= dropfifo_write_next;
		dropfifo_write_1 <= dropfifo_write;
		dropfifo_write_2 <= dropfifo_write_1;
		current_thread <= current_thread_next;
		current_thread_1 <= current_thread;
			
	end // else: !if(reset)
end // always @ (posedge clk)   

endmodule 
