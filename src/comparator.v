////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : comparator.vf
// /___/   /\     Timestamp : 01/31/2014 04:33:13
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family spartan3a -w C:/Xilinx/10.1/ISE/ISEexamples/mini_IDS3/mini_IDS3/comparator.sch comparator.vf
//Design Name: comparator
//Device: spartan3a
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale  100 ps / 10 ps

module COMP8_HXILINX_comparator (EQ, A, B);
    

   output EQ;

   input  [7:0] A;
   input  [7:0] B;

   assign EQ = (A==B) ;

endmodule
`timescale  100 ps / 10 ps

module AND7_HXILINX_comparator (O, I0, I1, I2, I3, I4, I5, I6);
    

   output O;

   input I0;
   input I1;
   input I2;
   input I3;
   input I4;
   input I5;
   input I6;

assign O = I0 && I1 && I2 && I3 && I4 && I5 && I6;

endmodule
`timescale 1ns / 1ps

module comparator(a, 
                  amask, 
                  b, 
                  mask);

    input [55:0] a;
    input [6:0] amask;
    input [55:0] b;
   output mask;
   
   wire XLXN_7;
   wire XLXN_10;
   wire XLXN_13;
   wire XLXN_16;
   wire XLXN_19;
   wire XLXN_22;
   wire XLXN_25;
   wire XLXN_36;
   wire XLXN_37;
   wire XLXN_38;
   wire XLXN_39;
   wire XLXN_40;
   wire XLXN_41;
   wire XLXN_42;
   
   COMP8_HXILINX_comparator XLXI_1 (.A(a[55:48]), 
                                    .B(b[55:48]), 
                                    .EQ(XLXN_7));
   // synthesis attribute HU_SET of XLXI_1 is "XLXI_1_0"
   OR2B1 XLXI_10 (.I0(amask[6]), 
                  .I1(XLXN_7), 
                  .O(XLXN_36));
   AND7_HXILINX_comparator XLXI_11 (.I0(XLXN_42), 
                                    .I1(XLXN_41), 
                                    .I2(XLXN_40), 
                                    .I3(XLXN_39), 
                                    .I4(XLXN_38), 
                                    .I5(XLXN_37), 
                                    .I6(XLXN_36), 
                                    .O(mask));
   // synthesis attribute HU_SET of XLXI_11 is "XLXI_11_1"
   COMP8_HXILINX_comparator XLXI_12 (.A(a[47:40]), 
                                     .B(b[47:40]), 
                                     .EQ(XLXN_10));
   // synthesis attribute HU_SET of XLXI_12 is "XLXI_12_2"
   OR2B1 XLXI_13 (.I0(amask[5]), 
                  .I1(XLXN_10), 
                  .O(XLXN_37));
   COMP8_HXILINX_comparator XLXI_14 (.A(a[39:32]), 
                                     .B(b[39:32]), 
                                     .EQ(XLXN_13));
   // synthesis attribute HU_SET of XLXI_14 is "XLXI_14_3"
   OR2B1 XLXI_15 (.I0(amask[4]), 
                  .I1(XLXN_13), 
                  .O(XLXN_38));
   COMP8_HXILINX_comparator XLXI_16 (.A(a[31:24]), 
                                     .B(b[31:24]), 
                                     .EQ(XLXN_16));
   // synthesis attribute HU_SET of XLXI_16 is "XLXI_16_4"
   OR2B1 XLXI_17 (.I0(amask[3]), 
                  .I1(XLXN_16), 
                  .O(XLXN_39));
   COMP8_HXILINX_comparator XLXI_18 (.A(a[23:16]), 
                                     .B(b[23:16]), 
                                     .EQ(XLXN_19));
   // synthesis attribute HU_SET of XLXI_18 is "XLXI_18_5"
   OR2B1 XLXI_19 (.I0(amask[2]), 
                  .I1(XLXN_19), 
                  .O(XLXN_40));
   COMP8_HXILINX_comparator XLXI_20 (.A(a[15:8]), 
                                     .B(b[15:8]), 
                                     .EQ(XLXN_22));
   // synthesis attribute HU_SET of XLXI_20 is "XLXI_20_6"
   OR2B1 XLXI_21 (.I0(amask[1]), 
                  .I1(XLXN_22), 
                  .O(XLXN_41));
   COMP8_HXILINX_comparator XLXI_22 (.A(a[7:0]), 
                                     .B(b[7:0]), 
                                     .EQ(XLXN_25));
   // synthesis attribute HU_SET of XLXI_22 is "XLXI_22_7"
   OR2B1 XLXI_23 (.I0(amask[0]), 
                  .I1(XLXN_25), 
                  .O(XLXN_42));
endmodule
