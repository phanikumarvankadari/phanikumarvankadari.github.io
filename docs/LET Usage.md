---
layout: default
title: LET Usage
description: ABAP development notes and examples for LET Usage
---

# ABAP LET — Usage

LET defines temporary variables inside expression contexts (COND/SWITCH/REDUCE).

## Examples
```abap
DATA(txt) = COND string( LET n = lines( lt ) IN
                         WHEN n = 0 THEN 'Empty'
                         ELSE |Count: { n }| ).

DATA sum = REDUCE i( LET lim = 100 IN
                     INIT s = 0 FOR x IN lt WHERE ( x < lim ) NEXT s = s + x ).
```

## Boilerplate
```abap
result = COND type( LET v = expr IN WHEN cond THEN val ELSE def ).
```
