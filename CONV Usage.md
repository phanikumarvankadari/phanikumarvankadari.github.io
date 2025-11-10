---
layout: default
title: "CONV Usage"
description: ABAP development notes and examples for CONV Usage
---

# ABAP CONV — Usage

CONV converts expressions to a target type inline.

## Examples
```abap
DATA txt TYPE string.
txt = CONV string( sy-datum ).

DATA n TYPE i.
n = CONV i( '123' ).

DATA numc5 TYPE numc5.
numc5 = CONV numc5( 42 ). " '00042'
```

## Boilerplate
```abap
var = CONV type( expr ).
```
