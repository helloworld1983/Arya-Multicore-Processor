#!/usr/bin/perl
use strict; use warnings; #use Switch;


# 1 extra nop added after lw
# +2 nops after every instruction

#shell command to gcc the .c code

#Cleanup extra stuff from the generated .s file
#look for line move $fp,$sp and trim file till that line.

#Global variables
my $line_num_start = 1;
my $line_num_end = 1;
my $address=0;
my @store_file_array;
my @values = 0;
my @label;
my $index = 0;
my @map;
my @branch_line_number;
my $i;
my $fp = 30;

#Open the file to write the MIPS our ISA code
my $file = "mips_isa.asm";
unless(open(FILE, ">", $file)) {
	die "Can't open file mips_isa.asm!\n";
}

#Open the code generated using mips-gcc
my $myfile = "test.s";
unless(open (MYFILE, "<", $myfile)) {
	die "Can't open file test.s!\n";
}

#Scan through each line of the .s file
#Finds all the labels in the file
#Stores the corresponding line number in label array

while(<MYFILE>) {
	chomp;
	
#Each line of the file is stored in $string
	my $string="$_";
	
#Find the the line mov $fp,$sp. The actual code starts after this line
	if($string eq '	move	$fp,$sp') {
		$line_num_start = $.;
	}
	
#scan through the file and store next line number after a label is found.
#the index in the array is same as label number
	if($string =~ m/\$L(\d+):/) {
		$string =~ s#\$L(\d+)#\$L$1#;
		$label[$1] = $. + 1;
		#print "$1\n";
		#print "$label[$1]\n";
	}

	if($string eq '	move	$sp,$fp') {
		$line_num_end = $.;
	}
	#$string =~ s#(\w+) \$(.+),\$(.+),(.+)#$1 \$$2,\$$3,$4#;
	#if($2 eq "fp" || $3 eq "fp" || $4 eq "fp"){
	
	#	print "$.\n" 
	#}
}

close(MYFILE);	

#print "scan through line numbers $line_num_start and $line_num_end\n";

unless(open (MYFILE, '<', $myfile)) {
	die "Can't open file test.s, second time!\n";
}

