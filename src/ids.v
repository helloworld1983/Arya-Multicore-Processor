
`timescale 1ns/1ps
// defines

`define REGFILE_ADDR_WIDTH 	5
`define MEM_ADDR_WIDTH 			8
`define INST_ADDR_WIDTH 		6
`define NUM_COUNTERS 			0
`define NUM_SOFTWARE_REGS 		11
`define NUM_HARDWARE_REGS 		7
`define NUM_THREADS				8
`define	NUM_CORES				2
`define NUM_THREADS_PER_CORE	4
`define INST_WIDTH				32
`define FT_COUNTER_ADDR_WIDTH   4
`define NUM_ACTIONS				4
`define THREAD_BITS_PER_CORE	2
`define THREAD_BITS				3
`define FT_ADDR_WIDTH			4
`define FT_DEPTH				16

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
wire							stop_smallfifo_rd;
reg                           	out_wr_int;

reg			         			out_wr_int_next;


reg								enable_cpu_next, enable_cpu, enable_cpu_1, enable_cpu_2;
reg								reset_cpu_next, reset_cpu;
wire							final_dropfifo_write;
reg								dropfifo_write, dropfifo_write_next;
reg								dropfifo_write_1;
reg								dropfifo_write_2;
reg	[2:0]						current_thread_next, current_thread, current_thread_1;


wire [(`INST_ADDR_WIDTH - 1) + 2:0]				    	input_inst_addr[0:1];
wire [31:0]	input_inst[0:1];
wire    cmd_setup_mem [0:1];
wire    cmd_verify_mem [0:1];
wire    cmd_debug_on [0:1];

reg  [31:0]                 	num_packets_in_next;
wire [31:0] 					halt_counter[0:1];
wire [31:0]						output_inst[0:1];

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


// hardware registers
reg [31:0]                    	dbh_output_inst_0;
reg [31:0]                    	dbh_output_inst_1;
reg [31:0]                      dbh_num_packets_in;
reg [31:0]                      dbh_halt_counter_0;
reg [31:0]                      dbh_halt_counter_1;
reg [31:0]						dbh_ft_count_output;
reg [31:0]						dbh_num_matches;

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



assign input_inst_addr[0] = dbs_input_inst_addr_0[(`INST_ADDR_WIDTH-1) + 2:0];
assign input_inst[0] = dbs_input_inst_0;
assign cmd_setup_mem[0] = dbs_cmd_0[1];
assign cmd_verify_mem[0] = dbs_cmd_0[2];
assign cmd_debug_on[0] = dbs_cmd_0[23];
assign input_inst_addr[1] = dbs_input_inst_addr_1[(`INST_ADDR_WIDTH-1) + 2:0];
assign input_inst[1] = dbs_input_inst_1;
assign cmd_setup_mem[1] = dbs_cmd_1[1];
assign cmd_verify_mem[1] = dbs_cmd_1[2];
assign cmd_debug_on[1] = dbs_cmd_1[23];
assign in_rdy     = !in_fifo_nearly_full;
assign input_fifo_rd_en = in_fifo_rd_en && ~stop_smallfifo_rd;
assign final_dropfifo_write = dropfifo_write || dropfifo_write_2;
assign df_fifo_as_mem_in = arya_thread_busy;
assign rdf_out_data = {df_out_data[7],df_out_data[6],df_out_data[5],df_out_data[4],df_out_data[3],df_out_data[2],df_out_data[1],df_out_data[0]};
assign rdf_out_ctrl = {df_out_ctrl[7],df_out_ctrl[6],df_out_ctrl[5],df_out_ctrl[4],df_out_ctrl[3],df_out_ctrl[2],df_out_ctrl[1],df_out_ctrl[0]};

//------------------------- Modules-------------------------------

wire [DATA_WIDTH-1:0]arya_datamem_data_in [0:1];
wire [1:0] arya_thread_id_out [0:1];
wire [1:0] previous_thread_id_out_0;
wire [1:0] previous_thread_id_out_1;

wire [31:0] output_inst_high [0:1];
wire [31:0] output_inst_low [0:1];

