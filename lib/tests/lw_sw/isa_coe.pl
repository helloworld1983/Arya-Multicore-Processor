#!/usr/bin/perl
use strict;
use warnings;
use Switch;
use Getopt::Long;

#Creating a file to write
my $file = "binaries.coe";
unless(open (FILE, '>',$file)) {
	die "Can't open file binaries.coe!\n";
}

my $hex_file = "hex_mem.txt";
unless(open (HEX_FILE, '>',$hex_file)) {
	die "Can't open hex file.coe!\n";
}

print FILE "memory_initialization_radix=2;\n";
print FILE "memory_initialization_vector=\n";

#Array to store the instruction binaries
my @store_file_array;
my $i = 0;

#Opcodes and Function fields for the ISA
my $add = "100000"; 	my $add_funct = "000001";
my $addi = "100100";
my $sub = "100000";		my $sub_funct = "000010";
my $sll = "100000";		my $sll_funct = "001000";
my $srl = "100000";		my $srl_funct = "001001";
my $and = "100000";		my $and_funct = "000011";
my $nop = "000000";
my $or = "100000";		my $or_funct = "000100";
my $xor = "100000";		my $xor_funct = "000110";
my $slt = "100000";		my $slt_funct = "000111";
my $beq = "010000";
my $bne = "001000";
my $lw = "100101";
my $sw = "000110";

my $file_name;
my $result = GetOptions ("file_name=s" => \$file_name);    # Taking input from command line.

my $file_write = "$file_name";
print "The file path is $file_write\n";
open (MYFILE,'<', $file_write)
  or die "cannot open < $file_write $!";

#Open the file to read the instructions from
#my $myfile = "mips_isa.asm";
#unless(open (MYFILE, '<',$myfile)) {
#	die "Can't open file mips_isa.asm!\n";
#}

