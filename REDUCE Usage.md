---
layout: default
title: "REDUCE Usage"
description: ABAP development notes and examples for REDUCE Usage
---

# ABAP REDUCE — Usage

REDUCE folds a collection to a single value.

## Examples
```abap
DATA sum = REDUCE i( INIT s = 0 FOR x IN lt ADD s = s + x ).

" Concatenate with separator
DATA joined TYPE string.
joined = REDUCE string( INIT acc = `` sep = ``
                        FOR r IN lt_texts
                        NEXT acc = |{ acc }{ sep }{ r }| sep = `, ` ).

" Count by condition
DATA cnt = REDUCE i( INIT c = 0 FOR r IN lt WHERE ( type = 'E' ) NEXT c = c + 1 ).
```

## Boilerplate
```abap
result = REDUCE type( INIT acc = init FOR line IN itab NEXT acc = f( acc = acc line = line ) ).
```