while(<MYFILE>) {
	chomp; #remove \n from end of lines
	
	if($. > $line_num_start && $. < $line_num_end){	
		my $string="$_";
		 $string=~ s/fp/$fp/g;
#the array index of map array is the current line in .s file
#at that index we store the corresponding address of converted instructions in out_assembly.txt. 
		$map[$.] = $address;

		if(substr($string,0,1) eq '	'){
			 @values = split ('\t', $string);
			 #print "$values[1]\n";
			
			 
		}
		else {
			$values[1]="skip";
		}
		
# The following is the mapping between MIPS ISA and Arya ISA		
		
		if( $values[1] eq "nop"){
				#print "$.\n";
				$store_file_array[$address] = "nop\n";
				$address++;
			}

		if($values[1] eq "li"){
				$values[2] =~ s#\$(.+),(\d+)#\$$1,$2#;
				$store_file_array[$address] = "addi \$$1,\$0,$2\n"; 
				$address++;
				put_nop();
			}
		if($values[1] eq "lw"){
				#print "=======lw line = $.=======\n";
				$values[2] =~ s#\$(.+),(.+)\(\$(\w+)\)#\$$1,$2(\$$3)#;
				$store_file_array[$address] = "lw \$$1,$2(\$$3)\n";
				$address++;
				put_nop_lw();
			}

		if($values[1] eq "sw"){
				#print "=======lw line = $.=======\n";
				$values[2] =~ s#\$(.+),(.+)\(\$(\w+)\)#\$$1,$2(\$$3)#;
				$store_file_array[$address] = "sw \$$1,$2(\$$3)\n";
				$address++;
				put_nop();
			}

		if($values[1] eq "mul"){
				#print "=======mul line = $.=======\n";
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "and \$7,\$7,\$0\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "addi \$1,\$0,1\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "beq \$0,\$$3,".($address+25)."\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "add \$7,\$7,\$$2\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "sub \$$3,\$$3,\$1\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "beq \$0,\$$3,".($address+15)."\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "beq \$0,\$0,".($address-15)."\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "add \$$1,\$0,\$0\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "add \$$1,\$7,\$0\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "addiu"){
				#print "=======addiu line = $.=======\n";
				$values[2] =~ s#\$(.+),\$(.+),(.+)#\$$1,\$$2,$3#;
				$store_file_array[$address] = "addi \$$1,\$$2,$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "sll"){
				#print "=======sll line = $.=======\n";
				$values[2] =~ s#\$(.+),\$(.+),(\d+)#\$$1,\$$2,$3#;
				$store_file_array[$address] = "addi \$1,\$0,$3\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "sll \$$1,\$$2\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "add \$$2,\$$1,\$0\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "addi \$1,\$1,-1\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "bne \$1,\$0,".($address-15)."\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "srl"){
				$values[2] =~ s#\$(.+),\$(.+),(\d+)#\$$1,\$$2,$3#;
				$store_file_array[$address] = "addi \$1,\$0,$3\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "srl \$$1,\$$2\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "add \$$2,\$$1,\$0\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "addi \$1,\$1,-1\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "bne \$1,\$0,".($address-15)."\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "slt"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "slt \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
		
		if($values[1] eq "bne"){
				$values[2] =~ s#\$(.+),\$(.+),\$L(\d+)#\$$1,\$$2,\$L$3#;
				$store_file_array[$address] = "bne \$$1,\$$2,$label[$3]\n";
				$branch_line_number[$index]= $address;
				$index++;
				$address++;
				put_nop();
			}
		if($values[1] eq "beq"){
				$values[2] =~ s#\$(.+),\$(.+),\$L(\d+)#\$$1,\$$2,\$L$3#;
				$store_file_array[$address] = "beq \$$1,\$$2,$label[$3]\n";
				$branch_line_number[$index]= $address;
				$index++;
				$address++;
				put_nop();
			}
		if($values[1] eq "j"){
				$values[2] =~ s#\$L(\d+)#\$L$1#;
#replace with beq instruction with line number as in .s file as 3rd parameter.
				$store_file_array[$address] = "beq \$0,\$0,$label[$1]\n";
#store the line number of this instruction as in our_assembly.txt file inorder to access it later. 
				$branch_line_number[$index]= $address;
#increment the address to go to next empty location in array.
				$index++;
				
				$address++;
				put_nop();
			}
			
		if($values[1] eq "add"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "add \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "addu"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "add \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "sub"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "sub \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
		
		if($values[1] eq "subu"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "sub \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "and"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "and \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "andi"){
				$values[2] =~ s#\$(.+),\$(.+),(\d+)#\$$1,\$$2,$3#;
				$store_file_array[$address] = "addi \$1,\$0,$3\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "and \$$1,\$$2,\$1\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "or"){
				#print "=======add line = $.=======\n";
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "or \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
			
		if($values[1] eq "ori"){
				$values[2] =~ s#\$(.+),\$(.+),(\d+)#\$$1,\$$2,$3#;
				$store_file_array[$address] = "addi \$1,\$0,$3\n";
				$address++;
				put_nop();
				$store_file_array[$address] = "or \$$1,\$$2,\$1\n";
				$address++;
				put_nop();
			}
		
		if($values[1] eq "not"){
				$values[2] =~ s#\$(.+),\$(.+)#\$$1,\$$2#;
				$store_file_array[$address] = "not \$$1,\$$2\n";
				$address++;
				put_nop();
			}
			
			
		if($values[1] eq "xor"){
				$values[2] =~ s#\$(.+),\$(.+),\$(.+)#\$$1,\$$2,\$$3#;
				$store_file_array[$address] = "xor \$$1,\$$2,\$$3\n";
				$address++;
				put_nop();
			}
		} #end of line-bounded if
 	}#end of while

close(MYFILE); 	

sub put_nop {
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
}

sub put_nop_lw {
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
		$store_file_array[$address] = "nop\n";
		$address++;
}

#display mapping of .s file with our_assembly.txt
=print mapping
my $v1 = 0;
my $op=0;
for( $v1 = $line_num_start+1 ;$v1 < $line_num_end; $v1++)
{
	print "$v1 - ";
	my $op = $map[$v1];
	print "$op\n";

}
=cut

#this loop iterates through the branch_line_number array and outputs the line number in in our_assembly.txt
#this locates the branch statement in out_assembly.txt.
#now the 3rd parameter here is mapped from .s file to our_assembly.txt to give accurate label locations

for (my $v = 0 ; $v < $index  ; $v++){
	 #print "$store_file_array[$branch_line_number[$v]]\n";
	 $store_file_array[$branch_line_number[$v]] =~ s#(\w+) \$(\d+),\$(\d+),(\d+)#$1 \$$2,\$$3,$4#;
	 #print "$1,$2,$3,$4\n";
	 my $subs = $map[$4];
	 $store_file_array[$branch_line_number[$v]] =~ s/$4/$subs/g;	 
	 #print $subs;
	 #print "\n";
}


print FILE @store_file_array;

close (FILE);
