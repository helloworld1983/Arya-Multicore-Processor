//////////////////////////////////
////// SOFTWARE REGS ////////////
//////////////////////////////////
// dbs_cmd [0] 	= send a reset
// dbs_cmd [1] 	= setup memory
// dbs_cmd [2] 	= verify mem
// dbs_cmd [3]  	= set debug mode on
// dbs_cmd [4] 	= enable stepinto
// dbs_cmd [5] 	= stepvalue bit 0
// dbs_cmd [6] 	= stepvalue bit 1
// dbs_cmd [7] 	= stepvalue bit 2
// dbs_cmd [8] 	= reset step count
// dbs_cmd [9] 	= enable mem
// dbs_cmd [10] 	= unused
// dbs_cmd [11] 	= unused
// dbs_cmd [12] 	= unused
// dbs_cmd [13] 	= unused
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

`define REGFILE_ADDR_WIDTH 	3
`define MEM_ADDR_WIDTH 			8
`define INST_ADDR_WIDTH 		8
`define NUM_COUNTERS 			0
`define NUM_SOFTWARE_REGS 		4
`define NUM_HARDWARE_REGS 		3
`define NUM_THREADS				8
`define	NUM_CORES				2


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
reg 							stop_small_fifo_rd_nxt;
reg								stop_small_fifo_rd;
reg								stop_small_fifo_rd_d;
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
reg	[2:0]							current_thread_next, current_thread;


// software registers 
wire [31:0]                   	dbs_cmd;
//wire [31:0]                   	dbs_input_data_high;
//wire [31:0]                   	dbs_input_data_low;
//wire [31:0]				    	dbs_input_data_addr;
wire [31:0]                   	dbs_input_inst_high;
wire [31:0]                   	dbs_input_inst_low;
wire [31:0]				    	dbs_input_inst_addr;

// hardware registers
//reg [31:0]                    	dbh_output_data_high;
//reg [31:0]					  	dbh_output_data_low;
reg [31:0]                    	dbh_output_inst_high;
reg [31:0]					  	dbh_output_inst_low;
reg [31:0]					  	dbh_step_count;



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
	
assign input_fifo_rd_en = in_fifo_rd_en && ~stop_small_fifo_rd_nxt;
assign final_dropfifo_write = dropfifo_write || dropfifo_write_2;
//------------------------- Modules-------------------------------

wire 	[`NUM_THREADS-1:0]	df_fifowrite;
wire 	[`NUM_THREADS-1:0]	df_begin_pkt;
wire 	[`NUM_THREADS-1:0]	df_startread;
wire 	[7:0]	df_out_ctrl [0:`NUM_THREADS-1];
wire 	[63:0]	df_out_data [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_out_wr;
wire 	[7:0]	df_datamem_first_addr_out [0:`NUM_THREADS-1];
wire 	[7:0]	df_datamem_last_addr_out [0:`NUM_THREADS-1];
wire 	[7:0]	df_datamem_addr_in [0:`NUM_THREADS-1];
wire 	[63:0]	df_datamem_data_in [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_datamem_we_in ;
wire 	[63:0]	df_datamem_data_out [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_fifo_as_mem_in;
wire 	[`NUM_THREADS-1:0]	arya_start_thread;
wire 	[`NUM_THREADS-1:0]	arya_thread_busy;
wire 	[`NUM_THREADS-1:0]	arya_thread_done;


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
	.firstword_in							(begin_pkt),
	.fifowrite_in							(dropfifo_write),
	.enable_cpu_in							(enable_cpu_2),
	.thread_sel								(current_thread),
	.firstword_out							(df_begin_pkt),
	.fifowrite_out							(df_fifowrite),
	.enable_cpu_out							(arya_start_thread)
);

wire [`NUM_THREADS*64-1:0] 	rdf_out_data;
wire [`NUM_THREADS*8-1:0]	rdf_out_ctrl;

assign rdf_out_data = {df_out_data[7],df_out_data[6],df_out_data[5],df_out_data[4],df_out_data[3],df_out_data[2],df_out_data[1],df_out_data[0]};
assign rdf_out_ctrl = {df_out_ctrl[7],df_out_ctrl[6],df_out_ctrl[5],df_out_ctrl[4],df_out_ctrl[3],df_out_ctrl[2],df_out_ctrl[1],df_out_ctrl[0]};

