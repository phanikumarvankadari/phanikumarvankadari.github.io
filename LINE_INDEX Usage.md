# ABAP line_index — Usage

line_index( itab[ ... ] ) returns the index of a row for index tables; 0 if not found. Useful to combine with `READ TABLE ... INDEX` or `DELETE ... INDEX`.

Notes
- Works on standard/sorted tables (index tables). Not meaningful for hashed.

## Examples
```abap
DATA(idx) = line_index( lt_rows[ id = 10 ] ).
IF idx > 0.
  READ TABLE lt_rows INDEX idx ASSIGNING FIELD-SYMBOL(<row>).
  <row>-name = 'Updated'.
ENDIF.

" Safe delete by index
idx = line_index( lt_rows[ id = 999 ] ).
IF idx > 0.
  DELETE lt_rows INDEX idx.
ENDIF.
```
