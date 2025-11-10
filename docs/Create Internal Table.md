---
layout: default
title: Create Internal Table
description: ABAP development notes and examples for Create Internal Table
---

#abap #sap-learning #cookbook
# Create Internal Table

Quick patterns to define and populate internal tables.

## Typed Standard Table
```abap
TYPES: BEGIN OF ty_s_flight,
         carrid TYPE s_carr_id,
         connid TYPE s_conn_id,
         price  TYPE s_price,
       END OF ty_s_flight,
       ty_t_flight TYPE STANDARD TABLE OF ty_s_flight WITH EMPTY KEY.

DATA lt_flights TYPE ty_t_flight.

lt_flights = VALUE #( ( carrid = 'LH' connid = '0400' price = '100.00' )
                      ( carrid = 'AA' connid = '0017' price = '120.00' ) ).
```

## Inline Types and Table Comprehensions
```abap
DATA lt_nums TYPE TABLE OF i WITH EMPTY KEY.
lt_nums = VALUE #( FOR i = 1 UNTIL i > 5 ( i ) ).
```

## Sorted/Hashed Tables
```abap
TYPES: ty_t_sorted TYPE SORTED TABLE OF ty_s_flight WITH UNIQUE KEY carrid connid,
       ty_t_hashed TYPE HASHED  TABLE OF ty_s_flight WITH UNIQUE KEY carrid connid.
```

## Field Symbols and Assigning
```abap
FIELD-SYMBOLS <fs> TYPE ty_s_flight.
LOOP AT lt_flights ASSIGNING <fs>.
  <fs>-price = <fs>-price * '1.10'.
ENDLOOP.
```
