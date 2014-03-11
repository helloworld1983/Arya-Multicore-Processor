#!/bin/bash
#Script to generate the .coe file from the .c file

if [ "$1" == "clean" ]; then
{
	rm test.s;
	rm mips_isa.asm;
	rm binaries.coe;
	rm hex_mem.txt;
	
	echo "Cleaned up the generated files!"
}
else
{
	#Compile the .c file using mips-gcc
	/home/ketulsheth/mips_compiler/bin/mips-gcc -march=mips32 -o test.s -S $1

	#.s file to .asm file
	perl mips_isa.pl

	#.asm to .coe file
	perl isa_coe.pl
	
	echo "Generated binaries.coe and hex.txt!"
}
fi
