
`timescale 1ns/1ps
// defines

`define REGFILE_ADDR_WIDTH 		4
`define MEM_ADDR_WIDTH 			8
`define INST_ADDR_WIDTH 		7
`define NUM_COUNTERS 			0
`define NUM_SOFTWARE_REGS 		14
`define NUM_HARDWARE_REGS 		6
`define NUM_THREADS				4
`define	NUM_CORES				2
`define NUM_THREADS_PER_CORE	2
`define INST_WIDTH				32
`define FT_COUNTER_ADDR_WIDTH   4
`define NUM_ACTIONS				8
`define THREAD_BITS_PER_CORE	1
`define THREAD_BITS				2
`define FT_ADDR_WIDTH			4
`define FT_DEPTH				16

module ids
#(
	parameter DATA_WIDTH = 64,
	parameter CTRL_WIDTH = DATA_WIDTH/8,
	parameter UDP_REG_SRC_WIDTH = 2,
	parameter param_pattern_high = 32'h7F313131,
	parameter param_pattern_low  = 32'h31313131
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
wire							stop_smallfifo_rd;
reg                           	out_wr_int;

reg			         			out_wr_int_next;


reg								enable_cpu_next, enable_cpu, enable_cpu_1, enable_cpu_2;
reg								reset_cpu_next, reset_cpu;
wire							final_dropfifo_write;
reg								dropfifo_write, dropfifo_write_next;
reg								dropfifo_write_1;
reg								dropfifo_write_2;
reg	[`THREAD_BITS-1:0]			current_thread_next, current_thread, current_thread_1;


