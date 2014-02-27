//////////////////////////////////
// IDS_CMD [0] 	= send a reset
// IDS_CMD [1] 	= setup memory
// IDS_CMD [2] 	= verify mem
// IDS_CMD [3]    = set debug mode on
// IDS_CMD [4] 	= enable stepinto
// IDS_CMD [5] 	= stepvalue bit 0
// IDS_CMD [6] 	= stepvalue bit 1
// IDS_CMD [7] 	= stepvalue bit 2
// IDS_CMD [8] 	= 
// IDS_CMD [9] 	= 
// IDS_CMD [10] 	=
// IDS_CMD [11] 	= 
// IDS_CMD [12] 	= 
// IDS_CMD [13] 	= 


////






`timescale 1ns/1ps
// defines

`define INST_WIDTH 32
`define REGFILE_ADDR 3
`define DATAPATH_WIDTH 64
`define MEM_ADDR_WIDTH 10
`define INST_MEM_START 0
`define DATA_MEM_START 512
`define NUM_COUNTERS 0
`define NUM_SOFTWARE_REGS 3
`define NUM_HARDWARE_REGS 2

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
   wire [31:0]                   mem_addr_in;
   wire [31:0]                   mem_data_in;
   wire [31:0]                   ids_cmd;
   // hardware registers
	reg [31:0]                    mem_data_out;
	reg [31:0]						   pc_out;

   // internal state
   reg [1:0]                     state, state_next;
   reg [2:0]                     header_counter, header_counter_next;
   reg [63:0]					 out_data_next, out_ctrl_next;
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
	
	debugger db (
	.debug_en					(ids_cmd[3]),
	.stepinto_en				(ids_cmd[4]),
	.stepvalue					(ids_cmd[7:5]),
	.clk_in						(clk),
	.clk_out						(cpu_clk)
	);
	
	
	arya core1 (
	.mem_addr_in				(mem_addr_in), // Address of memory written by software regs
	.mem_data_in				(mem_data_in), // Data of memory written by software regs
	.mem_data_out				(unified_memout_portb),
	.clk							(cpu_clk),
	.reset						(ids_cmd[0]),
	.setup_mem					(ids_cmd[1]),
	.verify_mem					(ids_cmd[2])
	);
	

   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_TAG),          // Tag -- eg. MODULE_TAG
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
      .software_regs    ({ids_cmd,mem_data_in,mem_addr_in}),

      // --- HW regs interface
      .hardware_regs    ({pc_out,mem_data_out}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------
	
	always @(posedge clk) begin
		if (reset) begin
			mem_data_out <= 0;
		end
		else begin
			mem_data_out <= unified_memout_portb;
		end
	end //always


endmodule 
