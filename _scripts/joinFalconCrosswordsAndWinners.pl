#!/usr/bin/perl

# Run with no args in _scripts dir.
# Will generate (or update) the _posts/* files containing the front matter for each crossword.

use strict;

# pull latest content from live site
my $source_crosswords_url = "https://www.ft.com/crossword";
my $crossword_html = `wget -O- $source_crosswords_url | grep "Latest Puzzles"`;
my @crossword_lines = split(/<li>/, $crossword_html);
die "ERROR: no crossword_lines" if scalar(@crossword_lines) == 0;

my $source_winners_url = "https://www.ft.com/content/a5c6b91c-1ae2-11e7-9519-a200b6e21c5a";
my $winners_html = `wget -O- $source_winners_url | grep "<p><strong>"`;
my @winners_lines = split(/<\/p>/, $winners_html);
die "ERROR: no winners_lines" if scalar(@winners_lines) == 0;

print "INFO: num crossword_lines = ", scalar(@crossword_lines), "\n";
print "INFO: num winners_lines = ", scalar(@winners_lines), "\n";

my $cws = {};
my $pdf;

my $months = {
  'December'  => 12,
  'November'  => 11,
  'October'   => 10,
  'September' =>  9,
  'August'    =>  8,
  'July'      =>  7,
  'June'      =>  6,
  'May'       =>  5,
  'April'     =>  4,
  'March'     =>  3,
  'February'  =>  2,
  'January'   =>  1
};


foreach my $line (@crossword_lines) {
  # print "INFO: crossword line = ${line}\n";
  # <a href="http://im.ft-static.com/content/images/f91627b6-10aa-11e7-a88c-50ba212dce4d.pdf" data-trackable="link" target="_blank">April 1 2017: Puzzle 15,513</a></li></ul>
  if( $line =~ /a href="(http:[^"]+)".*>(\w+) (\d+) (\d+): (\w+)(?: [nN]o\.)? ([\d,]+)</ ) {
    my $cStruct;
    my $pdf = $1;
    my $monthName = $2;
    my $day   = $3;
    my $year  = $4;
    my $name  = $5;
    my $num   = $6;

    if ( $pdf =~ /^http:/\/\(.+)\/([0-9a-f\-]+)/ ) {
      my $pdfdomain = $1;
      my $uuid = $2;
      my $pdfImg;
      if ($pdfdomain === 'prod-upp-image-read.ft.com') {
        # new: http://prod-upp-image-read.ft.com/5bb7800e-c06e-11e7-9836-b25f8adaa111
        # --> https://www.ft.com/__origami/service/image/v2/images/raw/ftcms:5bb7800e-c06e-11e7-9836-b25f8adaa111?source=crosswordsftcom

        $pdfImg = "https://www.ft.com/__origami/service/image/v2/images/raw/ftcms:${uuid}?source=crosswordsftcom";

      } else {
        # old: http://im.ft-static.com/content/images/2ee065ac-acbc-11e7-aab9-abaa44b1e130.pdf
        # --> https://www.ft.com/__origami/service/image/v2/images/raw/http:im.ft-static.com/content/images/2ee065ac-acbc-11e7-aab9-abaa44b1e130.pdf?source=crosswordsftcom

        $pdfImg = "https://www.ft.com/__origami/service/image/v2/images/raw/http:im.ft-static.com/content/images/${uuid}.pdf?source=crosswordsftcom";
      }

      $cStruct = {
        'pdf'      => $pdf,
        'uuid'     => $uuid,
        'pdfImg'   => $pdfImg,
      }
    } else {
      die "ERROR: could not parse pdf url to obtain the uuid: $pdf";
    }

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
  } else {
    print "DEBUG: unmatched crossword line=${line}\n";
  }
}

my @cIds = sort(keys(%$cws));
print "INFO: num crosswords identified = ", scalar @cIds, ", ids=", join(",", @cIds), "\n";
die "ERROR: no crosswords identified" if scalar( @cIds ) == 0;

# <p><strong>Crossword 15,490</strong>: J Mills, Grappenhall, Cheshire</p>

my $count_matched_winners = 0;
my @unmatched_ids = ();
my @matched_ids = ();

foreach my $line (@winners_lines){
  if ( $line =~ /<strong>(\w+) ([\d,]+)<\/strong>: (.+)/ ) {
    my $name    = $1;
    my $num     = $2;
    my $winners = $3;

    my $id = "$name $num";

    if (exists $cws->{$id} ) {
      my $cStruct = $cws->{ $id };
      $winners =~ s/&amp;/&/g;
      $cStruct->{'winners'} = [ split(/;/, $winners ) ];
      push( @matched_ids, $id);
      $count_matched_winners += 1;
    } else {
      push( @unmatched_ids, $id );
    }
  }
}

print "INFO: num matched_ids = ", scalar( @matched_ids ), ", ids=", join(",", @matched_ids), "\n";
print "INFO: num unmatched_ids = ", scalar( @unmatched_ids ), ", ids=", join(",", @unmatched_ids), "\n";

die "ERROR: no matched winners" if $count_matched_winners == 0;

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
      'pdf-as-img: ' . $cStruct->{'pdfImg'},
            'type: ' . 'static',
          'source: ' . 'FT.com',
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
