---
layout: default
title: "CAST Usage"
description: ABAP development notes and examples for CAST Usage
---

# ABAP CAST — Usage

CAST changes a reference’s static type within inheritance/interface hierarchies.

## Examples
```abap
" Downcast with check
IF lo_super IS INSTANCE OF zcl_sub.
  DATA(lo_sub) = CAST zcl_sub( lo_super ).
ENDIF.

" Try/catch variant
TRY.
    DATA(lo_sub2) ?= lo_super.
  CATCH cx_sy_move_cast_error.
ENDTRY.
```

## Boilerplate
```abap
ref_sub = CAST sub_type( ref_super ).
```
