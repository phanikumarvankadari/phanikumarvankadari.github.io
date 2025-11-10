---
layout: default
title: EXACT Usage
description: ABAP development notes and examples for EXACT Usage
---

# ABAP EXACT — Usage

EXACT performs lossless/checked conversions; raises on overflow/precision loss.

## Examples
```abap
TRY.
    DATA(b) = EXACT int1( 300 ).
  CATCH cx_sy_conversion_error.
    b = 255.
ENDTRY.
```

## Boilerplate
```abap
DATA(out) = EXACT type( expr ).
```
