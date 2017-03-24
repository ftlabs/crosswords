#!/usr/bin/perl

# run with no args in _scripts dir, where the dir contains
# - winners.txt (scraped from old page, http://www.ft.com/cms/s/2/48e09c20-fbc7-11e1-87ae-00144feabdc0.html?ft_site=falcon&desktop=true#axzz4cFDHYjuW)
# - crosswords.txt (scraped from http://www.ft.com/life-arts/crossword?ft_site=falcon&desktop=true)
# Will generate (or update) the _posts/* files containing the front matter for each crossword.

use strict;

my $cws = {};
my $pdf;

my $months = {
  'March'    => 3,
  'February' => 2,
  'January'  => 1
};

my $cStruct;

foreach my $line (`cat crosswords.txt`){
  # <a href="http://im.ft-static.com/content/images/7aa9517c-0025-11e7-96f8-3700c5664d30.pdf" >
  if( $line =~ /a href="(http:[^"]+)"/ ) {
    my $pdf = $1;
    if ( $pdf =~ /^http:.+\/([0-9a-f\-]+)/ ) {
      my $uuid = $1;
      # https://www.ft.com/__origami/service/image/v2/images/raw/ftcms:3d995a9e-06cd-11e7-97d1-5e720a26771b?source=chrisg
      $cStruct = {
        'pdf'      => $pdf,
        'uuid'     => $uuid,
        'pdfImg'   => "https://www.ft.com/__origami/service/image/v2/images/raw/ftcms:${uuid}?source=crosswordsftcom",
      }
    } else {
      die "ERROR: could not parse pdf url to obtain the uuid: $pdf";
    }
  # March 15 2017: Puzzle 15,498
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
    my $date = sprintf("%4d-%02d-%02d", $year, $month, $day);
    my $numNoCommas = $num;
    $numNoCommas =~ s/,//g;
    my $filename = "${date}-${name}-${numNoCommas}.html";

    $cStruct->{'id'} = $id;
    $cStruct->{'date'} = $date;
    $cStruct->{'filename'} = $filename;

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
      $winners =~ s/&amp;/&/g;
      $cStruct->{'winners'} = [ split(/;/, $winners ) ];
      print "found matching crossword for id=$id\n";
    } else {
      print "Error: no matching crossword for id=$id\n";
    }
  }
}

my @cIds = sort(keys(%$cws));

# ---
# layout: crossword-pdf
# crossword-id: Polymath 907
# author: Gozo
# pdf: https://im.ft-static.com/content/images/8e5ae332-fcf8-11e6-96f8-3700c5664d30.pdf
# uuid: 123-123-123-123
# pdf-as-img: https://www.ft.com/__origami/service/image/v2/images/raw/ftcms:8e5ae332-fcf8-11e6-96f8-3700c5664d30?source=crosswordsftcom
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
             'pdf: ' . $cStruct->{'pdf'},
            'uuid: ' . $cStruct->{'uuid'},
      'pdf-as-img: ' . $cStruct->{'pdfImg'}
  );

  if ( exists $cStruct->{'winners'} ) {
    push @lines, 'winners:';
    foreach my $winner (@{$cStruct->{'winners'}}){
      push @lines, '- '.$winner;
    }
  }

  push @lines, '---';
  my $filename = '../_posts/'.$cStruct->{'filename'};
  print "creating file=$filename\n";

  # Try to create the output file
  # (open it for writing)
  unless(open OUTPUT, '>'.$filename) {
      die "\nUnable to create '$filename'\n";
  }

  foreach my $line (@lines){
    print OUTPUT "$line\n";
  }

  close OUTPUT;
}
