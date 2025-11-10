---
layout: default
title: NEW Usage
description: ABAP development notes and examples for NEW Usage
---

# ABAP NEW — Usage

NEW creates objects or data with constructors as an expression.

## Examples
```abap
" Object creation with constructor params
DATA(lo) = NEW zcl_service( iv_id = 1 iv_name = 'X' ).

" Data object (anonymous structure/table)
DATA lr_i TYPE REF TO i. lr_i = NEW i( 42 ).

" Inline in method call
zcl_log=>write( NEW zcl_message( iv_text = 'Hello' ) ).
```

## Boilerplate
```abap
DATA(lo_obj) = NEW class( ... ).
DATA(lo_ref) = NEW type( ).
```
