# ABAP Table Expressions — Usage

Table expressions access a specific row inline: `itab[ ... ]`. They are concise and can be used in expressions.

Notes
- Not found raises `CX_SY_ITAB_LINE_NOT_FOUND` (guard with `line_exists` or TRY/CATCH).
- Index access works only on index tables (standard/sorted). Use key access for hashed.
- You may read fields or assign to fields of the found row.

## Examples
```abap
" By primary/named key (unique)
DATA(ls) = lt_rows[ id = 10 ].

" With named key
DATA(ls2) = lt_rows[ KEY id id = 10 ].

" By index (standard/sorted only)
DATA(name1) = lt_rows[ 1 ]-name.

" Inline update of a field
lt_rows[ id = 10 ]-name = 'Updated'.

" Guard with TRY for not found
TRY.
    DATA(city) = lt_rows[ id = 9999 ]-city.
  CATCH cx_sy_itab_line_not_found.
    city = 'N/A'.
ENDTRY.
```
