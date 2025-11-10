---
layout: default
title: SWITCH Usage
description: ABAP development notes and examples for SWITCH Usage
---

# ABAP SWITCH — Usage

SWITCH selects a value based on cases (like CASE as expression).

## Examples
```abap
DATA(code) = 'A'.
DATA(text) = SWITCH string( code
                 WHEN 'A' THEN 'Active'
                 WHEN 'I' THEN 'Inactive'
                 ELSE 'Unknown' ).

" With expressions on right side
DATA(n) = 2.
DATA(msg) = SWITCH string( n WHEN 1 THEN |One|
                              WHEN 2 THEN |Two|
                              ELSE |N={ n }| ).
```

## Boilerplate
```abap
result = SWITCH type( key WHEN k1 THEN v1 WHEN k2 THEN v2 ELSE v_default ).
```
