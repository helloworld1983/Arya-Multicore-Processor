`timescale 1ns/1ps

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
   wire [31:0]                   pattern_high;
   wire [31:0]                   pattern_low;
   wire [31:0]                   ids_cmd;
   // hardware registers
   reg [31:0]                    matches;

   // internal state
   reg [1:0]                     state, state_next;
   reg [2:0]                     header_counter, header_counter_next;
   reg [63:0]					 out_data_next, out_ctrl_next;
   // local parameter
   parameter                     START = 2'b00;
   parameter                     HEADER = 2'b01;
   parameter                     PAYLOAD = 2'b10;

 
   //------------------------- Local assignments -------------------------------
/*
   assign in_rdy     = out_rdy;
   assign out_wr     = in_wr;
   assign out_data   = in_data;
   assign out_ctrl   = in_ctrl;
  */    
   //------------------------- Modules-------------------------------
	
	
	wire mem_web;
	wire [7:0]mem_ctrl;
	wire [63:0]mem_data;
	wire [7:0]porta_addr;
	wire [7:0]portb_addr;
	wire porta_wena;
	wire porta_wen;
	
	wire [7:0]packet_start_addr;
	wire [7:0]packet_end_addr;
	wire packet_rdy;
	reg in_rdy_reg;
	wire in_rdy_next;
	reg proc_done;
	
	controller ctrl
	(
	.in_wr				(in_wr),
	.in_ctrl				(in_ctrl),
	.in_data				(in_data),
	.out_rdy				(out_rdy),
	.proc_done			(proc_done),
	.clk					(clk),
	.reset				(reset),
	.out_wr				(out_wr_next),
	.out_ctrl			(mem_ctrl),
	.out_data			(mem_data),
	.out_wr_addr		(porta_addr),
	.out_rd_addr		(portb_addr),
	.mem_wen				(porta_wen),
	.in_rdy				(in_rdy_next),
	.packet_rdy			(packet_rdy),
	.packet_start_addr	(packet_start_addr),
	.packet_end_addr		(packet_end_addr)
	);
	
	wire [7:0] porta_dout;
	wire [63:0] porta_ctrlout;
	
	wire [63:0] portb_dout;
	wire [7:0] portb_ctrlout;
	
	data_mem m1 (
	.clka					(clk),
	.dina					({mem_ctrl,mem_data}),
	.addra				(porta_addr),
	.wea					(porta_wen),
	.douta				({porta_ctrlout,porta_dout}),
	.clkb					(clk),
	.dinb					(0),
	.addrb				(portb_addr),
	.web					(0),
	.doutb				({portb_ctrlout, portb_dout})
	);
	/*
	arya core1(
	.start_addr			(),
	.end_addr			(),
	.data_in				(),
	.processor_en				(),
	
	.processor_done	(),
	.addr_out		(),
	.data_out			(),
	.mem_wen				()
	);
	*/
	
	assign out_ctrl = portb_ctrlout;
	assign out_data = portb_dout;
	reg out_wr_reg;
	assign out_wr = out_wr_reg;
	assign in_rdy = in_rdy_reg;
	
	
	always @(posedge clk) begin
		proc_done <= packet_rdy;
		out_wr_reg <= out_wr_next;
		in_rdy_reg <= in_rdy_next;
	end
	
	
	
	
	
	
	

   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (3),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (1)                  // Number of hw regs
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
      .software_regs    ({ids_cmd,pattern_low,pattern_high}),

      // --- HW regs interface
      .hardware_regs    (matches),

      .clk              (clk),
      .reset            (reset)
    );




endmodule 
