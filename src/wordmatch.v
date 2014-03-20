////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : wordmatch.vf
// /___/   /\     Timestamp : 01/31/2014 04:33:13
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family spartan3a -w C:/Xilinx/10.1/ISE/ISEexamples/mini_IDS3/mini_IDS3/wordmatch.sch wordmatch.vf
//Design Name: wordmatch
//Device: spartan3a
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale  100 ps / 10 ps

module OR8_HXILINX_wordmatch (O, I0, I1, I2, I3, I4, I5, I6, I7);
    

   output O;

   input I0;
   input I1;
   input I2;
   input I3;
   input I4;
   input I5;
   input I6;
   input I7;

assign O = (I0 || I1 || I2 || I3 || I4 || I5 || I6 || I7);

endmodule
`timescale 1ns / 1ps

module wordmatch(datacomp, 
                 datain, 
                 wildcard, 
                 match);

    input [55:0] datacomp;
    input [111:0] datain;
    input [6:0] wildcard;
   output match;
   
   wire XLXN_29;
   wire XLXN_30;
   wire XLXN_31;
   wire XLXN_32;
   wire XLXN_33;
   wire XLXN_34;
   wire XLXN_35;
   wire XLXN_36;
   
   comparator XLXI_1 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[55:0]), 
                      .mask(XLXN_29));
   OR8_HXILINX_wordmatch XLXI_2 (.I0(XLXN_36), 
                                 .I1(XLXN_35), 
                                 .I2(XLXN_34), 
                                 .I3(XLXN_33), 
                                 .I4(XLXN_32), 
                                 .I5(XLXN_31), 
                                 .I6(XLXN_30), 
                                 .I7(XLXN_29), 
                                 .O(match));
   // synthesis attribute HU_SET of XLXI_2 is "XLXI_2_0"
   comparator XLXI_3 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[63:8]), 
                      .mask(XLXN_30));
   comparator XLXI_4 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[71:16]), 
                      .mask(XLXN_31));
   comparator XLXI_5 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[79:24]), 
                      .mask(XLXN_32));
   comparator XLXI_6 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[87:32]), 
                      .mask(XLXN_33));
   comparator XLXI_7 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[95:40]), 
                      .mask(XLXN_34));
   comparator XLXI_8 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[103:48]), 
                      .mask(XLXN_35));
   comparator XLXI_9 (.a(datacomp[55:0]), 
                      .amask(wildcard[6:0]), 
                      .b(datain[111:56]), 
                      .mask(XLXN_36));
endmodule
