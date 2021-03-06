#!/usr/bin/perl
use warnings;
use strict;
use Cwd;

my $usage = <<EOF;

USAGE: perl 9prepare_sequence_comparison.pl organism.needle_out organism_ids_mapper.csv <organisms in the right order>

EOF


my $file = shift @ARGV;
my $ids_mapper = shift @ARGV;
my @organisms = @ARGV;

open (IN0, "+<", $ids_mapper);
my $j = 0;
my %HoA;
while (my $line1 = <IN0>) {
	chomp $line1;
	my @fields1 = split "," , $line1;
	for (my $i = 0; $i < scalar(@organisms); $i++){
		push @{$HoA{$organisms[$i]}}, $fields1[$i+1]; #Plus one because first column in the mapper is the ID
	}
}
close(IN0);

# Get letter codes of all analyzed organisms
my $remember = 1;
my @string;
my $multiplier = 1;
for(my $i = 0; $i < scalar(@organisms); $i++){
	my $rnd = int(rand($remember));
	if(${$HoA{$organisms[$i]}}[$rnd] eq "NULL" || (${$HoA{$organisms[$i]}}[$rnd] !~ /^ENS/) ){
		until((${$HoA{$organisms[$i]}}[$rnd] ne "NULL") && (${$HoA{$organisms[$i]}}[$rnd] =~ /^ENS/)){
                        $multiplier++;
			$rnd = int((rand($remember))*$multiplier);
		}
		$string[$i] = ${$HoA{$organisms[$i]}}[$rnd];
	}
	else {
		$string[$i] = ${$HoA{$organisms[$i]}}[$rnd];
	}
	$string[$i] =~ s/[0-9]//g;
}


open (my $needle, '<', $file) or die "Could not open '$file' $! \n";

while (<$needle>) {
	chomp;
	if (/^>($string[0]\d+)/) {
		print "\n".$1.",";
	}
	for(my $i=1; $i < scalar(@organisms); $i++){
		if (/^>($string[$i]\d+)/) {
			print ",".$1.",";
		}
	}
	if ((/^(-+)/)||(/^(\w+)/)) {
		print "".$_;
	} 	
}
close($file);
