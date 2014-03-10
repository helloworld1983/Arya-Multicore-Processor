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
// dbs_cmd [10] 	= unused
// dbs_cmd [11] 	= unused
// dbs_cmd [12] 	= unused
// dbs_cmd [13] 	= unused
////////////////////////////////////
// [31:0] 	dbs_input_data_high 	= upper 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_data_low 	= lower 32 bits of data to program memory
////////////////////////////////////
// [31:0] 	dbs_input_addr 			= memory address to program
///////////////////////////////////


/////////////////////////////////////
///// HARDWARE REGS//////////////////
////////////////////////////////////
// [31:0]	dbh_output_data_high		= upper 32 bits of data read from mem
/////////////////////////////////////
// [31:0]	dbh_output_data_low		= lower 32 bits of data read from mem
////////////////////////////////////
// [31:0]	dbh_step_count		 	= Number of steps the simulation has run
////////////////////////////////////


`timescale 1ns/1ps
// defines

`define REGFILE_ADDR_WIDTH 	3
`define MEM_ADDR_WIDTH 			10
`define INST_ADDR_WIDTH 		9
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

      output  [DATA_WIDTH-1:0]             out_data,
      output  [CTRL_WIDTH-1:0]             out_ctrl,
      output                               out_wr,
      input                                out_rdy,
      
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

   // Define the log2 function
   // `LOG2_FUNC

   //------------------------- Signals-------------------------------
   
   wire [DATA_WIDTH-1:0]         in_fifo_data;
   wire [CTRL_WIDTH-1:0]         in_fifo_ctrl;

   wire                          in_fifo_nearly_full;
   wire                          in_fifo_empty;

   reg                           in_fifo_rd_en;
   reg                           out_wr_int;

   // software registers 
   wire [31:0]                   dbs_cmd;
   wire [31:0]                   dbs_input_data_high;
   wire [31:0]                   dbs_input_data_low;
	wire [31:0]				     		dbs_input_addr;
   // hardware registers
	reg [31:0]                    dbh_output_data_high;
	reg [31:0]					  		dbh_output_data_low;
	reg [31:0]					  		dbh_step_count;

   // internal state
   reg [1:0]                     state, state_next;
   reg [2:0]                     header_counter, header_counter_next;
   reg [63:0]					 		out_data_next, out_ctrl_next;
   // local parameter
   parameter                     START = 2'b00;
   parameter                     HEADER = 2'b01;
   parameter                     PAYLOAD = 2'b10;

 
   //------------------------- Local assignments DONOT TOUCH -------------------------------

   assign in_rdy     = out_rdy;
   assign out_wr     = in_wr;
   assign out_data   = in_data;
   assign out_ctrl   = in_ctrl;
	
	
	//---------- Local assignments you may touch ---------------------------------------
      
   //------------------------- Modules-------------------------------
/*	
	debugger db (
	.debug_en					(dbs_cmd[3]), 	// Enable debug mode
	.stepinto_en				(dbs_cmd[4]), 	// Enable this to trigger step-into after loading stepvalue
	.stepvalue					(dbs_cmd[7:5]),	// Give these values while stepinto_en == 0
	.clk_in						(clk),
	.clk_out						(cpu_clk)
	);

    */
    
	wire [31:0] memory_output_data_high;
	wire [31:0] memory_output_data_low;
	
	wire cpu_en = 1'b1;
	
	arya #(
	.INST_ADDR_WIDTH			(`INST_ADDR_WIDTH),
	.DATAPATH_WIDTH			(DATA_WIDTH),
	.MEM_ADDR_WIDTH			(`MEM_ADDR_WIDTH),
	.REGFILE_ADDR_WIDTH		(`REGFILE_ADDR_WIDTH)
	) core_1(
	.mem_addr_in				(dbs_input_addr[`MEM_ADDR_WIDTH-1:0]), // Address of memory written by software regs
	.mem_data_in				({dbs_input_data_high, dbs_input_data_low}), // Data of memory written by software regs
	.mem_data_out				({memory_output_data_high, memory_output_data_low}),
	.clk							(clk),
	.en							(cpu_en),			// Forcing it to be one.
	.reset						(dbs_cmd[0]),
	.setup_mem					(dbs_cmd[1]),
	.verify_mem					(dbs_cmd[2]),
	.enable_mem					(dbs_cmd[9])
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
      .software_regs    ({dbs_input_addr,dbs_input_data_low,dbs_input_data_high,dbs_cmd}),

      // --- HW regs interface
      .hardware_regs    ({dbh_step_count,dbh_output_data_low,dbh_output_data_high}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------
	
	always @(posedge clk) begin
		if (reset) begin
			dbh_output_data_high <= 0;
			dbh_output_data_low <= 0;
		end
		else begin
			dbh_output_data_high <= memory_output_data_high;
			dbh_output_data_low <= memory_output_data_low;
		end
	end //always

	always @(posedge clk) begin		
		if (dbs_cmd[0])begin
			dbh_step_count <= 0;
		end // if (ids_cmd[0])
		else begin
			dbh_step_count <= dbh_step_count + 1;
		end // else
	end // always


endmodule 