#Loop through every line of the file to extract the instructions convert each to binaries
while (<MYFILE>) {
	
	chomp;
	my $string = "$_";
	my @values = split (' ', $string);
	switch ($values[0]) {
	
	case "add" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $add.$rs.$rt.$rd."00000".$add_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "addi" {
		$values[1] =~ s#\$(\d+),\$(\d+),(.+)#\$$1,\$$2,$3#;
		my $rt = $1;
		my $rs = $2;
		my $immd = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$immd = dec2bin_immd($immd);
		my $bin_temp = $addi.$rs.$rt.$immd;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "sub" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $sub.$rs.$rt.$rd."00000".$sub_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "sll" {
		$values[1] =~ s#\$(\d+),\$(\d+)#\$$1,\$$2#;
		my $rd = $1;
		my $rs = $2;
		$rd = dec2bin($rd);
		$rs = dec2bin($rs);
		my $bin_temp = $sll.$rs."00000".$rd."00000".$sll_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "srl" {
		$values[1] =~ s#\$(\d+),\$(\d+)#\$$1,\$$2#;
		my $rd = $1;
		my $rs = $2;
		$rd = dec2bin($rd);
		$rs = dec2bin($rs);
		my $bin_temp = $sll.$rs."00000".$rd."00000".$srl_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "and" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $and.$rs.$rt.$rd."00000".$and_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "or" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $or.$rs.$rt.$rd."00000".$or_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "xor" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $xor.$rs.$rt.$rd."00000".$xor_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "slt" {
		$values[1] =~ s#\$(\d+),\$(\d+),\$(\d+)#\$$1,\$$2,\$$3#;
		my $rd = $1;
		my $rs = $2;
		my $rt = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$rd = dec2bin($rd);
		my $bin_temp = $slt.$rs.$rt.$rd."00000".$slt_funct;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "beq" {
		$values[1] =~ s#\$(\d+),\$(\d+),(\d+)#\$$1,\$$2,$3#;
		my $rs = $1;
		my $rt = $2;
		my $offset = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$offset = dec2bin_immd($offset);
		my $bin_temp = $beq.$rs.$rt.$offset;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "bne" {
		$values[1] =~ s#\$(\d+),\$(\d+),(\d+)#\$$1,\$$2,$3#;
		my $rs = $1;
		my $rt = $2;
		my $offset = $3;
		$rs = dec2bin($rs);
		$rt = dec2bin($rt);
		$offset = dec2bin_immd($offset);
		my $bin_temp = $bne.$rs.$rt.$offset;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "nop" {
		my $binary = padzeroes($nop);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "lw" {
		$values[1] =~ s#\$(\d+),(\d+)\(\$(\d+)\)#\$$1,$2(\$$3)#;
		my $rt = $1;
		my $offset = $2;
		my $base = $3;
		$rt = dec2bin($rt);
		$offset = dec2bin_immd($offset);
		$base = dec2bin($base);
		my $bin_temp = $lw.$base.$rt.$offset;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "sw" {
		$values[1] =~ s#\$(\d+),(\d+)\(\$(\d+)\)#\$$1,$2(\$$3)#;
		my $rt = $1;
		my $offset = $2;
		my $base = $3;
		$rt = dec2bin($rt);
		$offset = dec2bin_immd($offset);
		$base = dec2bin($base);
		my $bin_temp = $sw.$base.$rt.$offset;
		my $binary = padzeroes($bin_temp);
		$store_file_array[$i] = $binary;
		$i++;
	}
	
	case "halt" {
		my $binary = '1' x 64;
		$store_file_array[$i] = $binary;
		$i++;
	}
}
}

#Make the hex file (instruction + padded zeros), 512 locations
foreach (@store_file_array) {
		my $binary_conv = $_;
		my $binaryl = substr($binary_conv,0,32);
		my $binarym = substr($binary_conv,32,64);
		my $hexl = unpack ("H8", pack("B32", $binaryl));
		my $hexm = unpack ("H8", pack("B32", $binarym));
		print HEX_FILE "$hexl".","."$hexm"."\n";
}
my $size = @store_file_array;
my $x = 512 - $size;
while ($x != 0) {
	my $binary_conv = '0' x 64;
	my $binaryl = substr($binary_conv,0,32);
	my $binarym = substr($binary_conv,32,64);
	my $hexl = unpack ("H8", pack("B32", $binaryl));
	my $hexm = unpack ("H8", pack("B32", $binarym));
	print HEX_FILE   "$hexl".","."$hexm"."\n";
	$x--;
}

#Add data to the hex file
my $data_size1 = 512;
my $data1 = 100;
while ($data_size1 != 0) {
	my $print_data = dec2bin_data($data1);
	my $binaryl = substr($print_data,0,32);
	my $binarym = substr($print_data,32,64);
	my $hexl = unpack ("H8", pack("B32", $binaryl));
	my $hexm = unpack ("H8", pack("B32", $binarym));
	if ($data_size1 == 1) {
		print HEX_FILE "$hexl".","."$hexm";
	}
	else {
		print HEX_FILE "$hexl".","."$hexm"."\n"
	}
	$data1++;
	$data_size1--;
}

#Make the coe file (instruction + padded zeros), 512 locations
foreach (@store_file_array) { 
		print FILE "$_".","."\n";
}
my $size1 = @store_file_array;
my $x1 = 512 - $size1;
while ($x1 != 0) {
	print FILE '0' x 64 . ",\n";
	$x1--;
}

#Add data to the coe file
my $data_size = 512;
my $data = 100;
while ($data_size != 0) {
	my $print_data = dec2bin_data($data);
	if ($data_size == 1) {
		print FILE $print_data.";";
	}
	else {
		print FILE $print_data.",\n"
	}
	$data++;
	$data_size--;
}

#Convert decimal to binary for the instructions
sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    my $sub_str = substr ($str, 27,5);
    return $sub_str;
}

sub dec2bin_immd {
	my $str = unpack("B32", pack("N", shift));
    my $sub_str = substr ($str, 16,16);
    return $sub_str;
}

#Convert decimal to binary for the data to be stored in data memory with padded zeroes
sub dec2bin_data {
	my $str = unpack("B32", pack("N", shift));
	my $add_str = ('0' x 32).$str;
	return $add_str;
}

#Pad zeroes to the registers of the instruction
sub padzeroes {
	my $bin_pad = ('0' x (64 - length($_[0]))).$_[0];
	return $bin_pad;
}

close(HEX_FILE);
close (MYFILE);
close (FILE);
