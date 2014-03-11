#!usr/bin/perl
use strict;
use warnings;

my $COMMAND = 0x2000300;
my $DATA_HIGH = 0x2000310;
my $DATA_LOW = 0x2000314;
my $DATA_ADDR = 0x200030c;

system("regwrie $COMMAND 0x204"); 

my $location = 512;
while ($location != 1024) {

        #print "addr = $i\tdata = 0x$line[0] 0x$line[1]\n";
        system("regwrite $DATA_ADDR $location");          # address of where to program
        #system("regread $DATA_HIGH | tee -a output.txt");
        system("regread $DATA_LOW | tee -a output.txt");
        #print MYFILE ($location - 512)."\t".$data_high.",".$data_low."\n";
        #sleep(0.1);
        select(undef, undef, undef, 0.1);
        $location++;
}
