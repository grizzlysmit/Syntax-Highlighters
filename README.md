Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [HighlighterFailed](#highlighterfailed)

  * [VariablesBase](#variablesbase)

  * [VariablesBaseActions](#variablesbaseactions)

  * [Variables and VariablesActions](#variables-and-variablesactions)

  * [ValueBase and ValueBaseActions](#valuebase-and-valuebaseactions)

  * [Value and ValueActions](#value-and-valueactions)

  * [highlight-var](#highlight-var)

  * [highlight-val](#highlight-val)

NAME
====

Syntax::Highlighters 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.2

TITLE
=====

Syntax::Highlighters

SUBTITLE
========

A Raku module to do basic syntax highlighting.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Syntax-Highlighters/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

Some syntax highlighting stuff: grammars to parse basic **Raku** forms and highlight them with colours. And functions to use them.

**NB: by no means complete or exhaustive (as yet at least), and no way to parse expressions etc**.

[Top of Document](#table-of-contents)

HighlighterFailed
=================

An Exception class for reporting errors in parsing.

```raku
class HighlighterFailed is Exception is export {
    has Str:D $.msg = 'Error: Highlighter Failed.';
    method message( --> Str:D) {
        $!msg;
    }
}
```

[Top of Document](#table-of-contents)

VariablesBase
-------------

A grammar for parsing variable forms forms the basis of **Variables** which syntax highlights variable forms.

VariablesBaseActions
--------------------

A role to assist in the parsing variable forms forms the basis of **VariablesActions** which syntax highlights variable forms.

[Top of Document](#table-of-contents)

Variables and VariablesActions
------------------------------

The grammar and class pair that do the actual syntax highlighting of the variable forms.

**NB: Uses VariablesBase and VariablesBaseActions to do the actual parsing**.

```raku
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
```

[Top of Document](#table-of-contents)

ValueBase and ValueBaseActions
------------------------------

ValueBase and ValueBaseActions are a grammar role pair that implement parsing of **Raku** style values.

**NB: not comprehensive nor complete (yet at least)**. 

Value and ValueActions
----------------------

Value and ValueActions are a grammar class pair that implements syntax highlighting of **Raku** style values, using ValueBase and ValueBaseActions, as the parsing work horse.

```raku
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
            $highlight ~= t.color(255, 0, 0) ~ ':' ~ t.color(255, 0, 255)
                                               ~ %spec«key» ~ t.color(255, 0, 0) ~ '(' ~ self!highlight(%spec«val»)
                                                                                                ~ t.color(255, 0, 0) ~ ')';
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
```

[Top of Document](#table-of-contents)

highlight-var
-------------

wraps up the actual usage of the grammars above.

Defined as:

```raku
sub highlight-var($var --> Str:D) is export {
    my $actions = VariablesActions;
    my $tmp = Variables.parse($var, :enc('UTF-8'), :$actions).made;;
    HighlighterFailed.new(:msg("Error: Variables.parse Failed.")).throw if $tmp === Any;
    return $tmp;
} # sub highlight-var($var --> Str:D) is export #
```

highlight-val
-------------

```raku
sub highlight-val($val --> Str:D) is export {
    my $actions = ValueActions;
    my $tmp = Value.parse($val, :enc('UTF-8'), :$actions).made;;
    HighlighterFailed.new(:msg("Error: Variables.parse Failed.")).throw if $tmp === Any;
    return $tmp;
} # sub highlight-val($val --> Str:D) is export #
```

[Top of Document](#table-of-contents)

