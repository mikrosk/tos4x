#!/util/bin/perl
#                               -*- Perl -*- 
#
# g2m - translate Unix/Gnu gas syntax to motorola (well madmac) syntax
#
# Usage:
#   perl g2m files ....
#     all translated output to stdout.
#
# Known limitations:
#   - probably does not handle every addressing mode.
#
#   - some .directives are not handled (see %direct_map below). i dont think
#     any of them are really significant, except maybe .float. i put it
#     there because i dont know what to translate .float to! (ok so i could
#     read the madmac manual, but i am lazy, and for now i dont know
#     where i put it!).
#
#   - some forms of constant may need translation. i translate 0xNNNN
#     to $NNNN, but i dont know about octal or other radix forms.
#     float constants are not touched (because i dont know what they
#     should translate to).
#
#   - if a '|' or '#' appears inside a string, then rest of the line
#     is taken to be a comment, from the first appearance of the char.
#
#   - i translate common cases \NN octals in strings (\t,\r,\n), but
#     leave the rest alone. madmac will complain, but the above cover
#     the most commonly occuring cases. (oh i also handle the \0 at 
#     the end of the string case).
#
#   - i dont do any case translation. some of the moto asm's i have seen
#     are case insensitive (and people seem to write in all uppercase) and
#     want to make me barf!
#
#   - .comm and .lcomm must appear at the end (gcc will always do this)
#     since i switch to .bss. If it does'nt and something follows then
#     it must first issue a suitable segment directive.
#     NOTE: for madmac apratt suggested using .common. i still have
#           to do this. i can't find my madmac man to lookup
#           the .common syntax!
#
#   - no attempt is made at preserving white space between the source and
#     the translation.
#
#   - there is one incompatibility in the label syntax recognized here
#     vs standard unix as (but not gas). a label can have whitespace
#     ([ \t]+) between the end of the label and the following ':'.
#
#   - labels with a trailing '.' have the trailing '.' lopped off. this
#     is because madmac complains that '.' should be followed by a 
#     [bwls]. this is definitely a bug in madmac. '.' is a valid label
#     character (or atleast i think i had seen that in the doc).
#
#   - madmac does not know how to handle auto labels '<number>[f|b]'
#     and barfs on 'bra 0f' etc. Anyone with ideas about what to do with
#     these?
#
#   - the translation assumes that labels referenced but not defined
#     or declared globl are implicitly xref's. i think madmac atleast
#     has a option to say this (otherwise it complains about unreferenced
#     expressions or some such).
#   
#   - it converts all jCC forms of jumps to the longer bCC form rather
#     than the shorter bCC.s form. this is ok because madmac (and probably
#     other asms) will optimize the longer forms as needed (or atleast in
#     the backward direction).
#
#   - probably more, but thats all i can think of right now. It should be
#     fairly straight forward to extend this to cover more cases. if you send
#     me specific examples i will try and extend for you.
#
# WARNINGS:
#   this is a quick hack. will get you 90% there so dont blindly use it.
#   i wrote this when learning perl many years ago, so its not pretty.
#   if you think you can write it better be my guest, and send source!
#
#   ++jrb    bammi@cadence,com
#
# $Revision: 1.2 $
#

die "usage: g2m files...\n" if $#ARGV < $[;

$debug = 0;

#
# map of .directives (suggestions welcome)
#
%direct_map = (
#     Gas	  Mac

#  punt on the hard stuff
    '.abort',	'* dont know how to .abort',
    '.align',	'* dont know how to .align',
    '.desc',	'* dont know how to .desc',
    '.file',	'* dont know how to .file',
    '.line',	'* dont know how to .line',
    '.fill',	'* dont know how to .fill',
    '.float',	'* dont know how to .float',
    '.lsym',	'* dont know how to .lsym',
    '.octa',	'* dont know how to .octa',
    '.quad',	'* dont know how to .quad',
    '.space',	'* dont know how to .space',

# easy ones
    '.text',	'.text',
    '.data',	'.data',
    '.even',	'.even',
    '.globl',	'.globl',
    '.byte',	'.dc.b',
    '.int',	'.dc.l',
    '.long',	'.dc.l',
    '.short',	'.dc.w',
    '.word',	'.dc.w',
    '.org',	'.org'

# the really hard ones
#    .set		handled in &process_directive
#    .comm		handled in &process_directive
#    .lcomm		handled in &process_directive
#    .ascii		handled in &process_directive
#    .asciz		handled in &process_directive
);