assign previous_thread_id_out_0 = arya_thread_id_out[0];
assign previous_thread_id_out_1 = arya_thread_id_out[1];

wire [1:0] action_thread_id_in [0:1];
wire [`NUM_ACTIONS-1:0] action_out;
wire action_done;
wire [2:0] action_thread_id;
wire [1:0] arya_action_done;
wire [31:0] ft_count_output;
reg [DATA_WIDTH-1:0] source_ip,source_ip_next;
reg start_in_next,start_in;
	
assign arya_action_done[0] = action_done && ~action_thread_id[2];
assign arya_action_done[1] = action_done && action_thread_id[2];


wire [31:0] ip_in;
wire match_true;
reg [31:0] num_matches;
assign ip_in = source_ip[47:16];
	
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_0;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_1;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_2;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_3;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_4;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_5;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_6;
wire 	[DATA_WIDTH-1:0]	df_datamem_data_out_7;

assign df_datamem_data_out_0 = df_datamem_data_out[0];
assign df_datamem_data_out_1 = df_datamem_data_out[1];
assign df_datamem_data_out_2 = df_datamem_data_out[2];
assign df_datamem_data_out_3 = df_datamem_data_out[3];
assign df_datamem_data_out_4 = df_datamem_data_out[4];
assign df_datamem_data_out_5 = df_datamem_data_out[5];
assign df_datamem_data_out_6 = df_datamem_data_out[6];
assign df_datamem_data_out_7 = df_datamem_data_out[7];

reg [DATA_WIDTH-1:0] arya_datamem_data_in_0;
reg [DATA_WIDTH-1:0] arya_datamem_data_in_1;

assign arya_datamem_data_in[0] = arya_datamem_data_in_0;
assign arya_datamem_data_in[1] = arya_datamem_data_in_1;

 	always @(*) begin
	case (previous_thread_id_out_0)
		'b00: begin
			arya_datamem_data_in_0 = df_datamem_data_out_0;
		end
		'b01: begin
			arya_datamem_data_in_0 = df_datamem_data_out_1;
		end
		'b10: begin
			arya_datamem_data_in_0 = df_datamem_data_out_2;
		end
		'b11: begin
			arya_datamem_data_in_0 = df_datamem_data_out_3;
		end
	endcase
	
	case (previous_thread_id_out_1)
		'b00: begin
			arya_datamem_data_in_1 = df_datamem_data_out_4;
		end
		'b01: begin
			arya_datamem_data_in_1 = df_datamem_data_out_5;
		end
		'b10: begin
			arya_datamem_data_in_1 = df_datamem_data_out_6;
		end
		'b11: begin
			arya_datamem_data_in_1 = df_datamem_data_out_7;
		end
	endcase
end




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
	.fifo_read_done							(fifo_read_done)
    );
	
	
	genvar j;
	generate
		for (j=0; j<`NUM_CORES; j=j+1) begin : cpu
		arya #(
		.INST_ADDR_WIDTH				(`INST_ADDR_WIDTH),
		.DATAPATH_WIDTH					(DATA_WIDTH),
		.MEM_ADDR_WIDTH					(`MEM_ADDR_WIDTH),
		.REGFILE_ADDR_WIDTH				(`REGFILE_ADDR_WIDTH),
		.NUM_THREADS					(`NUM_THREADS_PER_CORE),
		.INST_WIDTH						(`INST_WIDTH),
		.NUM_ACTIONS					(`NUM_ACTIONS),
		.THREAD_BITS					(`THREAD_BITS_PER_CORE)
		) core (
		.clk							(clk),
		.en								(1),			// Forcing it to be one.
		.reset							(reset),
		//.debug_commands					(dbs_cmd[(j+7)*`NUM_THREADS_PER_CORE-1:(j+6)*`NUM_THREADS_PER_CORE]),
        .debug_commands                 (0),
		//.debug_on						(0),
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
		.datamem_addr_out				({temp_datamem_addr_in[j*4 + 3],temp_datamem_addr_in[j*4 + 2],temp_datamem_addr_in[j*4 + 1],temp_datamem_addr_in[j*4 + 0]}),
		.datamem_data_out				({df_datamem_data_in[j*4 + 3],df_datamem_data_in[j*4 + 2],df_datamem_data_in[j*4 + 1],df_datamem_data_in[j*4 + 0]}),
		.datamem_we_out				    ({df_datamem_we_in[j*4 + 3],df_datamem_we_in[j*4 + 2],df_datamem_we_in[j*4 + 1],df_datamem_we_in[j*4 + 0]}),
		.thread_id_out					(arya_thread_id_out[j]),
		.halt_counter_out				(halt_counter[j])
		);
		

		end // for
	endgenerate

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


	/// accelerator ///////
	accelerator #(
	.FT_ADDR_WIDTH 			(`FT_ADDR_WIDTH),
	.FT_DEPTH				(`FT_DEPTH),
	.NUM_ACTIONS			(`NUM_ACTIONS)
	)
	accelerator_1 (
	.clk							(clk),
	.reset							(reset),
	.ip_in							(ip_in),
	.thread_id_in					(current_thread),
	.start_in						(start_in),
	.counter_rd_addr_in				(dbs_counter_read_addr[`FT_ADDR_WIDTH-1:0]),
	.read_counter					(dbs_counter_read_addr[`FT_ADDR_WIDTH]),
	.ft_ip							(dbs_ft_ip),
	.ft_action						(dbs_ft_action),
	.ft_addr						(dbs_ft_addr[`FT_ADDR_WIDTH-1:0]),
	.setup_ft						(dbs_ft_addr[`FT_ADDR_WIDTH]),
	//.setup_ft						(0),
	.action_out						(action_out),
	.thread_id_out					(action_thread_id),
	.acc_done						(action_done),
	.count_out						(ft_count_output),
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
	.software_regs    ({dbs_compare_ip_in,dbs_ft_addr, dbs_ft_action, dbs_ft_ip, dbs_counter_read_addr, dbs_input_inst_1,dbs_input_inst_addr_1,dbs_input_inst_0,dbs_input_inst_addr_0,dbs_cmd_1,dbs_cmd_0}),

	// --- HW regs interface
	.hardware_regs    ({dbh_num_matches, dbh_ft_count_output, dbh_halt_counter_1,dbh_halt_counter_0, dbh_num_packets_in, dbh_output_inst_1,dbh_output_inst_0}),


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
				state_next = PAYLOAD;
				begin_pkt_next = 1;
				dropfifo_write_next = 1;
			end // if (in_fifo_ctrl_p != 0)
			end // if (~stop_smallfifo_rd)
			end // START
			PAYLOAD: begin
                begin_pkt_next = 0;
                header_counter_next = header_counter + 1'b1;
                if (in_fifo_ctrl_p == 0) begin
                    if (header_counter_next == 4) begin
                        source_ip_next = in_fifo_data_p;
                        start_in_next = 1;
                    end else begin
                        source_ip_next = 0;
                        start_in_next = 0;
                    end
                end else if (in_fifo_ctrl_p != 0) begin
                    state_next = START;
                    header_counter_next = 0;
                    enable_cpu_next = 1;
                    current_thread_next = current_thread_next + 1;
                    num_packets_in_next = num_packets_in_next + 1;
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
		start_in <=0;
		source_ip <= 0;
		num_matches <=0;
        
		dbh_output_inst_0 <= 0;
        dbh_output_inst_1 <= 0;
        dbh_num_packets_in <= 0;
        dbh_halt_counter_0 <= 0;
		dbh_halt_counter_1 <= 0;
		dbh_ft_count_output <= 0;
		dbh_num_matches <=0;
		
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

		if (match_true) begin
			num_matches <= num_matches + 1;
		end else begin
			num_matches <= num_matches;
		end
        
		dbh_output_inst_0 <= output_inst[0];
        dbh_output_inst_1 <= output_inst[1];
        dbh_num_packets_in <= num_packets_in_next;
        dbh_halt_counter_0 <= halt_counter[0];
		dbh_halt_counter_1 <= halt_counter[1];
		dbh_ft_count_output <= ft_count_output;
		dbh_num_matches <= num_matches;
		
	end // else: !if(reset)
end // always @ (posedge clk)   

endmodule 
