---
layout: default
title: COND Usage
description: ABAP development notes and examples for COND Usage
---

# ABAP COND — Usage

COND is IF/ELSE as an expression that yields a value.

## Examples
```abap
DATA(score) = 88.
DATA(grade) = COND string( WHEN score >= 90 THEN 'A'
                           WHEN score >= 80 THEN 'B'
                           ELSE 'C' ).

" Boolean as abap_bool
DATA(ok) TYPE abap_bool.
ok = COND abap_bool( WHEN lines( lt ) > 0 THEN abap_true ELSE abap_false ).

" With LET for temps
DATA(txt) = COND string( LET n = lines( lt ) IN
                         WHEN n = 0 THEN 'Empty'
                         WHEN n < 10 THEN |Small ({ n })|
                         ELSE |Many ({ n })| ).
```

## Boilerplate
```abap
result = COND type( WHEN cond1 THEN v1 WHEN cond2 THEN v2 ELSE v_default ).
```
