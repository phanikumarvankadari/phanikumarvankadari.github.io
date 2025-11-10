# ABAP VALUE — Usage

VALUE constructs and initializes structures/tables inline; `VALUE #(...)` infers type from context.

## Examples
```abap
" Structure
TYPES: BEGIN OF ty_s, id TYPE i, name TYPE string, END OF ty_s.
DATA s TYPE ty_s.
s = VALUE #( id = 1 name = 'Alice' ).

" Internal table
TYPES tt_s TYPE STANDARD TABLE OF ty_s WITH EMPTY KEY.
DATA lt TYPE tt_s.
lt = VALUE #( ( id = 1 name = 'A' ) ( id = 2 name = 'B' ) ).

" BASE: start from existing value
s = VALUE #( BASE s name = 'Updated' ).
lt = VALUE #( BASE lt ( id = 3 name = 'C' ) ).

" With FOR (comprehension)
lt = VALUE #( FOR i = 1 THEN i + 1 WHILE i <= 3 ( id = i name = |N{i}| ) ).
```

## Boilerplate
```abap
" Range table
DATA lr TYPE RANGE OF i.
lr = VALUE #( ( sign = 'I' option = 'BT' low = 1 high = 10 ) ).

" DTO mapping
DATA s2 TYPE ty_s.
s2 = VALUE ty_s( id = s-id name = s-name ).
```
