# Internal Table Handling (ABAP)

## Looping Techniques

Work area (copy semantics)
```abap
LOOP AT lt_rows INTO DATA(ls_row).
  " read-only or small updates (copy back with MODIFY)
  WRITE: / ls_row-id, ls_row-name.
ENDLOOP.
```

Reference (no copy; stable even if table changes)
```abap
LOOP AT lt_rows REFERENCE INTO DATA(lr_row).
  " access via ->
  IF lr_row->id = 100.
    lr_row->name = |Found { lr_row->name }|.
  ENDIF.
ENDLOOP.
```

Field-symbol (fast; direct access to line)
```abap
LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_row>).
  <ls_row>-name = to_upper( <ls_row>-name ).
ENDLOOP.
```

## Choosing Table Types
- Standard table: general-purpose; appends fast; linear search O(n). Use with small/medium sets or when order matters. Enable `BINARY SEARCH` only on pre-sorted standard tables.
- Sorted table: always kept sorted by primary key; unique/non-unique keys; read/insert O(log n). Use when you frequently read by key and need order.
- Hashed table: hashed by unique primary key; read/insert O(1); no index, no order. Use for large key-based lookups and deduplication.

## Type Definitions (with and without keys)
```abap
TYPES: BEGIN OF ty_row,
         id   TYPE i,
         name TYPE string,
         city TYPE string,
       END OF ty_row.

" Without primary key (standard)
TYPES ty_std_nokey TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

" With non-unique primary key (standard)
TYPES ty_std_key   TYPE STANDARD TABLE OF ty_row WITH NON-UNIQUE KEY id.

" Sorted by unique key
TYPES ty_sorted    TYPE SORTED  TABLE OF ty_row WITH UNIQUE KEY id.

" Hashed by unique key
TYPES ty_hashed    TYPE HASHED  TABLE OF ty_row WITH UNIQUE KEY id.
```

## Boilerplates by Table Kind

Standard table (reads, binary search, modify)
```abap
DATA lt_std TYPE ty_std_key.
lt_std = VALUE #( ( id = 1 name = 'A' ) ( id = 2 name = 'B' ) ).
READ TABLE lt_std INTO DATA(ls1) WITH KEY id = 2.
SORT lt_std BY id.
READ TABLE lt_std INTO DATA(ls2) WITH KEY id = 2 BINARY SEARCH.
MODIFY lt_std FROM VALUE ty_row( id = 2 name = 'B2' ) INDEX sy-tabix.
```

Sorted table (log n reads/inserts)
```abap
DATA lt_sorted TYPE ty_sorted.
INSERT VALUE #( id = 10 name = 'X' ) INTO TABLE lt_sorted.
READ TABLE lt_sorted INTO DATA(ls3) WITH TABLE KEY id = 10.
MODIFY TABLE lt_sorted FROM VALUE ty_row( id = 10 name = 'X2' ).
```

Hashed table (O(1) lookup)
```abap
DATA lt_hash TYPE ty_hashed.
INSERT VALUE #( id = 100 name = 'H' ) INTO TABLE lt_hash.
READ TABLE lt_hash INTO DATA(ls4) WITH TABLE KEY id = 100.
MODIFY TABLE lt_hash FROM VALUE ty_row( id = 100 name = 'H2' ).
```

## Looping Boilerplates with Types
```abap
DATA lt_rows TYPE ty_std_nokey.
lt_rows = VALUE #( ( id = 1 name = 'a' ) ( id = 2 name = 'b' ) ).

" Work area
LOOP AT lt_rows INTO DATA(ls).
  WRITE / ls-name.
ENDLOOP.

" Reference
LOOP AT lt_rows REFERENCE INTO DATA(lr).
  lr->name = to_upper( lr->name ).
ENDLOOP.

" Field-symbol
LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls>).
  <ls>-city = 'Helsinki'.
ENDLOOP.
```

Notes
- Prefer ASSIGNING or REFERENCE INTO for in-place updates.
- Use hashed/sorted tables to avoid explicit `SORT ... BINARY SEARCH` logic.
- Define clear primary keys; prefer `WITH EMPTY KEY` only for small, order-driven lists.
