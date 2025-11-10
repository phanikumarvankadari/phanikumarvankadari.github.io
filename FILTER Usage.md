# ABAP FILTER — Usage

FILTER keeps rows matching a condition (or removes them with EXCEPT).

## Examples
```abap
" Keep only errors
DATA lt_err TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
lt_err = FILTER #( lt_ret USING KEY type WHERE type = 'E' ).

" Remove warnings
DATA lt_no_warn TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
lt_no_warn = FILTER #( lt_ret EXCEPT WHERE type = 'W' ).

" On keyed table with named secondary key
" DATA lt_tab TYPE SORTED TABLE OF ty_row WITH UNIQUE KEY id.
" lt_sel = FILTER #( lt_tab USING KEY id WHERE id > 100 ).
```

## Boilerplate
```abap
sel = FILTER type( src USING KEY keyname WHERE cond ).
sel = FILTER type( src EXCEPT WHERE cond ).
```