wire [(`INST_ADDR_WIDTH - 1) + 2:0]	input_inst_addr[0:`NUM_CORES-1];
wire [31:0]	input_inst[0:`NUM_CORES-1];
wire    cmd_setup_mem [0:`NUM_CORES-1];

reg  [31:0]                 	num_packets_in_next;
wire [31:0] 					halt_counter[0:`NUM_CORES-1];
wire [31:0]						output_inst[0:`NUM_CORES-1];
reg [31:0] 						pattern_matches;

// software registers 
wire [31:0]                		dbs_cmd_0;
wire [31:0]                		dbs_cmd_1;
wire [31:0]				    	dbs_input_inst_addr_0;
wire [31:0]				    	dbs_input_inst_0;
wire [31:0]				    	dbs_input_inst_addr_1;
wire [31:0]				    	dbs_input_inst_1;
wire [31:0]						dbs_counter_read_addr;
wire [31:0]						dbs_ft_ip;
wire [31:0]						dbs_ft_action;
wire [31:0]						dbs_ft_addr;
wire [31:0] 					dbs_compare_ip_in;
wire [31:0]						dbs_pattern_high;
wire [31:0]						dbs_pattern_low;
wire [31:0]						dbs_input_port;


// hardware registers
reg [31:0]                    	dbh_output_inst_0;
reg [31:0]                    	dbh_output_inst_1;
reg [31:0]                      dbh_num_packets_in;
reg [31:0]						dbh_ft_count_output;
reg [31:0]						dbh_num_matches;
reg [31:0] 						dbh_pattern_matches;

// internal state
reg [1:0]                     	state, state_next;
reg                           	begin_pkt, begin_pkt_next;
reg [2:0]                     	header_counter, header_counter_next;

// local parameter
parameter                     	START = 2'b00;
parameter                     	HEADER = 2'b01;
parameter                     	PAYLOAD = 2'b10;


//------------------------- Local assignments -------------------------------

wire 	[`NUM_THREADS-1:0]	df_fifowrite;
wire 	[`NUM_THREADS-1:0]	df_begin_pkt;
wire 	[`NUM_THREADS-1:0]	df_startread;
wire 	[CTRL_WIDTH-1:0]	df_out_ctrl [0:`NUM_THREADS-1];
wire 	[DATA_WIDTH-1:0]	df_out_data [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_out_wr;
wire 	[`NUM_THREADS-1:0]	df_out_wr_early;
wire 	[`MEM_ADDR_WIDTH-1:0]	df_datamem_first_addr_out [0:`NUM_THREADS-1];
wire 	[`MEM_ADDR_WIDTH-1:0]	df_datamem_last_addr_out [0:`NUM_THREADS-1];
wire 	[`MEM_ADDR_WIDTH-1:0]	df_datamem_addr_in [0:`NUM_THREADS-1];
wire 	[`MEM_ADDR_WIDTH-1:0]	temp_datamem_addr_in [0:`NUM_THREADS-1];
wire 	[`MEM_ADDR_WIDTH*`NUM_THREADS_PER_CORE-1:0]	arya_datamem_addr_out [0:`NUM_CORES-1];
wire 	[DATA_WIDTH-1:0]	df_datamem_data_in [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_datamem_we_in ;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out [0:`NUM_THREADS-1];
wire 	[`NUM_THREADS-1:0]	df_fifo_as_mem_in;
wire 	[`NUM_THREADS-1:0]	arya_start_thread;
wire 	[`NUM_THREADS-1:0]	arya_thread_busy;
wire 	[`NUM_THREADS-1:0]	arya_thread_done;
wire 	[`NUM_THREADS-1:0]	fifo_read_done;
wire 	[`NUM_THREADS*DATA_WIDTH-1:0] 	rdf_out_data;
wire 	[`NUM_THREADS*CTRL_WIDTH-1:0]	rdf_out_ctrl;
wire	[DATA_WIDTH*`NUM_THREADS_PER_CORE-1:0] arya_datamem_data_out [0:`NUM_CORES-1];
wire	[`NUM_THREADS_PER_CORE-1:0] arya_datamem_we_out [0:`NUM_CORES-1];


/* Matcher Wires */
wire matcher_en;
wire matcher_ce;
wire matcher_reset;
reg [31:0]                    matches_next;
reg                           in_pkt_body, in_pkt_body_next;
reg                           end_of_pkt, end_of_pkt_next;

assign matcher_en = (!in_fifo_empty && out_rdy && in_pkt_body);
assign matcher_ce = (!in_fifo_empty && out_rdy);
assign matcher_reset = (reset ||  end_of_pkt);


assign input_inst_addr[0] = dbs_input_inst_addr_0[(`INST_ADDR_WIDTH-1) + 2:0];
assign input_inst[0] = dbs_input_inst_0;
assign cmd_setup_mem[0] = dbs_cmd_0[1];

assign input_inst_addr[1] = dbs_input_inst_addr_1[(`INST_ADDR_WIDTH-1) + 2:0];
assign input_inst[1] = dbs_input_inst_1;
assign cmd_setup_mem[1] = dbs_cmd_1[1];

assign in_rdy     = !in_fifo_nearly_full;
assign input_fifo_rd_en = in_fifo_rd_en && ~stop_smallfifo_rd;
assign final_dropfifo_write = dropfifo_write || dropfifo_write_2;
assign df_fifo_as_mem_in = arya_thread_busy;

assign rdf_out_data = {df_out_data[3],df_out_data[2],df_out_data[1],df_out_data[0]};
assign rdf_out_ctrl = {df_out_ctrl[3],df_out_ctrl[2],df_out_ctrl[1],df_out_ctrl[0]};

//------------------------- Modules-------------------------------




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

   detect7B matcher (
      .ce            (matcher_ce),           // data enable
      .match_en      (matcher_en),           // match enable
      .clk           (clk),
      .pipe1         ({in_fifo_ctrl, in_fifo_data}),   // Data in
      .hwregA        ({dbs_pattern_high, dbs_pattern_low}),   // pattern in
//      .hwregA        ({param_pattern_high, param_pattern_low}),   // pattern in
      .match         (matcher_match),        // match out
      .mrst          (matcher_reset)         // reset in
   );
   
   
infifo_arbiter #(
	.NUM_THREADS							(`NUM_THREADS),
	.THREAD_BITS							(`THREAD_BITS)
)in_arb(
	.clk									(clk),
	.reset									(reset),
	.firstword_in							(begin_pkt),
	.fifowrite_in							(dropfifo_write && out_wr_int),
	.enable_cpu_in							(enable_cpu_2),
	.thread_sel								(current_thread_1),
	.thread_sel_next						(current_thread),
	.fifo_done								(fifo_read_done),
	.firstword_out							(df_begin_pkt),
	.fifowrite_out							(df_fifowrite),
	.enable_cpu_out							(arya_start_thread),
	.stop_smallfifo_read					(stop_smallfifo_rd)
);



outfifo_arbiter #(
	.NUM_THREADS							(`NUM_THREADS),
	.DATAPATH_WIDTH							(DATA_WIDTH),
	.CTRL_WIDTH								(CTRL_WIDTH),
	.THREAD_BITS							(`THREAD_BITS)
) out_fifo(
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
	.fifo_read_done							(fifo_read_done)
    );

wire [DATA_WIDTH-1:0]arya_datamem_data_in [0:`NUM_CORES-1];
wire [`NUM_THREADS_PER_CORE-1:0] arya_thread_id_out [0:`NUM_CORES-1];
wire [`THREAD_BITS_PER_CORE-1:0] previous_thread_id_out_0;
wire [`THREAD_BITS_PER_CORE-1:0] previous_thread_id_out_1;

wire [31:0] output_inst_high [0:`NUM_CORES-1];
wire [31:0] output_inst_low [0:`NUM_CORES-1];

assign previous_thread_id_out_0 = arya_thread_id_out[0];
assign previous_thread_id_out_1 = arya_thread_id_out[1];

wire [`NUM_THREADS_PER_CORE-1:0] action_thread_id_in [0:`NUM_CORES-1];
wire [`NUM_ACTIONS-1:0] action_out;
wire action_done;
wire [`THREAD_BITS-1:0] action_thread_id;
wire [`NUM_CORES-1:0] arya_action_done;
wire [31:0] ft_count_output;
reg [DATA_WIDTH-1:0] source_ip,source_ip_next;
reg [DATA_WIDTH-1:0] start_in_next,start_in;
	
assign arya_action_done[0] = end_of_pkt && ~action_thread_id[`THREAD_BITS-1];
assign arya_action_done[1] = end_of_pkt && action_thread_id[`THREAD_BITS-1];
	
	
	genvar j;
	genvar i;
	generate
		for (j=0; j<`NUM_CORES; j=j+1) begin : cpu
		arya #(
		.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH					(DATA_WIDTH),
		.MEM_ADDR_WIDTH					(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH				(`REGFILE_ADDR_WIDTH),
		.NUM_THREADS_PER_CORE			(`NUM_THREADS_PER_CORE),
		.INST_WIDTH						(`INST_WIDTH),
		.NUM_ACTIONS					(`NUM_ACTIONS),
		.THREAD_BITS					(`THREAD_BITS_PER_CORE)
		) core (
		.clk							(clk),
		.en								(1),			// Forcing it to be one.
		.reset							(reset),
        .debug_commands                 (0),
		// For all threads
		.start_thread					(arya_start_thread[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//input pulse
		.thread_busy					(arya_thread_busy[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//output high
		.thread_done					(arya_thread_done[(j+1)*`NUM_THREADS_PER_CORE-1:j*`NUM_THREADS_PER_CORE]),	//output pulse to use as lastword
		.inst_addr_in					(input_inst_addr[j]),
		.inst_data_in					(input_inst[j]),
		.setup_mem						(cmd_setup_mem[j]),
		//.setup_mem						(0),
		.action_data_in					(action_out),
		.action_wen						(arya_action_done[j]),
		.action_thread_id_in			(action_thread_id),
		.inst_data_out					(output_inst[j]),
		.datamem_data_in				(arya_datamem_data_in[j]),
		//.datamem_addr_out				({temp_datamem_addr_in[j*4 + 3],temp_datamem_addr_in[j*4 + 2],temp_datamem_addr_in[j*4 + 1],temp_datamem_addr_in[j*4 + 0]}),
		.datamem_addr_out				(arya_datamem_addr_out[j]),
		//.datamem_data_out				({df_datamem_data_in[j*4 + 3],df_datamem_data_in[j*4 + 2],df_datamem_data_in[j*4 + 1],df_datamem_data_in[j*4 + 0]}),
		.datamem_data_out				(arya_datamem_data_out[j]),
		//.datamem_we_out				    ({df_datamem_we_in[j*4 + 3],df_datamem_we_in[j*4 + 2],df_datamem_we_in[j*4 + 1],df_datamem_we_in[j*4 + 0]}),
		.datamem_we_out					(arya_datamem_we_out[j]),
		.thread_id_out					(arya_thread_id_out[j]),
		.halt_counter_out				(halt_counter[j])
		);
		

		end // for
	endgenerate
	
	generate
	for (i=0; i<`NUM_CORES; i=i+1) begin : I
		for (j=0; j<`NUM_THREADS_PER_CORE; j=j+1) begin : ASSIGNS
			assign temp_datamem_addr_in[i*`NUM_THREADS_PER_CORE+j] = arya_datamem_addr_out[i][(j+1)*`MEM_ADDR_WIDTH-1:j*`MEM_ADDR_WIDTH];
			assign df_datamem_data_in[i*`NUM_THREADS_PER_CORE+j] = arya_datamem_data_out[i][(j+1)*DATA_WIDTH-1:j*DATA_WIDTH];
			assign df_datamem_we_in[i*`NUM_THREADS_PER_CORE+j] = arya_datamem_we_out[i][(j+1)-1:j];
		end // for
	end // for
	endgenerate
	
	
	
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_0;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_1;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_2;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_3;

assign df_datamem_data_out_0 = df_datamem_data_out[0];
assign df_datamem_data_out_1 = df_datamem_data_out[1];
assign df_datamem_data_out_2 = df_datamem_data_out[2];
assign df_datamem_data_out_3 = df_datamem_data_out[3];

reg [DATA_WIDTH-1:0] arya_datamem_data_in_0;
reg [DATA_WIDTH-1:0] arya_datamem_data_in_1;

assign arya_datamem_data_in[0] = arya_datamem_data_in_0;
assign arya_datamem_data_in[1] = arya_datamem_data_in_1;


 	always @(*) begin
	case (previous_thread_id_out_0)
		'b0: begin
			arya_datamem_data_in_0 = df_datamem_data_out_0;
		end
		'b1: begin
			arya_datamem_data_in_0 = df_datamem_data_out_1;
		end
	endcase
	
	case (previous_thread_id_out_1)
		'b0: begin
			arya_datamem_data_in_1 = df_datamem_data_out_2;
		end
		'b1: begin
			arya_datamem_data_in_1 = df_datamem_data_out_3;
		end
	endcase
end


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
		.input_port					(dbs_input_port[15:0]),
        .input_port_en              (dbs_input_port[16]),
		//.input_port					(01010101),
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
	
	wire [31:0] ip_in;
	wire match_true;
	reg [31:0] num_matches;
	assign ip_in = source_ip[47:16];
	
	/// accelerator ///////
	accelerator #(
	.FT_ADDR_WIDTH 			(`FT_ADDR_WIDTH),
	.FT_DEPTH				(`FT_DEPTH),
	.NUM_ACTIONS			(`NUM_ACTIONS),
	.NUM_THREADS			(`NUM_THREADS),
	.THREAD_BITS			(`THREAD_BITS)
	)
	accelerator_1 (
	.clk							(clk),
	.reset							(reset),
	.ip_in							(ip_in),
	.thread_id_in					(current_thread),
	.start_in						(start_in),
	.counter_rd_addr_in				(dbs_counter_read_addr[`FT_ADDR_WIDTH-1:0]),
	.read_counter					(dbs_counter_read_addr[`FT_ADDR_WIDTH]),
	//.read_counter					(0),
	.ft_ip							(dbs_ft_ip),
	.ft_action						(dbs_ft_action),
	.ft_addr						(dbs_ft_addr[`FT_ADDR_WIDTH-1:0]),
	.setup_ft						(dbs_ft_addr[`FT_ADDR_WIDTH]),
	//.setup_ft						(0),
	.action_out						(action_out),
	.thread_id_out					(action_thread_id),
	.acc_done						(action_done),
	.count_out						(ft_count_output),
	.end_of_pkt						(end_of_pkt),
	.dpi_true						(dbs_compare_ip_in[0]),
	.matcher_match					(matcher_match),
	.match_true						(match_true)
	);
	/// accelerator ///////
	
	
	
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
	.software_regs    ({dbs_input_port, dbs_pattern_low, dbs_pattern_high, dbs_compare_ip_in,dbs_ft_addr, dbs_ft_action, dbs_ft_ip, dbs_counter_read_addr, dbs_input_inst_1,dbs_input_inst_addr_1,dbs_input_inst_0,dbs_input_inst_addr_0,dbs_cmd_1,dbs_cmd_0}),

	// --- HW regs interface
	.hardware_regs    ({dbh_pattern_matches, dbh_num_matches, dbh_ft_count_output, dbh_num_packets_in, dbh_output_inst_1,dbh_output_inst_0}),


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
    num_packets_in_next = dbh_num_packets_in;
	source_ip_next = source_ip;
	start_in_next = start_in;
//	end_of_pkt_next = end_of_pkt;
    end_of_pkt_next = 0;
    in_pkt_body_next = in_pkt_body;
	pattern_matches = dbh_pattern_matches;
	
	if (!in_fifo_empty && out_rdy) begin
		out_wr_int_next = 1;
		in_fifo_rd_en = 1;
		//out_data = in_fifo_data;
		
		case(state)
			START: begin
			enable_cpu_next = 0;
			dropfifo_write_next = 0;
			end_of_pkt_next = 0;   // takes matcher out of reset
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
				if (header_counter_next == 4) begin
					source_ip_next = in_fifo_data_p;
					start_in_next = 1;
				end else begin
					//source_ip_next = 0;
					//start_in_next = 0;
				end
				if (header_counter_next == 5) begin
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
                num_packets_in_next = num_packets_in_next + 1;
				end_of_pkt_next = 1;   // will reset matcher
                in_pkt_body_next = 0;
                if (matcher_match) begin
                     pattern_matches = dbh_pattern_matches + 1;
                end				
            end else begin
                  in_pkt_body_next = 1;
            end
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
		start_in <=0;
		source_ip <= 0;
		num_matches <=0;
		end_of_pkt <= 0;
        in_pkt_body <= 0;
		
        
		dbh_output_inst_0 <= 0;
        dbh_output_inst_1 <= 0;
        dbh_num_packets_in <= 0;
		dbh_ft_count_output <= 0;
		dbh_num_matches <= 0;
		dbh_pattern_matches <= 0;
		
	end
	else begin
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
		start_in <= start_in_next;
		source_ip <= source_ip_next;
		end_of_pkt <= end_of_pkt_next;
        in_pkt_body <= in_pkt_body_next;
		
		if (match_true) begin
			num_matches <= num_matches + 1;
		end else begin
			num_matches <= num_matches;
		end
        
		dbh_output_inst_0 <= output_inst[0];
        dbh_output_inst_1 <= output_inst[1];
        dbh_num_packets_in <= num_packets_in_next;
		dbh_ft_count_output <= ft_count_output;
		dbh_num_matches <= num_matches;
		dbh_pattern_matches <= pattern_matches;
	end // else: !if(reset)
end // always @ (posedge clk)   

endmodule 
