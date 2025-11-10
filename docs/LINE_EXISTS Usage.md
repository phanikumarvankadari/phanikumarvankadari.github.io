---
layout: default
title: LINE_EXISTS Usage
description: ABAP development notes and examples for LINE_EXISTS Usage
---

# ABAP line_exists — Usage

line_exists( itab[ ... ] ) checks if a row exists for a table expression without raising an exception.

## Examples
```abap
IF line_exists( lt_rows[ id = 10 ] ).
  lt_rows[ id = 10 ]-name = 'Found';
ENDIF.

" Index variant for index tables
IF line_exists( lt_rows[ 1 ] ).
  DATA(first_city) = lt_rows[ 1 ]-city.
ENDIF.

" Combine with ELSE for insert/append logic
IF line_exists( lt_rows[ id = new_id ] ).
  lt_rows[ id = new_id ]-name = new_name.
ELSE.
  INSERT VALUE #( id = new_id name = new_name ) INTO TABLE lt_rows.
ENDIF.
```
