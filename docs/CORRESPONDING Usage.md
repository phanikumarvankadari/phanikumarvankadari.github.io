# ABAP CORRESPONDING — Usage

CORRESPONDING maps fields by name between structures/tables.

## Examples
```abap
" Structure → structure with mapping
TYPES: BEGIN OF ty_a, a TYPE i, b TYPE string, END OF ty_a.
TYPES: BEGIN OF ty_b, x TYPE i, b TYPE string, END OF ty_b.
DATA s_a TYPE ty_a VALUE #( a = 1 b = 'X' ).
DATA s_b TYPE ty_b.
s_b = CORRESPONDING ty_b( s_a MAPPING x = a ).

" Table → table with EXCEPT
DATA lt_b TYPE STANDARD TABLE OF ty_b WITH EMPTY KEY.
lt_b = CORRESPONDING #( lt_a MAPPING x = a EXCEPT b ).
```

## Boilerplate
```abap
result = CORRESPONDING type( source MAPPING t1 = s1 t2 = s2 EXCEPT f3 f4 ).
```
