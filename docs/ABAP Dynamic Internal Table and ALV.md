---
layout: default
title: ABAP Dynamic Internal Table and ALV
description: ABAP development notes and examples for ABAP Dynamic Internal Table and ALV
---

x# ABAP Dynamic Internal Table and ALV

Dynamic internal tables are created at runtime when the structure is not known at compile-time. Common approaches:
- RTTS (Run Time Type Services): programmatically define components and create types.
- Field catalog helpers: derive a dynamic table from an ALV field catalog.

## RTTS Approach (flexible, modern)
- Build component list (`abap_component_tab`) and create structure/table descriptors.
- Create data references and assign field-symbols to populate rows.
- Works well with SALV to visualize quickly.

```abap
DATA: lt_comp TYPE abap_component_tab,
      ls_comp TYPE abap_componentdescr.

ls_comp-name = 'CARRID'. ls_comp-type ?= cl_abap_elemdescr=>get_c( 3 ).  APPEND ls_comp TO lt_comp.
ls_comp-name = 'CONNID'. ls_comp-type ?= cl_abap_elemdescr=>get_i( ).     APPEND ls_comp TO lt_comp.
ls_comp-name = 'FLDATE'. ls_comp-type ?= cl_abap_elemdescr=>get_d( ).     APPEND ls_comp TO lt_comp.

DATA(lo_struct) = cl_abap_structdescr=>create( lt_comp ).
DATA(lo_table)  = cl_abap_tabledescr=>create( p_line_type = lo_struct ).

DATA lr_tab TYPE REF TO data. CREATE DATA lr_tab TYPE HANDLE lo_table.
FIELD-SYMBOLS: <tab>  TYPE STANDARD TABLE,
               <line> TYPE any, <carrid> TYPE any, <connid> TYPE any, <fldate> TYPE any.
ASSIGN lr_tab->* TO <tab>.
DATA lr_line TYPE REF TO data. CREATE DATA lr_line TYPE HANDLE lo_struct. ASSIGN lr_line->* TO <line>.
ASSIGN COMPONENT 'CARRID' OF STRUCTURE <line> TO <carrid>.
ASSIGN COMPONENT 'CONNID' OF STRUCTURE <line> TO <connid>.
ASSIGN COMPONENT 'FLDATE' OF STRUCTURE <line> TO <fldate>.
<carrid> = 'LH'. <connid> = 400. <fldate> = sy-datum. APPEND <line> TO <tab>.

cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv) CHANGING t_table = <tab> ).
lo_salv->get_display_settings( )->set_striped_pattern( abap_true ).
lo_salv->get_columns( )->set_optimize( abap_true ).
lo_salv->display( ).
```

## Field Catalog Approach (classic ALV)
- Define an `lvc_t_fcat` catalog and let the framework build the table.
- Quick to scaffold when you already know ALV columns.

```abap
DATA: lt_fcat TYPE lvc_t_fcat.

" Define proper types/texts (avoid default C)
APPEND VALUE lvc_s_fcat( fieldname = 'CARRID' inttype = 'C' outputlen = 3  coltext = 'Carrier' ) TO lt_fcat.
APPEND VALUE lvc_s_fcat( fieldname = 'CONNID' inttype = 'I' outputlen = 10 coltext = 'ConnId' ) TO lt_fcat.
APPEND VALUE lvc_s_fcat( fieldname = 'FLDATE' inttype = 'D' outputlen = 10 coltext = 'Flight Date' ) TO lt_fcat.

DATA lr_tab TYPE REF TO data.
cl_alv_table_create=>create_dynamic_table( EXPORTING it_fieldcatalog = lt_fcat IMPORTING ep_table = lr_tab ).

FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE, <wa> TYPE any.
ASSIGN lr_tab->* TO <tab>.

" Create a dynamic line, fill all components, and append
DATA lr_line TYPE REF TO data.
CREATE DATA lr_line LIKE LINE OF <tab>.
ASSIGN lr_line->* TO <wa>.
ASSIGN COMPONENT 'CARRID' OF STRUCTURE <wa> TO FIELD-SYMBOL(<c1>).  <c1> = 'LH'.
ASSIGN COMPONENT 'CONNID' OF STRUCTURE <wa> TO FIELD-SYMBOL(<c2>).  <c2> = 400.
ASSIGN COMPONENT 'FLDATE' OF STRUCTURE <wa> TO FIELD-SYMBOL(<d1>).  <d1> = sy-datum.
APPEND <wa> TO <tab>.

" Optional: display via SALV
cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv) CHANGING t_table = <tab> ).
lo_salv->get_display_settings( )->set_striped_pattern( abap_true ).
lo_salv->get_columns( )->set_optimize( abap_true ).
lo_salv->display( ).
```

Notes
- Prefer RTTS for full control; field catalog for quick ALV scaffolding.
- Always guard dynamic component access with checks in production code.
