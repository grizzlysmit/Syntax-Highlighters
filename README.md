Table of Contents
-----------------

  * [Introduction](#introduction)

  * [HighlighterFailed](#highlighterfailed)

  * [VariablesBase](#variablesbase)

  * [VariablesBaseActions](#variablesbaseactions)

  * [Variables and VariablesActions](#variables-and-variablesactions)

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

0.1.0

TITLE
=====

Gzz::Text::Utils

SUBTITLE
========

A Raku module to one basic syntax highlighting.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Syntax-Highlighters/blob/main/LICENSE)

Introduction
============

Some syntax highlighting stuff: grammars to parse basic **Raku** forms and highlight them with colours. And functions to use them.

[Table of Contents](#table-of-contents)

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

VariablesBase
-------------

A grammar for parsing variable forms forms the basis of **Variables** which syntax highlights variable forms.

VariablesBaseActions
--------------------

A role to assist in the parsing variable forms forms the basis of **VariablesActions** which syntax highlights variable forms.

Variables and VariablesActions
------------------------------

The grammar and class pair that do the actual syntax highlighting of the variable forms.

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