outfifo_arbiter out_arb(
    .clk									(clk),
    .reset									(reset),
	.thread_done							(arya_thread_done),
    .df_out_data_in							(rdf_out_data),
    .df_out_ctrl_in							(rdf_out_ctrl),
    .df_out_wr_in							(df_out_wr),
	.fifo_start_read_next					(df_startread),
    .out_data_out							(out_data),
    .out_ctrl_out							(out_ctrl),
    .out_wr_out								(out_wr)
    );

	genvar j;
	generate
		for (j=0; j<`NUM_CORES; j=j+1) begin : cpu
		dummy_arya #(
		.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH					(DATA_WIDTH),
		.MEM_ADDR_WIDTH					(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH				(`REGFILE_ADDR_WIDTH)
		) core_1 (
		.clk							(clk),
		.en								(1),			// Forcing it to be one.
		.reset							(reset),
		// For all threads
		.start_thread					(arya_start_thread[(j+1)*4-1:j*4]),	//input pulse
		.thread_busy					(arya_thread_busy[(j+1)*4-1:j*4]),	//output high
		.thread_done					(arya_thread_done[(j+1)*4-1:j*4])	//output pulse to use as lastword
		);
		end
	endgenerate

	genvar i;
	generate
		for (i=0; i<`NUM_THREADS; i=i+1) begin: fifo
		
		dropfifo  #(
		.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH				(DATA_WIDTH),
		.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
		) drop_fifo_0 (
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
		.datamem_first_addr			(df_datamem_first_addr_out[i]),
		.datamem_last_addr			(df_datamem_last_addr_out[i]),
		.datamem_addr_in			(df_datamem_addr_in[i]),
		.datamem_data_in			(df_datamem_data_in[i]),
		.datamem_we					(df_datamem_we_in[i]),
		.datamem_data_out			(df_datamem_data_out[i]),
		.fifo_as_mem				(df_fifo_as_mem_in[i])			// Signal to muxes
		);	
		end
	endgenerate

/*
    dropfifo  #(
	.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) drop_fifo_0 (
	.clk           				(clk), 
	.drop_pkt      				(0),  		// Functionality not required
	.fiforead      				(df0_out_rdy), 
	.fifowrite     				(df0_fifowrite), 
	.firstword     				(df0_begin_pkt), 
	.in_fifo       				({df0_in_fifo_ctrl,df0_in_fifo_data}), 
	//.lastword      				(arya_cpu_done), 
	.lastword					(df0_startread),
	.rst           				(reset), 
	.out_fifo      				({df0_out_ctrl,df0_out_data}), 
	.valid_data    				(df0_out_wr),
	.datamem_first_addr			(df0_datamem_first_addr_out),
	.datamem_last_addr			(df0_datamem_last_addr_out),
	.datamem_addr_in				(df0_datamem_addr_in),
	.datamem_data_in				(df0_datamem_data_in),
	.datamem_we						(df0_datamem_we_in),
	.datamem_data_out				(df0_datamem_data_out),
	.fifo_as_mem					(df0_fifo_as_mem_in)			// Signal to muxes
);

    dropfifo  #(
	.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) drop_fifo_1 (
	.clk           				(clk), 
	.drop_pkt      				(0),  		// Functionality not required
	.fiforead      				(df1_out_rdy), 
	.fifowrite     				(df1_fifowrite), 
	.firstword     				(df1_begin_pkt), 
	.in_fifo       				({df1_in_fifo_ctrl,df1_in_fifo_data}), 
	//.lastword      				(arya_cpu_done), 
	.lastword						(df1_startread),
	.rst           				(reset), 
	.out_fifo      				({df1_out_ctrl,df1_out_data}), 
	.valid_data    				(df1_out_wr),
	.datamem_first_addr			(df1_datamem_first_addr_out),
	.datamem_last_addr			(df1_datamem_last_addr_out),
	.datamem_addr_in				(df1_datamem_addr_in),
	.datamem_data_in				(df1_datamem_data_in),
	.datamem_we						(df1_datamem_we_in),
	.datamem_data_out				(df1_datamem_data_out),
	.fifo_as_mem					(df1_fifo_as_mem_in)			// Signal to muxes
);

    dropfifo  #(
	.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) drop_fifo_2 (
	.clk           				(clk), 
	.drop_pkt      				(0),  		// Functionality not required
	.fiforead      				(df2_out_rdy), 
	.fifowrite     				(df2_fifowrite), 
	.firstword     				(df2_begin_pkt), 
	.in_fifo       				({df2_in_fifo_ctrl,df2_in_fifo_data}), 
	//.lastword      				(arya_cpu_done), 
	.lastword						(df2_startread),
	.rst           				(reset), 
	.out_fifo      				({df2_out_ctrl,df2_out_data}), 
	.valid_data    				(df2_out_wr),
	.datamem_first_addr			(df2_datamem_first_addr_out),
	.datamem_last_addr			(df2_datamem_last_addr_out),
	.datamem_addr_in				(df2_datamem_addr_in),
	.datamem_data_in				(df2_datamem_data_in),
	.datamem_we						(df2_datamem_we_in),
	.datamem_data_out				(df2_datamem_data_out),
	.fifo_as_mem					(df2_fifo_as_mem_in)			// Signal to muxes
);

    dropfifo  #(
	.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) drop_fifo_3 (
	.clk           				(clk), 
	.drop_pkt      				(0),  		// Functionality not required
	.fiforead      				(df3_out_rdy), 
	.fifowrite     				(df3_fifowrite), 
	.firstword     				(df3_begin_pkt), 
	.in_fifo       				({df3_in_fifo_ctrl,df3_in_fifo_data}), 
	//.lastword      				(arya_cpu_done), 
	.lastword						(df3_startread),
	.rst           				(reset), 
	.out_fifo      				({df3_out_ctrl,df3_out_data}), 
	.valid_data    				(df3_out_wr),
	.datamem_first_addr			(df3_datamem_first_addr_out),
	.datamem_last_addr			(df3_datamem_last_addr_out),
	.datamem_addr_in				(df3_datamem_addr_in),
	.datamem_data_in				(df3_datamem_data_in),
	.datamem_we						(df3_datamem_we_in),
	.datamem_data_out				(df3_datamem_data_out),
	.fifo_as_mem					(df3_fifo_as_mem_in)			// Signal to muxes
);

*/
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
	.software_regs    ({dbs_input_inst_addr,dbs_input_inst_low,dbs_input_inst_high,dbs_cmd}),

	// --- HW regs interface
	.hardware_regs    ({dbh_step_count,dbh_output_inst_low,dbh_output_inst_high}),


	.clk              (clk),
	.reset            (reset)
	);

//------------------------- Logic-------------------------------

always @(*) begin
	state_next = state;
	header_counter_next = header_counter;
	in_fifo_rd_en = 0;
	stop_small_fifo_rd_nxt = stop_small_fifo_rd;
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
			if (in_fifo_ctrl_p != 0) begin
				state_next = HEADER;
				begin_pkt_next = 1;
				dropfifo_write_next = 1;
			end // if (in_fifo_ctrl_p != 0)
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
		stop_small_fifo_rd <= 0;
		stop_small_fifo_rd_d <= 0;
		//dbh_output_data_high <= 0;
		//dbh_output_data_low <= 0;
		dbh_output_inst_high <= 0;
		dbh_output_inst_low <= 0;
		enable_cpu <= 0;
		enable_cpu_1 <= 0;
		enable_cpu_2 <= 0;
		reset_cpu <= 0;
		dropfifo_write <= 0;
		dropfifo_write_1 <= 0;
		dropfifo_write_2 <= 0;
		current_thread <= 0;
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
		stop_small_fifo_rd <= stop_small_fifo_rd_nxt;
		stop_small_fifo_rd_d <= stop_small_fifo_rd;
		//dbh_output_inst_high <= memory_output_inst_high;
		//dbh_output_inst_low <= memory_output_inst_low;
		dbh_output_inst_high <= memory_output_inst_high;
		dbh_output_inst_low <= memory_output_inst_low;
		enable_cpu <= enable_cpu_next;
		enable_cpu_1 <= enable_cpu;
		enable_cpu_2 <= enable_cpu_1;
		reset_cpu <= reset_cpu_next;
		dropfifo_write <= dropfifo_write_next;
		dropfifo_write_1 <= dropfifo_write;
		dropfifo_write_2 <= dropfifo_write_1;
		current_thread <= current_thread_next;
			
	end // else: !if(reset)
end // always @ (posedge clk)   

endmodule 
