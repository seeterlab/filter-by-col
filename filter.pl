#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling auto_version);
use Pod::Usage;
use List::Util qw(min max);

our $VERSION = '1.0';

our $optionKey1Indexes = '1';
our $optionKey2Indexes = '1';
our $optionKeyIndexes = undef;
our $optionInvertMatch = 0;
our $man = 0;
our $help = 0;

our @key1Slice;
our @key2Slice;
our %hash;
our $maxKey1Index;
our $maxKey2Index;

#================================================================================
#================================================================================
sub defineKeySlice {
  my $keyIndexes = shift;

  my @keySlice = split /,/, $keyIndexes;
  return map { $_ -1 } @keySlice;
}


#================================================================================
#================================================================================
sub getMaxIndex {
  my @keySlice = @_;

  # On compare à 0 car on a déjà retranché 1 aux index spécifiés sur la ligne de commande
  pod2usage("column number must be one based !")
    if min(@keySlice) < 0;
  return max(@keySlice);
}


#================================================================================
#================================================================================
sub readFile1 {
  open(my $file1, '<', shift @ARGV) or die "$!\n";
  while (<$file1>) {
    # Découpe la ligne sur les espaces
    my @F = split /\s+/;
    
    # Vérifie que le nombre de colonne convient
    pod2usage("expected column " . ($maxKey1Index + 1) . " is missing at line $. in file1")
      if @F <= $maxKey1Index;

    # Défini la clef à l'aide de @key1Slice
    my $key = join('-', @F[@key1Slice]);

    # Rempli la table de hashage
    $hash{$key}++;
  }
}


#================================================================================
#================================================================================
sub readFile2 {
  # Lit file2 ou stdin
  while (<>) {
    # Découpe la ligne sur les espaces
    my @F = split /\s+/;

    # Vérifie que le nombre de colonne convient
    pod2usage("expected column " . ($maxKey2Index + 1) . " is missing at line $. in file2")
      if @F <= $maxKey2Index;

    # Défini la clef à l'aide de @key2Slice
    my $key = join('-', @F[@key2Slice]);

    if ($optionInvertMatch) {
      # Affiche les lignes qui ne matchent pas
      print unless $hash{$key};
    }
    else {
      # Affiche les lignes qui matchent
      print if $hash{$key};
    }
  }
}


#================================================================================
# main
#================================================================================

GetOptions('help|h' => \$help, man => \$man,
           'v|invert-match' => \$optionInvertMatch,
           'k|key=s' => \$optionKeyIndexes,
           'a|key1=s' => \$optionKey1Indexes,
           'b|key2=s' => \$optionKey2Indexes) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;

pod2usage(2) if ( @ARGV < 1 || @ARGV > 2 );

if (defined $optionKeyIndexes) {
  $optionKey1Indexes = $optionKeyIndexes;
  $optionKey2Indexes = $optionKeyIndexes;
}

@key1Slice = defineKeySlice($optionKey1Indexes);
@key2Slice = defineKeySlice($optionKey2Indexes);
$maxKey1Index = getMaxIndex(@key1Slice);
$maxKey2Index = getMaxIndex(@key2Slice);

readFile1();
readFile2();

#================================================================================
# POD
#================================================================================
__END__

=head1 NAME

filter.pl - Filter B<file_to_filter.txt> with B<reference_file.txt>

=head1 SYNOPSIS

filter.pl [-v|--invert-match] [-a|--key1 num,num,...] [-b|--key2 num,num,...] B<reference_file.txt> [B<file_to_filter.txt>]

or

filter.pl [-v|--invert-match] [-k|--key num,num,...] B<reference_file.txt> [B<file_to_filter.txt>]

or

filter.pl [--help|--man]

=head1 OPTIONS

=over 4

=item B<-v|--invert-match>

If specified, match is inverted: print lines that do not match those of B<reference_file.txt>.

=item B<-a|--key1>

Specify one based and comma separated column numbers to consider for B<reference_file.txt>.
Default value: 1

=item B<-b|--key2>

