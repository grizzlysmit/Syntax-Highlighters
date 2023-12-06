unit module Syntax::Highlighters:ver<0.1.0>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

INIT my $debug = False;
####################################
#                                  #
#  To turn On or Off debuggging    #
#  Comment or Uncomment this       #
#  following line.                 #
#                                  #
####################################
#INIT $debug = True; use Grammar::Debugger;

#use Grammar::Tracer;
INIT "Grammar::Debugger is on".say if $debug;

use Terminal::ANSI::OO :t;

=begin pod

=begin head2

Table of  Contents

=end head2

=item2 L<highlight-var|#highlight-var>
=item2 L<highlight-val|#highlight-val>

=NAME Syntax::Highlighters 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.0
=TITLE Gzz::Text::Utils
=SUBTITLE A Raku module to provide text formatting services to Raku programs.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Gzz-Text-Utils/blob/main/LICENSE>

=begin head1

some syntax highlighting stuff 

=end head1

=end pod
 
#`«««
    ################################################
    #**********************************************#
    #**                                          **#
    #**  Grammars to Syntax Highlight Raku¹ Code **#
    #**               and Values.                **#
    #**                                          **#
    #** 1. not complete or exhaustive.           **#
    #**                                          **#
    #**********************************************#
    ################################################
#»»»

class HighlighterFailed is Exception is export {
    has Str:D $.msg = 'Error: Highlighter Failed.';
    method message( --> Str:D) {
        $!msg;
    }
}


grammar VariablesBase {
    token var          { [ <scalar-var> || <array-var> || <hash-var> || <callable-var> ] }
    token scalar-var   { [ '$' <index> || '$' <twigil>? <identifier> ] }
    token array-var    { [ '@' <index> || '@' <twigil>? <identifier> <array-derref>? ] }
    token array-derref { [ '[' <array-index> ']' ] }
    token array-index  { \d+ }
    token hash-var     { [ '%' <index> || '%' <twigil>? <identifier> <hash-derref>? ] }
    token hash-derref  { [ '«' <key0=.identifier> '»' # only support the simplest case
                           || '<' <key1=.identifier> '>' # again only support the simplest case
                           || '{' '$' <key2=.identifier> '}' ] }
    token callable-var { [ '&' <index> || '&' <twigil>? <identifier> <invoked>? ] }
    token invoked      { '(' .* ')' } # dammed crude #
    token twigil       { [ '*' || '?' || '!' || '.' || '^' || ':' || '=' || '~' ] }
    token index        { '<' <identifier> '>' }
    regex identifier   { \w+ [ '-' \w+ ]* }
}

role VariablesBaseActions {
    method identifier($/) {
        my Str $identifier = ~$/;
        make $identifier;
    }
    method array-index($/) {
        my Int $array-index = +$/;
        make $array-index;
    }
    method array-derref($/) {
        my %array-derref = derref-type => 'array', derref-char => '[', ind => $/<array-index>.made;
        make %array-derref;
    }
    method key0($/) {
        my Str $key0 = ~$/;
        make $key0;
    }
    method key1($/) {
        my Str $key1 = ~$/;
        make $key1;
    }
    method key2($/) {
        my Str $key2 = ~$/;
        make $key2;
    }
    method hash-derref($/) {
        my %hash-derref;
        if $/<key0> {
            %hash-derref = derref-type => 'hash', derref-char => '«', ind => $/<key0>.made;
        } elsif $/<key1> {
            %hash-derref = derref-type => 'hash', derref-char => '<', ind => $/<key1>.made;
        } elsif $/<key2> {
            %hash-derref = derref-type => 'hash', derref-char => '{', ind => $/<key2>.made;
        }
        make %hash-derref;
    }
    method invoked($/) {
        my %invoked = derref-type => 'invoked', derref-char => '(', ind => ~$/;
    }
    method index($/) {
        my %index = type => 'index', sigil => 'TBO', twigil => '<', name => $/<identifier>.made;
        make %index;
    }
    method twigil($/) {
        my $twigil = ~$/;
        make $twigil;
    }
    method scalar-var($/) {
        my %scalar-var;
        if $/<index> {
            %scalar-var = $/<index>.made;
            %scalar-var«type» = 'scalar-var';
            %scalar-var«sigil» = '$';
        } elsif $/<twigil> {
            %scalar-var = type => 'scalar-var', sigil => '$', twigil => $/<twigil>.made, name => $/<identifier>.made;
        } else {
            %scalar-var = type => 'scalar-var', sigil => '$', twigil => '', name => $/<identifier>.made;
        }
        make %scalar-var;
    }
    method array-var($/) {
        my %array-var;
        if $/<index> {
            %array-var = $/<index>.made;
            %array-var«type» = 'array-var';
            %array-var«sigil» = '@';
        } elsif $/<twigil> {
            %array-var = type => 'array-var', sigil => '@', twigil => $/<twigil>.made, name => $/<identifier>.made, derref => {};
        } else {
            %array-var = type => 'array-var', sigil => '@', twigil => '', name => $/<identifier>.made, derref => {};
        }
        if $/<array-derref> {
            %array-var«derref» = $/<array-derref>.made;
        }
        make %array-var;
    }
    method hash-var($/) {
        my %hash-var;
        if $/<index> {
            %hash-var = $/<index>.made;
            %hash-var«type» = 'hash-var';
            %hash-var«sigil» = '%';
        } elsif $/<twigil> {
            %hash-var = type => 'hash-var', sigil => '%', twigil => $/<twigil>.made, name => $/<identifier>.made, derref => {};
        } else {
            %hash-var = type => 'hash-var', sigil => '%', twigil => '', name => $/<identifier>.made, derref => {};
        }
        if $/<hash-derref> {
            %hash-var«derref» = $/<hash-derref>.made;
        }
        make %hash-var;
    }
    method callable-var($/) {
        my %callable-var;
        if $/<index> {
            %callable-var = $/<index>.made;
            %callable-var«type» = 'callable-var';
            %callable-var«sigil» = '&';
        } elsif $/<twigil> {
            %callable-var = type => 'callable-var', sigil => '&', twigil => $/<twigil>.made, name => $/<identifier>.made;
        } else {
            %callable-var = type => 'callable-var', sigil => '&', twigil => '', name => $/<identifier>.made;
        }
        make %callable-var;
    }
    method var($made) {
        my %var;
        if $made<scalar-var> {
            %var = $made<scalar-var>.made;
        } elsif $made<array-var> {
            %var = $made<array-var>.made;
        } elsif $made<hash-var> {
            %var = $made<hash-var>.made;
        } elsif $made<callable-var> {
            %var = $made<callable-var>.made;
        } else {
            %var = type => 'Failed', sigil => 'Bad-var', twigil => '', name => 'Error bad value: ' ~ ~$made;
        }
        $made.make: %var;

    }
} # role VariablesBaseActions #

