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
reg                           	in_pkt_body, in_pkt_body_next;
reg                           	end_of_pkt, end_of_pkt_next;
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
assign dropfifo_write = out_wr_int && ~(stop_small_fifo_rd_d);

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


wire [`MEM_ADDR_WIDTH-1:0]					arya_datamem_addr_out;
wire [DATA_WIDTH-1:0]						arya_datamem_data_out;
wire 										arya_datamem_we_out;
wire [DATA_WIDTH-1:0]						arya_datamem_data_in;
wire										arya_cpu_busy;
wire										arya_cpu_start_trigger;
wire [`MEM_ADDR_WIDTH-1:0]					arya_datamem_first_addr_in;
wire [`MEM_ADDR_WIDTH-1:0]					arya_datamem_last_addr_in;
wire										arya_cpu_done;
wire										arya_enable_cpu;
wire 										arya_reset_cpu;

wire [`MEM_ADDR_WIDTH-1:0]				df_datamem_first_addr_out;
wire [`MEM_ADDR_WIDTH-1:0]				df_datamem_last_addr_out;
wire [`MEM_ADDR_WIDTH-1:0]				df_datamem_addr_in;
wire 									df_datamem_we_in;
wire [DATA_WIDTH-1:0]					df_datamem_data_in;
wire [DATA_WIDTH-1:0]					df_datamem_data_out;
wire									df_fifo_as_mem_in;


assign df_datamem_addr_in 			    = arya_datamem_addr_out + df_datamem_first_addr_out;
assign df_datamem_data_in				= arya_datamem_data_out;
assign df_datamem_we_in					= arya_datamem_we_out;
assign df_fifo_as_mem_in				= arya_enable_cpu;

assign arya_datamem_data_in			= df_datamem_data_out;
assign arya_datamem_first_addr_in	= df_datamem_first_addr_out;
assign arya_datamem_last_addr_in		= df_datamem_last_addr_out;
assign arya_enable_cpu					= enable_cpu_2 && enable_cpu;
assign arya_reset_cpu					= reset_cpu || reset;
assign arya_cpu_start_trigger			= 'b0;

	arya #(
	.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) core_1(
	.mem_addr_in				(dbs_input_inst_addr[`INST_ADDR_WIDTH-1:0]), // Address of memory written by software regs
	.mem_data_in				({dbs_input_inst_high, dbs_input_inst_low}), // Data of memory written by software regs
	.mem_data_out				({memory_output_inst_high, memory_output_inst_low}),
	.clk						(clk),
	.en							(arya_enable_cpu),			// Forcing it to be one.
	.reset						(dbs_cmd[0] || arya_reset_cpu),
	.setup_mem					(dbs_cmd[1]),
	.verify_mem					(dbs_cmd[2]),
	.datamem_addr_out			(arya_datamem_addr_out),			// Output address to datamem/FIFO
	.datamem_data_out			(arya_datamem_data_out),			// Output data to datamem/FIFO
	.datamem_we_out			    (arya_datamem_we_out),			// Output we to datamem/FIFO
	.datamem_data_in			(arya_datamem_data_in),			// Input packet data from datamem/FIFO
	.cpu_busy					(arya_cpu_busy),			// Output indicating the CPU is processing a packet
	.cpu_start_trigger			(arya_cpu_start_trigger),			// Input indicating the CPU can start processing the data.
	.datamem_first_addr_in		(arya_datamem_first_addr_in),
	.datamem_last_addr_in		(arya_datamem_last_addr_in),
	.cpu_done					(arya_cpu_done)
	);


///// HACK HACK HACK //////
//assign arya_cpu_done = 1;
//assign df_fifo_as_mem_in = 0;
//////////////////////////
/*
cpu dummy_cpu (
	.clk(clk),
	.cpu_en(enable_cpu),
	.reset(reset_cpu || reset),
	.cpu_done(arya_cpu_done)
);
*/


    dropfifo  #(
	.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH				(DATA_WIDTH),
	.MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH			(`REGFILE_ADDR_WIDTH)
	) drop_fifo_1 (
	.clk           				(clk), 
	.drop_pkt      				(0),  		// Functionality not required
	.fiforead      				(out_rdy), 
	.fifowrite     				(dropfifo_write), 
	.firstword     				(begin_pkt), 
	.in_fifo       				({in_fifo_ctrl,in_fifo_data}), 
	//.lastword      				(end_of_pkt), 
	.lastword      				(arya_cpu_done), 
	.rst           				(reset), 
	.out_fifo      				({out_ctrl,out_data}), 
	.valid_data    				(out_wr),
	.datamem_first_addr			(df_datamem_first_addr_out),
	.datamem_last_addr			(df_datamem_last_addr_out),
	.datamem_addr_in				(df_datamem_addr_in),
	.datamem_data_in				(df_datamem_data_in),
	.datamem_we						(df_datamem_we_in),
	.datamem_data_out				(df_datamem_data_out),
	.fifo_as_mem					(df_fifo_as_mem_in)			// Signal to muxes
);


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
	//out_data = 0;
	end_of_pkt_next = end_of_pkt;
	in_pkt_body_next = in_pkt_body;
	begin_pkt_next = begin_pkt;
	enable_cpu_next = enable_cpu;
	reset_cpu_next = reset_cpu;
	
	if (!in_fifo_empty && out_rdy) begin
		out_wr_int_next = 1;
		in_fifo_rd_en = 1;
		//out_data = in_fifo_data;
		
		case(state)
			START: begin
			reset_cpu_next = 0;
			if (in_fifo_ctrl_p != 0) begin
				state_next = HEADER;
				begin_pkt_next = 1;
				end_of_pkt_next = 0;   // takes matcher out of reset
			end
			end
			HEADER: begin
			begin_pkt_next = 0;
			if (in_fifo_ctrl_p == 0) begin
				header_counter_next = header_counter + 1'b1;
				if (header_counter_next == 3) begin
					state_next = PAYLOAD;
				end
			end
			end
			PAYLOAD: begin
			if (in_fifo_ctrl_p != 0) begin
				state_next = PROCESS;
				header_counter_next = 0;
				end_of_pkt_next = 1;   // will tell cpu to start
				enable_cpu_next = 1;
				in_pkt_body_next = 0;
				stop_small_fifo_rd_nxt = 1;
			end // if (in_fifo_ctrl_p !=0)
			else begin
				in_pkt_body_next = 1;
			end // else
			end // PAYLOAD
				PROCESS: begin
					end_of_pkt_next = 0;
					if (arya_cpu_done) begin
						state_next = START;
						stop_small_fifo_rd_nxt = 0;
						enable_cpu_next = 0;
						reset_cpu_next = 1;
					end // if (cpu_done)
					else begin
						stop_small_fifo_rd_nxt = 1;
					end // else
				end // PROCESS
		endcase // case(state)
	end
end // always @ (*)

always @(posedge clk) begin
	if(reset) begin
		header_counter <= 0;
		state <= START;
		begin_pkt <= 0;
		end_of_pkt <= 0;
		in_pkt_body <= 0;
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
	end
	else begin
		//if (dbs_cmd[0]) dbh_step_count <= 0;
		//else dbh_step_count <= dbh_step_count + 1;
		header_counter <= header_counter_next;
		state <= state_next;
		begin_pkt <= begin_pkt_next;
		begin_pkt <= begin_pkt_next;
		begin_pkt <= begin_pkt_next;
		end_of_pkt <= end_of_pkt_next;
		in_pkt_body <= in_pkt_body_next;
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
			
	end // else: !if(reset)
end // always @ (posedge clk)   

endmodule 
