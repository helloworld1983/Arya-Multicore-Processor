#!usr/bin/perl
use strict;
use warnings;

my $COMMAND = 0x2000300;
my $DATA_HIGH = 0x2000310;
my $DATA_LOW = 0x2000314;
my $DATA_ADDR = 0x200030c;

select(undef, undef, undef, 1);
system("regwrite $COMMAND 0x0"); 
select(undef, undef, undef, 5);
system("regwrite $COMMAND 0x4"); 
select(undef, undef, undef, 1);
system("regwrite $COMMAND 0x204"); 
select(undef, undef, undef, 1);

my $location = 512;
while ($location != 1024) {

        #print "addr = $i\tdata = 0x$line[0] 0x$line[1]\n";
        system("regwrite $DATA_ADDR $location");          # address of where to program
        select(undef, undef, undef, 0.20);
        system("regread $DATA_LOW | tee -a output.txt");
        select(undef, undef, undef, 0.20);
        $location++;
}
