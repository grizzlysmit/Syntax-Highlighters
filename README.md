Table of Contents
-----------------

    * [Introduction](#introduction)

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

