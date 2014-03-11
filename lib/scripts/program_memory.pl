#!/usr/bin/perl -w
use lib "/usr/local/netfpga/lib/Perl5";
use strict;
use Getopt::Long;

my $COMMAND = 0x2000300;
my $DATA_HIGH = 0x2000304;
my $DATA_LOW = 0x2000308;
my $DATA_ADDR = 0x200030c;

my $file_name;
my $result = GetOptions ("file_name=s" => \$file_name);    # Taking input from command line.

my $file = "$file_name";
print "The file path is $file\n";
open (MYFILE, $file)
  or die "cannot open < $file $!";


my $i = 0;
while (<MYFILE>) {
        chomp;
        my @line = split (',');
        print "addr = $i\tdata = 0x$line[0] 0x$line[1]\n";
        system("regwrite $COMMAND 0x204");                # Default mode of execution
        system("regwrite $DATA_ADDR $i");          # address of where to program
        system("regwrite $DATA_HIGH 0x$line[0]");         # Store high word
        system("regwrite $DATA_LOW 0x$line[1]");          # store low wor
        system("regwrite $COMMAND 0x202");                 # Program the memory with this data.
        #sleep(0.1);
        select(undef, undef, undef, 0.10);
        system("regwrite $COMMAND 0x204");                 # Stop programming the memory
        $i++;
    }
close MYFILE or die "Can't close file: $!";


