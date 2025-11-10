---
layout: default
title: ABAP Formatting
description: ABAP development notes and examples for ABAP Formatting
---

# ABAP Formatting (String Templates)

String templates are the preferred way to build strings in modern ABAP.
They are cleaner than `&&` concatenation and support built‑in formatting.
Syntax: a template is delimited by `| ... |` and inserts values with `{ ... }`.

## Basics
```abap
DATA(name) = 'Demo'.
DATA(rv)   = |Hello { name }!|.               " -> "Hello Demo!"

" Equivalent concatenation (harder to read)
rv = 'Hello ' && name && '!'.
```

## Dates, Times, and Numbers
```abap
DATA(d) = sy-datum.   " e.g., 20251106
DATA(t) = sy-uzeit.   " e.g., 142355
DATA(n) = '12345.67'.

DATA(out1) = |Date ISO: { d DATE = ISO }|.      " 2025-11-06
DATA(out2) = |Time ISO: { t TIME = ISO }|.      " 14:23:55
DATA(out3) = |Number (USER): { n NUMBER = USER }|. " locale-aware
```

## Width, Alignment, Padding
```abap
DATA(val) = 42.
DATA(a) = |[{ val WIDTH = 6 ALIGN = RIGHT }] |.   " [    42]
DATA(b) = |[{ val WIDTH = 6 ALIGN = LEFT  }] |.   " [42    ]
DATA(c) = |[{ val WIDTH = 6 PAD = '0'     }] |.   " [000042]
```

## Function Calls and Expressions
```abap
DATA(first) = 'vincit'.
DATA(last)  = 'finland'.
DATA(full)  = |{ to_upper( first ) } { to_mixed( last ) }|.  " VINCIT Finland

" Conditional content
DATA(score) = 88.
DATA(txt) = |Result: { COND string( WHEN score >= 90 THEN 'A' ELSE 'OK' ) }|.
```

Tips
- Keep formatting in the template, not after it.
- Prefer templates over `WRITE`-style formatting for new code.
- If you need literals like `{` or `}`, build parts separately or escape via expressions.
