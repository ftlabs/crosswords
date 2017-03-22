#!/usr/bin/perl
use strict;

my $cws = {};
my $pdf;

my $months = {
  'March'    => 3,
  'February' => 2,
  'January'  => 1
};

# <a href="http://im.ft-static.com/content/images/7aa9517c-0025-11e7-96f8-3700c5664d30.pdf" >
# March 15 2017: Puzzle 15,498

foreach my $line (`cat crosswords.txt`){
  if ( $line =~ /(http:.*pdf)/ ) {
    $pdf = $1;
  } elsif( $line =~ /(\w+) (\d+) (\d+): (\w+)(?: no\.)? ([\d,]+)/ ) {
    my $monthName = $1;
    my $day   = $2;
    my $year  = $3;
    my $name  = $4;
    my $num   = $5;

    if ($name eq 'Puzzle') {
      $name = 'Crossword';
    }

    my $month  = $months->{$monthName};
    my $id = "$name $num";

    my $cStruct = {
      'id'   => $id,
      'date' => $year.'-'.$month.'-'.$day,
      'pdf'  => $pdf
    };

    $cws->{ $cStruct->{'id'} } = $cStruct;
    print "added id=".$cStruct->{'id'}."\n";
  }
}

# <p><strong>Crossword 15,490</strong>: J Mills, Grappenhall, Cheshire</p>

foreach my $line (`cat winners.txt`){
  if ( $line =~ /<strong>(\w+) ([\d,]+)<\/strong>: (.+)<\/p>/ ) {
    my $name    = $1;
    my $num     = $2;
    my $winners = $3;

    my $id = "$name $num";

    if (exists $cws->{$id} ) {
      my $cStruct = $cws->{ $id };
      $cStruct->{'winners'} = [ split(/;/, $winners ) ];
      print "found matching crossword for id=$id\n";
    } else {
      print "Error: no matching crossword for id=$id\n";
    }
  }
}

my @cIds = keys(%$cws);

# ---
# layout: crossword-pdf
# crossword-id: Polymath 907
# author: Gozo
# pdf: https://im.ft-static.com/content/images/8e5ae332-fcf8-11e6-96f8-3700c5664d30.pdf
# height: 800px
# winners:
# - I Roberts, London, SW18
# ---

foreach my $id (@cIds){
  my $cStruct = $cws->{ $id };
  my @lines = (
    '---',
    'layout: crossword-pdf',
    'crossword-id: ' . $id,
    'pdf: ' . $cStruct->{'pdf'}
  );

  if ( exists $cStruct->{'winners'} ) {
    push @lines, 'winners:';
    foreach my $winner (@{$cStruct->{'winners'}}){
      push @lines, '- '.$winner;
    }
  }

  push @lines, '---';
  print join("\n", @lines), "\n";
}
