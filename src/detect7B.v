////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : detect7B.vf
// /___/   /\     Timestamp : 01/31/2014 04:35:43
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family spartan3a -w C:/Xilinx/10.1/ISE/ISEexamples/mini_IDS3/mini_IDS3/detect7B.sch detect7B.vf
//Design Name: detect7B
//Device: spartan3a
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module detect7B(ce, 
                clk, 
                hwregA, 
                match_en, 
                mrst, 
                pipe1, 
                match);

    input ce;
    input clk;
    input [63:0] hwregA;
    input match_en;
    input mrst;
    input [71:0] pipe1;
   output match;
   
   wire [71:0] pipe0;
   wire XLXN_10;
   wire XLXN_17;
   wire XLXN_19;
   wire [111:0] XLXN_21;
   wire match_DUMMY;
   
   assign match = match_DUMMY;
   wordmatch XLXI_1 (.datacomp(hwregA[55:0]), 
                     .datain(XLXN_21[111:0]), 
                     .wildcard(hwregA[62:56]), 
                     .match(XLXN_17));
   busmerge XLXI_2 (.da(pipe0[47:0]), 
                    .db(pipe1[63:0]), 
                    .q(XLXN_21[111:0]));
   reg9B XLXI_3 (.ce(ce), 
                 .clk(clk), 
                 .clr(XLXN_10), 
                 .d(pipe1[71:0]), 
                 .q(pipe0[71:0]));
   FDCE XLXI_4 (.C(clk), 
                .CE(XLXN_19), 
                .CLR(XLXN_10), 
                .D(XLXN_19), 
                .Q(match_DUMMY));
   defparam XLXI_4.INIT = 1'b0;
   AND3B1 XLXI_5 (.I0(match_DUMMY), 
                  .I1(match_en), 
                  .I2(XLXN_17), 
                  .O(XLXN_19));
   FD XLXI_6 (.C(clk), 
              .D(mrst), 
              .Q(XLXN_10));
   defparam XLXI_6.INIT = 1'b0;
endmodule