grammar Variables is VariablesBase is export {
    token TOP { <var> }
}

class VariablesActions does VariablesBaseActions is export {
    method TOP($made) {
        my %spec = $made<var>.made;
        my Str $top = t.color(255,0,0) ~ %spec«sigil»;
        if %spec«twigil» eq '<' {
            $top ~= t.color(0,255,255) ~ '<' ~ %spec«name» ~ '>';
        } elsif %spec«type» eq 'Failed' {
            $top ~= t.color(255,0,0) ~ %spec«name»;
        } else {
            $top ~= %spec«twigil» ~ t.color(0,255,255) ~ %spec«name»;
        }
        if %spec«derref»:exists && (%spec«derref»«derref-char»:exists) {
            if %spec«derref»«derref-char» eq '[' {
                $top ~= t.color(255,0,0) ~ '[' ~ t.color(255,0,255) ~ %spec«derref»«ind» ~ t.color(255,0,0) ~ ']';
            } elsif %spec«derref»«derref-char» eq '«' {
                $top ~= t.color(255,74,0) ~ '«' ~ %spec«derref»«ind» ~ '»';
            } elsif %spec«derref»«derref-char» eq '<' {
                $top ~= t.color(255,0,0) ~ '<' ~ t.color(255,0,255) ~ %spec«derref»«ind» ~ t.color(255,0,0) ~ '>';
            } elsif %spec«derref»«derref-char» eq '{' {
                $top ~= t.color(255,0,0) ~ '{$' ~ t.color(255,0,255) ~ %spec«derref»«ind» ~ t.color(255,0,0) ~ '}';
            } elsif %spec«derref»«derref-char» eq '(' {
                $top ~= t.color(255,0,0) ~ '(' ~ t.color(255,0,255) ~ %spec«derref»«ind» ~ t.color(255,0,0) ~ ')';
            }
        }
        $made.make: $top;
    }
}