Specify one based and comma separated column numbers to consider for B<file_to_filter.txt>.
Default value: 1

=item B<-k|--key>

Specify one based and comma separated column numbers to consider for B<reference_file.txt> and B<file_to_filter.txt>.
Default value: 1

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<filer.pl> filters B<file_to_filter.txt> with B<reference_file.txt> based on the specified key columns.
Files do not have to be sorted.
If B<file_to_filter.txt> is omitted, stdin is read instead.


=head1 EXAMPLES

=head2 Same key columns order in both files

If the key column numbers are in the same order in both files, you can specify those numbers with B<-k> (or --key):

    filter.pl -k 1,2 B<reference_file.txt> B<file_to_filter.txt>

=head2 Different key columns order in each file

If the key column numbers are NOT in the same order in both files, use B<-a> and B<-b> (or --key1 and --key2):

    filter.pl -a 1,2 -b 3,1 B<reference_file.txt> B<file_to_filter.txt>

=head2 Reading from stdin

If B<file_to_filter.txt> is omitted, sdtin is read instead:

    cat B<file_to_filter.txt> | filter.pl -k 1,2 B<reference_file.txt>

=head1 SAMPLE FILES

If B<reference_file.txt> and B<file_to_filter.txt> have the following content:

=head2 reference_file.txt

    1	abc	13259250
    1	def	13282200
    1	ijkl	13323300
    1	mnop	13345050
    1	qr	13371150
    1	stuvx	13475700
    2	XYZ	2437050
    2	TOTO	2459700
    2	TITI	2591100
    2	THING	2615700
    2	OTHER	2657400

=head2 file_to_filter.txt

    1325 13253660 	 1 260
    ijkl 13255820 	 1 200
    1325 13259040 	 1 380
    1327 13278020 	 1 200
    1327 13278420 	 1 220
    1331 13316320 	 1 200
    mnop 13319760 	 1 200
    1332 13322380 	 1 200
    1335 13359500 	 1 300
    1335 13360140 	 1 280
    abc 13364080 	 1 340
    1336 13368240 	 1 460
    1346 13467580 	 1 200
    1353 13537860 	 1 200
    1354 13542460 	 1 440
    1354 13544660 	 1 200
    1354 13545160 	 1 420
    5117 5117260 	 2 260
    5166 5167060 	 2 200
    TOTO 5169100 	 2 220
    5169 5169680 	 2 320
    5214 5215020 	 2 320
    5390 5391120 	 2 660
    5391 5391820 	 2 220
    5419 5419660 	 2 200
    5509 5510260 	 2 620
    5511 5511820 	 2 220
    XYZ 5512820 	 2 440
    5539 5539700 	 2 200

=head2 Showing matching lines in file_to_filter.txt

The following command produces the output below:

    filter.pl -a 1,2 -b 3,1 B<reference_file.txt> B<file_to_filter.txt>

    ijkl 13255820 	 1 200
    mnop 13319760 	 1 200
    abc  13364080 	 1 340
    TOTO 5169100  	 2 220
    XYZ  5512820 	 2 440

=head2 Showing NOT matching lines in file_to_filter.txt

The following command produces the output below:

    filter.pl -v -a 1,2 -b 3,1 B<reference_file.txt> B<file_to_filter.txt>

    1325 13253660 	 1 260
    1325 13259040 	 1 380
    1327 13278020 	 1 200
    1327 13278420 	 1 220
    1331 13316320 	 1 200
    1332 13322380 	 1 200
    1335 13359500 	 1 300
    1335 13360140 	 1 280
    1336 13368240 	 1 460
    1346 13467580 	 1 200
    1353 13537860 	 1 200
    1354 13542460 	 1 440
    1354 13544660 	 1 200
    1354 13545160 	 1 420
    5117 5117260 	 2 260
    5166 5167060 	 2 200
    5169 5169680 	 2 320
    5214 5215020 	 2 320
    5390 5391120 	 2 660
    5391 5391820 	 2 220
    5419 5419660 	 2 200
    5509 5510260 	 2 620
    5511 5511820 	 2 220
    5539 5539700 	 2 200