foreach $file (@ARGV) {
  open(FILE, $file) || die "Could'nt open $file for read";
  print ";\n; Translation of $file by g2m.\n",
        ";  checking  the translation is HIGHLY recommended.\n;\n";
  while(<FILE>) {
    chop; s/^[ \t]+//;      # get rid of trailing \n and leading spaces
    if(/^$/) {		# empty line
      print "-- empty --" if $debug;
      print "\n";
    } elsif (/^[#\|]/) {  # comment line
      s/^[#\|]/;/;
      print "-- comment --" if $debug;
      print $_, "\n";
    } else {
      # weed out trailing comment if there is one
      local($comment) = undef;
      if(/\|/) {
	local($lead);
	($lead, $comment) = split(/\|/, $_, 2);
	$_ = $lead;
      }
      # weed out the label if there is one
      if(/^(([A-Za-z_][A-Za-z0-9_.]*)|([0-9]+))\s*:/) {
	local($label, $rest) = split(/:/, $_, 2);
	print "-- label--" if $debug;
	$label =~ s/\.$//;
	print $label, ':';
	$_ = $rest;
      }
      s/^[ \t]+//;
      if(!(/^$/)) {
	local($opcode, $rest) = split(/[ \t]+/, $_, 2);
	if($opcode =~ /^\./) {
	  &process_directive($opcode, $rest);
	} else {
	  &process_opcode($opcode);
	  if(length($rest) > 0) {
	    &process_operands($rest);
          }
	}
      }
      print ' ; ', $comment if defined($comment);
      print "\n";
    }
  } # while
  close(FILE);
} # foreach


sub process_directive {
  local($directive, $rest) = @_;
  if($directive eq '.set') {
    local($var, $exp) = split(/,/, $rest, 2);
    print $var, " = ", $exp;
  } elsif ($directive eq '.comm') {
    local($label, $bytes) = split(/,/, $rest);
    print "\t.bss\n\t.even\n\t.globl\t", $label, "\n", $label,
          ":\t.ds.b\t", $bytes;
  } elsif ($directive eq '.lcomm') {
    local($label, $bytes) = split(/,/, $rest);
    print "\t.bss\n\t.even\n", $label, ":\t.ds.b\t", $bytes;
  } elsif ($directive eq '.ascii') {
    print "\t.dc.b\t";
    &put_string($rest);
  } elsif ($directive eq '.asciz') {
    print "\t.dc.b\t";
    &put_string($rest);
    print ',0';
  } else {
    die "Can't process '$directive'\n"
	   unless defined($direct_map{$directive});
    print "\t", $direct_map{$directive}, "\t", $rest;
  }
}

sub process_opcode {
  local($opcod) = @_;
  local($size) = undef;
  if(length($opcod) > 3) {
    if($opcod =~ /(.+)([lwbs])$/) {
      $opcod = $1;
      $size = $2;
    }
  }
  if($opcod =~ /(or)([lwb])$/) {
    $opcod = $1;
    $size = $2;
  } elsif ($opcod =~ /mov$/) {
    $opcod = "move";
  } elsif ($opcod =~ /movm$/) {
    $opcod = movem;
  } elsif ($opcod eq "jbsr") {
    $opcod = "jsr";
  } elsif ($opcod eq "jmp") {
    # nothing, here to avoid following match
  } elsif ($opcod =~ /j(.+)$/) {
    $opcod = 'b' . $1;
  }
  print "\t", $opcod;
  print ".$size" if defined($size);
}

sub process_operands {
  local($line) = @_;
  local(@operands);
  local($first) = 1;
  $line =~ s/^[ \t]+//;
  $line =~ s/[ \t]+$//;
  @operands = split(/,/, $line);
  print "\t";
  while ($_ = $operands[0]) {
    
    if($first == 1) {
      $first = 0;
    } else {
      print ', ';
    }
    
    if(/.+@\([^)]+$/) { # join back any over-enthusiastic splits on ','
    shift @operands;
    $_ = $_ . ',' . $operands[0];
    }
  
    s/0[xX]([0-9A-Fa-f]+)/\$\1/g;
    if(/(.+)@\((.+),([ad][0-7]):(.).*\)/) {
      print '(', $2, ',', $1, ',', $3, '.', $4, ')';
    } elsif (/(.+)@\(([ad][0-7]):(.).*\)/) {
      print   '(0,', $1, ',', $2, '.', $3, ')';
    } elsif (/(.+)@\((.+)\)/) {
      print $2, '(', $1, ')';
    } elsif (/(.+)@\+/) {
      print '(', $1, ')+';
    } elsif (/(.+)@-/) {
      print '-(', $1, ')';
    } elsif (/(.+)@$/) {
      print '(', $1, ')';
    } elsif (/([-+]*[$]*[0-9]+):([lwb])$/) {
      print $1, '.', $2;
    } else {
      print $_;
    }
    shift @operands;
  }
}

sub put_string {
  local($str) = @_;
#get the common cases, madmac will complain about the rest
  $str =~ s/\\11/\\t/g;
  $str =~ s/\\15/\\r/g;
  $str =~ s/\\12/\\n/g;
  if($str =~ /\\0"$/) {
      $str =~ s/\\0"$/"/;
      print $str, ", 0\n";
  } else {
      print $str;
  }
}
# EOF