grammar ValueBase {
    token value       { <space> [ <array-val> || <hash-val> || <scalar-val> ] <space-after=.space> }
    token array-val   { '[' [ <space> [ <value> ]+ %% ',' ]? <space-after=.space> ']' }
    token hash-val    { '{' [ <space> [ <pair> ]+ %% ',' ]? <space-after=.space> '}' }
    token space       { \h* }
    token pair        { [ <pair0> || <pair1> ] }
    token pair0       { <key> \h+ '=>' \h+ <value> }
    token pair1       { ':' <key> '(' <value> ')' }
    token key         { \w+ [ '-' \w+ ]* }
    token scalar-val  { [ <int-val> || <rat-val> || <num-val> || <bool-val> || <bare-word> || <string> ] }
    token int-val     { \d+ }
    token rat-val     { <numerator> '/' <denominator> }
    token numerator   { \d+ }
    token denominator { \d+ }
    token num-val     { [ <mantisa> <exponent>? || <integer> <exponent> ] }
    token mantisa     { [ '.' \d+ || \d+ '.' \d* ] }
    token exponent    { <signifitant> <sign>? <integer> }
    token signifitant { [ 'e' || 'E' ] }
    token integer     { \d+ }
    token sign        { [ '+' || '-' ] }
    token bool-val    { [ 'True' || 'False' ] }
    token bare-word   { '/'? \w+ [ [ '-' || '/' ] \w+ ]* '/'? }
    # lots of string stuff missing here  like q and qq strings etc ... #
    token string      { [ '"' <string-body> '"' || "'" <single-body> "'" ] }
    token string-body { [ <-["]>* [ <?after '\\' > '"' <-["]>* ]* ]? }
    token single-body { [ <-[']>* [ <?after '\\' > "'" <-[']>* ]* ]? }
}

role ValueBaseActions {
    method space-after($/) {
        my %space-after = $/<space>.made;
        make %space-after;
    }
    method space($/) {
        my %space = type => 'space', val => ~$/;
        make %space;
    }
    method key($/) {
        my $key = ~$/;
        make $key;
    }
    method int-val($/) {
        my Int %int-val = type => 'int', val => +$/;
        make %int-val;
    }
    method numerator($/) {
        my Int $numerator = +$/;
        make $numerator;
    }
    method denominator($/) {
        my Int $denominator = +$/;
        make $denominator;
    }
    method integer($/) {
        my Int $integer = +$/;
        make $integer;
    }
    method rat-val($/) {
        my %rat-val = type => 'rat-val', numerator => $/<numerator>.made, denominator => $/<denominator>.made;
        make %rat-val;
    }
    method mantisa($/) {
        my Num $mantisa = +$/;
        make $mantisa;
    }
    method sign($/) {
        my Str $sign = ~$/;
        make $sign;
    }
    method signifitant($/) {
        my Str $signifitant = ~$/;
        make $signifitant;
    }
    method exponent($/) {
        my %exponent = signifitant => $/<signifitant>.made, sign => '', exp => $/<integer>.made;
        if $/<sign> {
            %exponent«sign» = $/<sign>.made;
        }
        make %exponent;
    }
    method num-val($/) {
        my %num-val;
        my %exp;
        if $/<exponent> {
            %exp = $/<exponent>.made;
        }
        if $/<mantisa> {
            %num-val = type => 'num', mantisa => $/<mantisa>.made, exponent => %exp;
        } elsif $/<integer> {
            %num-val = type => 'num', mantisa => $/<integer>.made, exponent => %exp;
        }
        make %num-val;
    }
    method bool-val($/) {
        my %bool-val = type => 'bool', val => ~$/;
        make %bool-val;
    }
    method bare-word($/) {
        my %bare-word = type => 'bare-word', val => ~$/;
        make %bare-word;
    }
    method string-body($/) {
        my Str $string-body = ~$/;
        make $string-body;
    }
    method single-body($/) {
        my Str $single-body = ~$/;
        make $single-body;
    }
    method string($/) {
        my %string;
        if $/<string-body> {
            %string = type => 'string', open => '"', close => '"', val => $/<string-body>.made;
        } elsif $/<single-body> {
            %string = type => 'string', open => "'", close => "'", val => $/<single-body>.made;
        }
        make %string;
    }
    #token scalar-val  { [ <int-val> || <rat-val> || <num-val> || <bare-word> || <string> ] }
    method scalar-val($/) {
        my %scalar-val;
        if $/<int-val> {
            %scalar-val = $/<int-val>.made;
        } elsif $/<rat-val> {
            %scalar-val = $/<rat-val>.made;
        } elsif $/<num-val> {
            %scalar-val = $/<num-val>.made;
        } elsif $/<bool-val> {
            %scalar-val = $/<bool-val>.made;
        } elsif $/<bare-word> {
            %scalar-val = $/<bare-word>.made;
        } elsif $/<string> {
            %scalar-val = $/<string>.made;
        }
        make %scalar-val;
    }
    #token array-val   { '[' [ [ \h+ <value> ]+ %% ',' ]? ']' }
    method array-val($/) {
        my %array-val = type => 'array-val', val => $/<value>».made, a-space => $/<space>.made, a-space-after => $/<space-after>.made;
        make %array-val;
    }
    #token pair0       { <key> \h+ '=>' \h+ <value> }
    method pair0($/) {
        my %pair0 = type => 'pair0', key => $/<key>.made, val => $/<value>.made;
        make %pair0;
    }
    #token pair1       { ':' <key> '(' <value> ')' }
    method pair1($/) {
        my %pair1 = type => 'pair1', key => $/<key>.made, val => $/<value>.made;
        make %pair1;
    }
    #token pair        { [ <pair0> || <pair1> ] }
    method pair($/) {
        my %pair;
        if $/<pair0> {
            %pair = $/<pair0>.made;
        } elsif $/<pair1> {
            %pair = $/<pair1>.made;
        }
        make %pair;
    }
    #token hash-val    { '{' [ [ \h+ <pair> ]+ %% ',' ]? '}' }
    method hash-val($/) {
        my %hash-val = type => 'hash-val', val => $/<pair>».made, h-space => $/<space>.made, h-space-after => $/<space-after>.made;
        make %hash-val;
    }
    #token value       { [ <array-val> || <hash-val> || <scalar-val> ] }
    method value($/) {
        my %value;
        if $/<array-val> {
            %value = |$/<array-val>.made, space => $/<space>.made, space-after => $/<space-after>.made;
        } elsif $/<hash-val> {
            %value = $/<hash-val>.made, space => $/<space>.made, space-after => $/<space-after>.made;
        } elsif $/<scalar-val> {
            %value = |$/<scalar-val>.made, space => $/<space>.made, space-after => $/<space-after>.made;
        }
        make %value;
    }
} # role ValueBaseActions does KeyActions #

grammar Value is ValueBase is export {
    token TOP            { ^ <value> $ }
}

class ValueActions does ValueBaseActions is export {
    method !highlight(%spec) {
        my $highlight = '';
        $highlight ~= %spec«space»«val» if %spec«space»;
        if %spec«type» eq 'int' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«val»;
        } elsif %spec«type» eq 'rat-val' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«numerator» ~ '/' ~ %spec«denominator»;
        } elsif %spec«type» eq 'num' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«mantisa»;
            $highlight ~= %spec«exponent»«signifitant» ~ %spec«exponent»«sign» ~ %spec«exponent»«exp» if %spec«exponent»;
        } elsif %spec«type» eq 'bool' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«val»;
        } elsif %spec«type» eq 'bare-word' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«val»;
        } elsif %spec«type» eq 'string' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«open» ~ %spec«val» ~ %spec«close»;
        } elsif %spec«type» eq 'array-val' {
            $highlight ~= t.color(255, 0, 0) ~  '[';
            $highlight ~= %spec«a-space»«val» if %spec«a-space»;
            my Str:D $sep = '';
            my @vals = |%spec«val»;
            for @vals -> %val {
                $highlight ~= t.color(255, 0, 0) ~ $sep ~ self!highlight(%val);
                $sep = ',';
            }
            $highlight ~= %spec«a-space-after»«val» if %spec«a-space-after»;
            $highlight ~= t.color(255, 0, 0) ~ ']';
        } elsif %spec«type» eq 'hash-val' {
            $highlight ~= t.color(255, 0, 0) ~  '{';
            $highlight ~= %spec«h-space»«val» if %spec«h-space»;
            my Str:D $sep = '';
            my @vals = |%spec«val»;
            for @vals -> %val {
                $highlight ~= t.color(255, 0, 0) ~ $sep ~ self!highlight(%val);
                $sep = ',';
            }
            $highlight ~= %spec«h-space-after»«val» if %spec«h-space-after»;
            $highlight ~= t.color(255, 0, 0) ~ '}';
        } elsif %spec«type» eq 'pair0' {
            $highlight ~= t.color(255, 0, 255) ~ %spec«key» ~ t.color(255, 0, 0) ~ ' => ' ~ self!highlight(%spec«val»);
        } elsif %spec«type» eq 'pair1' {
            $highlight ~= t.color(255, 0, 0) ~ ':' ~ t.color(255, 0, 255) ~ %spec«key» ~ t.color(255, 0, 0) ~ '(' ~ self!highlight(%spec«val») ~ t.color(255, 0, 0) ~ ')';
        }
        $highlight ~= %spec«space-after»«val» if %spec«space-after»;
        return $highlight;
    }
    method TOP($made) {
        my %spec = $made<value>.made;
        my Str $top = self!highlight(%spec);
        $made.make: $top;
    }
} # class ValueActions does ValueBaseActions #

sub highlight-var(Str:D $var --> Str:D) is export {
    my $actions = VariablesActions;
    my $tmp = Variables.parse($var, :enc('UTF-8'), :$actions).made;;
    HighlighterFailed.new(:msg("Error: Variables.parse Failed.")).throw if $tmp === Any;
    return $tmp;
} # sub highlight-var(Str:D --> Str:D) is export #

sub highlight-val(Str:D $val --> Str:D) is export {
    my $actions = ValueActions;
    my $tmp = Value.parse($val, :enc('UTF-8'), :$actions).made;;
    HighlighterFailed.new(:msg("Error: Variables.parse Failed.")).throw if $tmp === Any;
    return $tmp;
} # sub highlight-val(Str:D --> Str:D) is export #
