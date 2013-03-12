# For Emacs: -*- mode:cperl; mode:folding -*-

package Lingua::AFR::Word2Num;
# ABSTRACT: Word 2 number conversion in AFR.

# {{{ use block
#

use 5.10.1;

use strict;
use warnings;

use Perl6::Export::Attrs;

use Parse::RecDescent;

# }}}
# {{{ variable declarations

our $VERSION = 0.0682;

our $INFO = {
    rev  => '$Rev: 682 $',
};

my $parser = af_numerals();
# }}}

# {{{ w2n                                         convert number to text
#
sub w2n :Export {
    my $input = shift // return;

    $input =~ s/,//g;
    $input =~ s/ //g;

    return $parser->numeral($input);
}
# }}}
# {{{ af_numerals                                 create parser for numerals

sub af_numerals {
    return Parse::RecDescent->new(q{
      numeral: million   { return $item[1]; }                         # root parse. go from maximum to minimum value
        |      millenium { return $item[1]; }
        |      century   { return $item[1]; }
        |      decade    { return $item[1]; }
        |                { return undef; }

      number: 'nul'        { $return = 0; }                           # try to find a word from 0 to 19
        |     'een'        { $return = 1; }
        |     'twee'       { $return = 2; }
        |     'drie'       { $return = 3; }
        |     'vier'       { $return = 4; }
        |     'vyf'        { $return = 5; }
        |     'ses'        { $return = 6; }
        |     'sewe'       { $return = 7; }
        |     'agt'        { $return = 8; }
        |     'nege'       { $return = 9; }
        |     'tien'       { $return = 10; }
        |     'elf'        { $return = 11; }
        |     'twaalf'     { $return = 12; }
        |     'dertien'    { $return = 13; }
        |     'viertien'   { $return = 14; }
        |     'vyftien'    { $return = 15; }
        |     'sestien'    { $return = 16; }
        |     'sewentien'  { $return = 17; }
        |     'agtien'     { $return = 18; }
        |     'negentien'  { $return = 19; }

      tens:   'twintig'  { $return = 20; }                            # try to find a word that representates
        |     'dertig'   { $return = 30; }                            # values 20,30,..,90
        |     'viertig'  { $return = 40; }
        |     'vyftig'   { $return = 50; }
        |     'sestig'   { $return = 60; }
        |     'sewentig' { $return = 70; }
        |     'tagtig'   { $return = 80; }
        |     'negentig' { $return = 90; }

      decade: number(?) 'en' tens(?)                                  # try to find words that represents values
              { $return = -1;                                         # from 0 to 99
                for (@item) {
                  if (ref $_ && defined $$_[0]) {
                    $return += $$_[0] if ($return != -1);             # -1 if the non-zero identifier, since
                    $return  = $$_[0] if ($return == -1);             # zero is a valid result
                  }
                }
                $return = undef if ($return == -1);
              }
        |     number(?) tens(?)
              { $return = -1;
                for (@item) {
                  if (ref $_ && defined $$_[0]) {
                    $return += $$_[0] if ($return != -1);             # -1 if the non-zero identifier, since
                    $return  = $$_[0] if ($return == -1);             # zero is a valid result
                  }
                }
                $return = undef if ($return == -1);
              }
        |     'en' number(?)
              { $return = -1;
                for (@item) {
                  if (ref $_ && defined $$_[0]) {
                    $return += $$_[0] if ($return != -1);             # -1 if the non-zero identifier, since
                    $return  = $$_[0] if ($return == -1);             # zero is a valid result
                  }
                }
                $return = undef if ($return == -1);
              }


      century: number(?) 'honderd' decade(?)                          # try to find words that represents values
               { $return = 0;                                         # from 100 to 999
                 for (@item) {
                   if (ref $_ && defined $$_[0]) {
                     $return += $$_[0];
                   } elsif ($_ eq "honderd") {
                     $return = ($return>0) ? $return * 100 : 100;
                   }
                 }
                 $return = undef if (!$return);
               }

    millenium: century(?) decade(?) 'duisend' century(?) decade(?)    # try to find words that represents values
               { $return = 0;                                         # from 1.000 to 999.999
                 for (@item) {
                   if (ref $_ && defined $$_[0]) {
                     $return += $$_[0];
                   } elsif ($_ eq "duisend") {
                     $return = ($return>0) ? $return * 1000 : 1000;
                   }
                 }
                 $return = undef if (!$return);
               }

      million: millenium(?) century(?) decade(?)                      # try to find words that represents values
               'miljoen'                                              # from 1.000.000 to 999.999.999.999
               millenium(?) century(?) decade(?)
               { $return = 0;
                 for (@item) {
                   if (ref $_ && defined $$_[0]) {
                     $return += $$_[0];
                   } elsif ($_ eq "miljoen") {
                     $return = ($return>0) ? $return * 1000000 : 1000000;
                   }
                 }
                 $return = undef if (!$return);
               }
    });
}

# }}}

1;

__END__

# {{{ POD HEAD

=pod

=head1 NAME

Lingua::AFR::Word2Num

=head1 VERSION

version 0.0682

Text to positive number convertor for Afrikaans.

Input text must be encoded in utf8.

=head2 $Rev: 682 $

ISO 639-3 namespace

=head1 SYNOPSIS

 use Lingua::AFR::Word2Num;

 my $num = Lingua::AFR::Word2Num::w2n( 'een honderd, drie en twintig' );

 print defined($num) ? $num : "sorry, can't convert this text into number.";

=head1 DESCRIPTION

Word 2 number conversion in AFR.

Lingua::AFR::Word2Num is module for converting text containing number
representation in afrikaans back into number. Converts whole numbers from 0 up
to 999 999 999 999.

=cut

# }}}
# {{{ Functions Reference

=pod

=head2 Functions Reference

=over 2

=item w2n (positional)

  1   string  string to convert
  =>  number  converted number
      undef   if input string not known

Convert text representation to number.

=item af_numerals

=back

=cut

# }}}
# {{{ POD FOOTER

=head1 EXPORT_OK

w2n

=head1 KNOWN BUGS

None.

=head1 AUTHOR

 Vitor Serra Mori <info@petamem.com>

=head1 COPYRIGHT

Copyright (C) PetaMem, s.r.o. 2004-present

=head2 LICENSE

Artistic license or BSD license.

=cut

# }}}
