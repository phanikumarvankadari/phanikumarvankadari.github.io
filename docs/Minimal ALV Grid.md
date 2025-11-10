---
layout: default
title: Minimal ALV Grid
description: ABAP development notes and examples for Minimal ALV Grid
---

#abap #sap-learning #cookbook #alv
# Minimal ALV Grid

Smallest SALV example to display an internal table.

```abap
DATA lt_scarr TYPE TABLE OF scarr WITH EMPTY KEY.
SELECT * FROM scarr INTO TABLE lt_scarr UP TO 50 ROWS.

DATA(lo_alv) = cl_salv_table=>factory( r_container = VALUE #( )
                                       t_table     = REF #( lt_scarr ) ).
lo_alv->display( ).
```
