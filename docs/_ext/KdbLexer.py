# -*- coding: utf-8 -*-
"""
    pygments.lexers.q
    -------------------

    Pygment lexer for q

    :copyright: Copyright (C) 2014 Jaskirat M.S. Rajasansir
    :version: 0.4
    :license: BSD, see LICENSE for details
"""

import re

from pygments.lexer import RegexLexer, include, bygroups, using, this
from pygments.token import *

__all__ = [ 'KdbLexer' ]

class KdbLexer(RegexLexer):
    name = 'q'
    aliases = [ 'q', 'k', 'kdb' ]
    filenames = [ '*.q', '*.k' ]

    tokens = {
        'comments': [
            (r'^/$', Comment.Multiline, 'multilineComment'),
            (r'(^\s*?)(/.*\n)', bygroups(Whitespace, Comment.Single))
        ],

        'multilineComment': [
            (r'^\\$', Comment.Multiline, '#pop'),
            (r'.*\n', Comment.Multiline)
        ],

        'punctuation': [
            (r'(\n\s*?|\t| )', Whitespace),
            (r'[{(\[;,]', Punctuation),
            (r'[})\]]', Punctuation)
        ],

        # Parses all types except number types
        'types': [
            (r'(`(?:boolean|guid|byte|short|int|long|real|float|char|symbol|timestamp|month|date|datetime|timespan|minute|second|time))(\$)', bygroups(Keyword.Type, Operator)),
                                                                                                        # ^ Casts
            (r'\"(B|G|X|H|I|J|E|F|C|S|P|M|D|Z|N|U|V|T)\"', Keyword.Type),                               # Casts (from string)
            (r'0[Nn](g|h|e|p|m|d|z|n|u|v|t)', Keyword.Constant),                                        # Null constants

            (r'"(\\\\|\\"|[^"])*"', String),                                                            # Char / String
            (r'`[a-zA-z0-9_\.]*', String.Symbol),                                                         # Symbol

            (r'[0-9]{4}\.[0-9]{2}\.[0-9]{2}D[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{9}', Literal.Date),       # Timestamp
            (r'[0-9]{4}\.[0-9]{2}\.[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}', Literal.Date),       # Datetime
            (r'[0-9]{2}:[0-9]{2}(:[0-9]{2}\.[0-9]*)?', Literal.Date),                                   # Time / Timespan
            (r'[0-9]{2}:[0-9]{2}(:[0-9]{2})?', Literal.Date),                                           # Minute / Second
            (r'[0-9]{4}\.[0-9]{2}\.[0-9]{2}', Literal.Date),                                            # Date
            (r'[0-9]{4}\.[0-9]{2}m', Literal.Date),                                                     # Month

            (r'[0-9]{8}-[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{12}', Literal),                                # GUID
        ],

        # Number types are split out due to parsing rules, don't want to parse a number within a variable name
        'numTypes': [
            (r'0x[0-9a-fA-F]+', Number.Hex),                                                            # Byte
            (r'[0-9]+(\.[0-9]+)?[fe]', Number.Float),                                                   # Float / Real
            (r'[01]+b', Number),                                                                         # Boolean
            (r'[0-9]+(h|i|j)?', Number.Integer)                                                         # Short / Integer / Long
        ],

        # All built-in variables and functions
        'functions': [
            (r'(`)?\.z\.(a|ac|b|bm|c|d|D|exit|f|h|i|k|K|l|n|N|o|p|P|pc|pg|pd|ph|pi|po|pp|ps|pw|q|s|t|T|ts|u|vs|w|W|ws|x|z|Z|zd)\b', Name.Builtin),
            (r'(`)?\.Q\.(k|host|addr|gc|w|res|addmonths|Cf|f|fmt|ff|fl|opt|def|qt|v|qp|V|ft|ord|tx|tt|fk|t|ty|nct|fu|fc|A|a|n|nA|an|b6|id|j10|x10|j12|x12|l|vt|bv|dd|d0|p1|p2|p|view|L|cn|pcnt|dt|ind|fp|foo|a1|a0|a2|qb|qd|xy|IN|qa|x1|x0|x2|ua|q0|qe|ps|en|par|qm|dpt|dpft|hdpf|fsn|fs|dsftg|M|chk|sw|tab|t0|s1|s2|S|s)\b', Name.Builtin),
            (r'(`)?\.h\.(htc|hta|htac|ha|hb|pre|xmp|cd|td|hc|xs|xd|ex|iso8601|eb|es|ed|edsn|ec|tx|xt|c0|c1|logo|sa|html|sb|fram|jx|uh|sc|hug|hu|ty|hn|HOME|hy|hp|he|br|hr|nbr|code|http|text|data|ht)\b', Name.Builtin),
            (r'(`)?\.o\.(ex|T|T0|B0|C0|PS|t|Columns|TI|TypeInfo|Special|o|Tables|Ts|Stats|Cols|Key|FG|Fkey|Gkey)\b', Name.Builtin),
            (r'\b(neg|not|null|string|reciprocal|floor|ceiling|signum|mod|xbar|xlog|and|or|each|scan|over|prior|mmu|lsq|inv|md5|ltime|gtime|count|first|var|dev|med|cov|cor|all|any|rand|sums|prds|mins|maxs|fills|deltas|ratios|avgs|differ|prev|next|rank|reverse|iasc|idesc|asc|desc|msum|mcount|mavg|mdev|xrank|mmin|mmax|xprev|rotate|distinct|group|where|flip|type|key|til|get|value|attr|cut|set|upsert|raze|union|inter|except|cross|sv|vs|sublist|enlist|read0|read1|hopen|hclose|hdel|hsym|hcount|peach|system|ltrim|rtrim|trim|lower|upper|ssr|view|tables|views|cols|xcols|keys|xkey|xcol|xasc|xdesc|fkeys|meta|uj|lj|ij|pj|aj|aj0|asof|wj|wj1|fby|xgroup|ungroup|ej|plist|txf|save|load|rsave|rload|show|csv|parse|eval|abs|acos|asin|atan|avg|bin|by|cos|delete|div|do|exec|exit|exp|from|getenv|if|in|insert|last|like|log|max|min|prd|select|setenv|sin|sqrt|ss|sum|tan|update|wavg|while|within|wsum|xexp)\b', Operator.Word)
        ],

        # Character operators
        'operators': [
            (r'[-<>+*%&\|\^/$:=@~\'\\!#_?!]', Operator)
        ],

        # Function and variable assigments
        'syntax': [
            (r'([a-zA-Z\.][a-zA-Z0-9\.]*)(:{)', bygroups(Name.Function, Operator)),
            (r'(\.?[a-zA-Z_][a-zA-Z0-9_]*)((?:,:|::|@:|_:|:))', bygroups(Name.Label, Operator))
        ],


        # Main parser. NOTE: As this is state machine parser, the order of the parsing is important
        'root': [
            include('comments'),
            include('syntax'),
            include('types'),
            include('operators'),
            include('punctuation'),
            include('functions'),

            (r'[a-zA-Z_.][a-zA-Z0-9_\.]*', Name.Other),

            include('numTypes'),

        ]
    }

