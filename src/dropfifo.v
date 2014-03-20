////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : dropfifo.vf
// /___/   /\     Timestamp : 01/31/2014 04:44:07
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family spartan3a -w C:/Xilinx/10.1/ISE/ISEexamples/mini_IDS3/mini_IDS3/dropfifo.sch dropfifo.vf
//Design Name: dropfifo
//Device: spartan3a
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 100 ps / 10 ps

module FD8CE_HXILINX_dropfifo(Q, C, CE, CLR, D);

   
   output [7:0]       Q;

   input 	      C;	
   input 	      CE;	
   input 	      CLR;	
   input  [7:0]       D;
   
   reg    [7:0]       Q;
   
   always @(posedge C or posedge CLR)
     begin
	if (CLR)
	  Q <= 8'b0000_0000;
	else if (CE)
          Q <= D;
     end
   
   
endmodule
`timescale  100 ps / 10 ps

module COMP8_HXILINX_dropfifo (EQ, A, B);
    

   output EQ;

   input  [7:0] A;
   input  [7:0] B;

   assign EQ = (A==B) ;

endmodule
`timescale 100 ps / 10 ps

module CB8CLE_HXILINX_dropfifo(CEO, Q, TC, C, CE, CLR, D, L);
   
   parameter TERMINAL_COUNT = 8'b1111_1111;
   
   output             CEO;
   output [7:0]       Q;
   output             TC;

   input 	      C;	
   input 	      CE;	
   input 	      CLR;	
   input  [7:0]       D;
   input              L;
   
   reg    [7:0]       Q;
   
   always @(posedge C or posedge CLR)
     begin
	if (CLR)
	  Q <= 8'b0000_0000;
        else if (L)
          Q <= D;
	else if (CE)
	  Q <= Q + 1;
     end
   
   assign CEO = TC & CE;
   assign TC = Q == TERMINAL_COUNT;
   
endmodule
`timescale 100 ps / 10 ps

module CB8CE_HXILINX_dropfifo(CEO, Q, TC, C, CE, CLR);
   
   parameter TERMINAL_COUNT = 8'b1111_1111;
   
   output             CEO;
   output [7:0]       Q;
   output             TC;

   input 	      C;	
   input 	      CE;	
   input 	      CLR;	
   
   reg   [7:0]        Q;
   
   always @(posedge C or posedge CLR)
     begin
	if (CLR)
	  Q <= 8'b0000_0000;
	else if (CE)
	  Q <= Q + 1;
     end
   
   assign CEO = TC & CE;
   assign TC = Q == TERMINAL_COUNT;
   
endmodule
`timescale 1ns / 1ps

module dropfifo(clk, 
                drop_pkt, 
                fiforead, 
                fifowrite, 
                firstword, 
                in_fifo, 
                lastword, 
                rst, 
                out_fifo, 
                valid_data);

    input clk;
    input drop_pkt;
    input fiforead;
    input fifowrite;
    input firstword;
    input [71:0] in_fifo;
    input lastword;
    input rst;
   output [71:0] out_fifo;
   output valid_data;
   
   wire XLXN_11;
   wire XLXN_12;
   wire XLXN_13;
   wire XLXN_17;
   wire XLXN_25;
   wire XLXN_28;
   wire XLXN_29;
   wire [7:0] XLXN_30;
   wire [7:0] XLXN_31;
   wire XLXN_33;
   wire XLXN_34;
   wire [7:0] XLXN_36;
   wire [71:0] XLXN_39;
   wire XLXN_40;
   
   FD XLXI_1 (.C(clk), 
              .D(firstword), 
              .Q(XLXN_11));
   defparam XLXI_1.INIT = 1'b0;
   FD XLXI_2 (.C(clk), 
              .D(lastword), 
              .Q(XLXN_12));
   defparam XLXI_2.INIT = 1'b0;
   FD XLXI_3 (.C(clk), 
              .D(fifowrite), 
              .Q(XLXN_28));
   defparam XLXI_3.INIT = 1'b0;
   FD8CE_HXILINX_dropfifo XLXI_4 (.C(clk), 
                                  .CE(XLXN_17), 
                                  .CLR(rst), 
                                  .D(XLXN_36[7:0]), 
                                  .Q(XLXN_31[7:0]));
   // synthesis attribute HU_SET of XLXI_4 is "XLXI_4_0"
   COMP8_HXILINX_dropfifo XLXI_5 (.A(XLXN_36[7:0]), 
                                  .B(XLXN_30[7:0]), 
                                  .EQ(XLXN_33));
   // synthesis attribute HU_SET of XLXI_5 is "XLXI_5_1"
   COMP8_HXILINX_dropfifo XLXI_6 (.A(XLXN_30[7:0]), 
                                  .B(XLXN_31[7:0]), 
                                  .EQ(XLXN_34));
   // synthesis attribute HU_SET of XLXI_6 is "XLXI_6_2"
   FD XLXI_7 (.C(clk), 
              .D(drop_pkt), 
              .Q(XLXN_25));
   defparam XLXI_7.INIT = 1'b0;
   reg9B XLXI_8 (.ce(XLXN_29), 
                 .clk(clk), 
                 .clr(rst), 
                 .d(in_fifo[71:0]), 
                 .q(XLXN_39[71:0]));
   CB8CLE_HXILINX_dropfifo XLXI_9 (.C(clk), 
                                   .CE(XLXN_28), 
                                   .CLR(rst), 
                                   .D(XLXN_31[7:0]), 
                                   .L(XLXN_25), 
                                   .CEO(), 
                                   .Q(XLXN_36[7:0]), 
                                   .TC());
   // synthesis attribute HU_SET of XLXI_9 is "XLXI_9_3"
   CB8CE_HXILINX_dropfifo XLXI_10 (.C(clk), 
                                   .CE(XLXN_40), 
                                   .CLR(rst), 
                                   .CEO(), 
                                   .Q(XLXN_30[7:0]), 
                                   .TC());
   // synthesis attribute HU_SET of XLXI_10 is "XLXI_10_4"
   FDC XLXI_11 (.C(clk), 
                .CLR(rst), 
                .D(XLXN_40), 
                .Q(valid_data));
   defparam XLXI_11.INIT = 1'b0;
   OR2 XLXI_12 (.I0(XLXN_12), 
                .I1(XLXN_11), 
                .O(XLXN_13));
   AND2B1 XLXI_13 (.I0(XLXN_25), 
                   .I1(XLXN_13), 
                   .O(XLXN_17));
   AND3B2 XLXI_14 (.I0(XLXN_34), 
                   .I1(XLXN_33), 
                   .I2(fiforead), 
                   .O(XLXN_40));
   VCC XLXI_18 (.P(XLXN_29));
   dual9Bmem XLXI_20 (.addra(XLXN_36[7:0]), 
                      .addrb(XLXN_30[7:0]), 
                      .clka(clk), 
                      .clkb(clk), 
                      .dina(XLXN_39[71:0]), 
                      .wea(XLXN_28), 
                      .doutb(out_fifo[71:0]));
endmodule
