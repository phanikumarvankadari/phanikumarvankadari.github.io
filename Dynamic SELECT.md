---
layout: default
title: "Dynamic SELECT"
description: ABAP development notes and examples for Dynamic SELECT
---

#abap #sap-learning #cookbook
# Dynamic SELECT

End-to-end dynamic Open SQL for a custom table, including GUID and UTC timestamp filters. Prefer parameterized predicates and ranges; use dynamic strings only when needed and always escape values.

## 1) Custom Table (DDL)
```sql
define table zt_dyn_demo {
  key client     : abap.clnt    not null,
  key doc_guid   : abap.raw(16) not null,    // GUID X16
      created_at : abap.utclong,             // UTC timestamp
      created_by : abap.uname,
      status     : abap.char(1),             // e.g. 'N','P','C'
      amount     : abap.curr(15,2),
      currency   : abap.cuky(5),
      note       : abap.char(60)
}
```

## 2) Dynamic Filtering (Ranges + Timestamp BETWEEN)
```abap
DATA lr_status TYPE RANGE OF c LENGTH 1.
APPEND VALUE #( sign = 'I' option = 'EQ' low = 'P' ) TO lr_status.
APPEND VALUE #( sign = 'I' option = 'EQ' low = 'C' ) TO lr_status.

" Define a 7-day window [lv_from, lv_to]
DATA(lv_to)   = cl_abap_tstmp=>get_system_tstmp( ).        " type utclong
DATA(lv_from) = cl_abap_tstmp=>add( tstmp = lv_to secs = -7 * 24 * 60 * 60 ).

SELECT doc_guid, created_at, created_by, status, amount, currency
  FROM zt_dyn_demo
  WHERE status    IN @lr_status
    AND created_at BETWEEN @lv_from AND @lv_to
  INTO TABLE @DATA(lt_recent).
```

## 3) Filter by GUID (C36 → X16 parameterized)
```abap
DATA(lv_guid_c36) = '550E8400-E29B-41D4-A716-446655440000'.
DATA(lv_guid_x16) TYPE sysuuid_x16.

lv_guid_x16 = cl_system_uuid=>if_uuid_static~convert_uuid_c36_to_x16( lv_guid_c36 ).

SELECT * FROM zt_dyn_demo
  WHERE doc_guid = @lv_guid_x16
  INTO TABLE @DATA(lt_one).
```

## 4) Dynamic WHERE String (for optional text/user filters)
```abap
DATA(lv_user) = 'DEMO_USER'.
DATA(lv_text) = 'PRIORITY'.

DATA(lv_where) = |
created_by = '{ cl_abap_dyn_prg=>escape_quotes( lv_user ) }'
and note LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_text ) }%'|.

SELECT doc_guid, created_at, created_by, status
  FROM zt_dyn_demo
  WHERE (lv_where)
  INTO TABLE @DATA(lt_dyn_where).
```

## 5) Dynamic Field List and ORDER BY
```abap
DATA(lv_fields) = 'doc_guid, created_at, status, amount, currency'.
DATA(lv_order)  = 'created_at DESC, amount DESC'.

SELECT (lv_fields)
  FROM zt_dyn_demo
  ORDER BY (lv_order)
  INTO CORRESPONDING FIELDS OF TABLE @DATA(lt_any).
```

## 6) Dynamic Table Name (one code path, multiple tables)
```abap
DATA(lv_tab) = 'ZT_DYN_DEMO'.
SELECT * FROM (lv_tab) INTO TABLE @DATA(lt_all) UP TO 100 ROWS.
```

## 7) RTTS: Create Table Type for a Dynamic Column Set
```abap
" Pick columns at runtime
DATA lt_cols TYPE STANDARD TABLE OF string WITH EMPTY KEY.
lt_cols = VALUE #( ( 'DOC_GUID' ) ( 'CREATED_AT' ) ( 'AMOUNT' ) ( 'CURRENCY' ) ).

" Build a dynamic structure
DATA lt_comp TYPE cl_abap_structdescr=>component_table.
LOOP AT lt_cols INTO DATA(lv_col).
  DATA(lo_type) = SWITCH #( lv_col
    WHEN 'DOC_GUID'   THEN cl_abap_elemdescr=>get_x( 16 )    " RAW(16)
    WHEN 'CREATED_AT' THEN cl_abap_elemdescr=>get_decfloat34( ) " use generic high-prec for demo
    WHEN 'AMOUNT'     THEN cl_abap_elemdescr=>get_p( decimals = 2 length = 15 )
    WHEN 'CURRENCY'   THEN cl_abap_elemdescr=>get_c( 5 )
    ELSE cl_abap_elemdescr=>get_c( 30 ) ).
  APPEND VALUE #( name = lv_col type = lo_type ) TO lt_comp.
ENDLOOP.

DATA(lo_struct) = cl_abap_structdescr=>create( lt_comp ).
DATA(lo_tab)    = cl_abap_tabledescr=>create( p_line_type = lo_struct ).

DATA lr_tab TYPE REF TO data.
CREATE DATA lr_tab TYPE HANDLE lo_tab.
FIELD-SYMBOLS <lt_dyn> TYPE STANDARD TABLE.
ASSIGN lr_tab->* TO <lt_dyn>.

" Build matching field list
DATA(lv_fields2) = REDUCE string( INIT s = '' FOR c IN lt_cols
  NEXT s = cond #( WHEN s IS INITIAL THEN c ELSE |{ s }, { c }| ) ).

SELECT (lv_fields2) FROM zt_dyn_demo INTO TABLE @<lt_dyn> UP TO 50 ROWS.
```

Notes
- Use parameter variables for GUID and timestamps; avoid embedding binary values into strings.
- Ranges and BETWEEN keep statements safe and index-friendly.
- Escape text when constructing `(lv_where)`.
- With RTTS, reuse created descriptors in loops to avoid overhead.
