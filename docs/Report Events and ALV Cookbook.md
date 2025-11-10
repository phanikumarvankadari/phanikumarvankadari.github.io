---
layout: default
title: Report Events and ALV Cookbook
description: ABAP development notes and examples for Report Events and ALV Cookbook
---

#abap #sap-learning #reports #alv
# Report Events and ALV Cookbook

Two end-to-end report snippets you can paste into SE38/ADT:
- Example 1 shows most selection-screen widgets, common report events, and classic ALV List (REUSE_ALV_LIST_DISPLAY) with zebra, header, alignment, and totals.
- Example 2 shows a minimal SALV Grid using the OO API with zebra, auto column optimize, right-justified numeric columns, header, and aggregations.

See also: [[ALV List]], [[SALV]], [[ABAP Report Boilerplate]].

## Example 1 — Report Events + Selection Screen + Classic ALV List

```abap
REPORT zcook_events_alv_list.

TABLES: sflight.

DATA: gt_sflight TYPE TABLE OF sflight.

" Selection screen with box, file, checkbox, radio buttons and a select-option
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001. " Maintain TEXT-001 = 'Selection'
PARAMETERS: p_file TYPE rlgrap-filename LOWER CASE.
PARAMETERS: p_chk  AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_r1   RADIOBUTTON GROUP rg DEFAULT 'X',
            p_r2   RADIOBUTTON GROUP rg.
SELECT-OPTIONS: s_carr FOR sflight-carrid.
SELECTION-SCREEN END OF BLOCK b1.

" Event: INITIALIZATION — set defaults
INITIALIZATION.
  s_carr-sign   = 'I'.
  s_carr-option = 'CP'.
  s_carr-low    = 'AA*'.
  APPEND s_carr.

" Event: F4 help for file parameter
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

" Event: F1 help for file parameter
AT SELECTION-SCREEN ON HELP-REQUEST FOR p_file.
  MESSAGE |Provide a local filename or path to import data (e.g., flights.csv).| TYPE 'I'.

" Event: Dynamic screen modifications
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_FILE'.
      screen-input = COND i( WHEN p_r2 = 'X' THEN 1 ELSE 0 ).
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

" Event: General validation
AT SELECTION-SCREEN.
  IF p_r2 = 'X' AND p_file IS INITIAL.
    MESSAGE e398(00) WITH 'Please choose a file for option 2'.
  ENDIF.

" Main logic
START-OF-SELECTION.
  IF p_r1 = 'X'.
    SELECT *
      FROM sflight
      INTO TABLE @gt_sflight
      WHERE carrid IN @s_carr.
  ELSE.
    " Placeholder: In real usage, upload from p_file using GUI_UPLOAD/CL_GUI_FRONTEND_SERVICES
    CLEAR gt_sflight.
  ENDIF.

END-OF-SELECTION.
  PERFORM display_alv_list.

" List header (also shown in ALV list if layout permits)
TOP-OF-PAGE.
  WRITE: / 'SFLIGHT Report', 30 'Date:', sy-datum, 45 'Time:', sy-uzeit.

"------------------------------
" ALV List using REUSE_ALV_LIST_DISPLAY
"------------------------------
FORM display_alv_list.
  DATA: lt_fcat   TYPE slis_t_fieldcat_alv,
        ls_fcat   TYPE slis_fieldcat_alv,
        ls_layout TYPE slis_layout_alv.

  CLEAR ls_layout.
  ls_layout-zebra               = 'X'.
  ls_layout-colwidth_optimize   = 'X'.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'CARRID'.
  ls_fcat-seltext_l = 'Carrier'.
  ls_fcat-hotspot   = 'X'.        " Hotspot for &IC1 user command
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'CONNID'.
  ls_fcat-seltext_l = 'ConnId'.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'FLDATE'.
  ls_fcat-seltext_l = 'Date'.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'SEATSMAX'.
  ls_fcat-seltext_l = 'Seats'.
  ls_fcat-do_sum    = 'X'.         " Aggregation
  ls_fcat-just      = 'R'.         " Right-justified numeric
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'PRICE'.
  ls_fcat-seltext_l = 'Price'.
  ls_fcat-do_sum    = 'X'.
  ls_fcat-just      = 'R'.
  APPEND ls_fcat TO lt_fcat.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'ALV_USER_COMMAND'
      is_layout          = ls_layout
      it_fieldcat        = lt_fcat
    TABLES
      t_outtab           = gt_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.

" Handle hotspot/double-click (&IC1)
FORM alv_user_command USING r_ucomm LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.
  IF r_ucomm = '&IC1'.
    READ TABLE gt_sflight INDEX rs_selfield-tabindex INTO DATA(ls_row).
    IF sy-subrc = 0.
      MESSAGE |Carrier { ls_row-carrid } Conn { ls_row-connid }| TYPE 'I'.
      " Example navigation (adapt to real tcode/params):
      " SET PARAMETER ID 'CAR' FIELD ls_row-carrid.
      " CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.
```

Notes
- Replace the placeholder file upload with `CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD` or `GUI_UPLOAD` if you want to populate `gt_sflight` from a CSV.
- Alignment and totals are controlled via the field catalog (`JUST`, `DO_SUM`).
 - Includes F1 (help-request) and F4 (value-request) examples for `p_file`.

## Example 2 — Minimal SALV Grid (OO ALV) with Zebra, Header, Alignment, Aggregations

```abap
REPORT zcook_salv_grid_min.

TABLES: sflight.
DATA: gt_sflight TYPE STANDARD TABLE OF sflight.

SELECT *
  FROM sflight
  INTO TABLE @gt_sflight
  UP TO 200 ROWS.

DATA(lo_alv) = NEW cl_salv_table( ).
cl_salv_table=>factory(
  IMPORTING r_salv_table = lo_alv
  CHANGING  t_table      = gt_sflight ).

" Zebra layout and list header
lo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
lo_alv->get_display_settings( )->set_list_header( 'SFLIGHT Summary' ).

" Auto-optimize widths
lo_alv->get_columns( )->set_optimize( abap_true ).

" Right-justify numeric columns
DATA(lo_cols) = lo_alv->get_columns( ).
TRY.
    DATA(lo_col_price) = CAST cl_salv_column_table( lo_cols->get_column( 'PRICE' ) ).
    lo_col_price->set_alignment( if_salv_c_alignment=>right ).
    DATA(lo_col_seats) = CAST cl_salv_column_table( lo_cols->get_column( 'SEATSMAX' ) ).
    lo_col_seats->set_alignment( if_salv_c_alignment=>right ).
  CATCH cx_salv_not_found.
ENDTRY.

" Aggregations (totals) in the grid footer
DATA(lo_aggs) = lo_alv->get_aggregations( ).
TRY.
    lo_aggs->add_aggregation( 'PRICE' ).
    lo_aggs->add_aggregation( 'SEATSMAX' ).
  CATCH cx_salv_data_error.
ENDTRY.

" Optional: enable all std. functions (export, sort, sum, etc.)
lo_alv->get_functions( )->set_all( abap_true ).

lo_alv->display( ).
```

Tips
- Prefer SALV for quick tabular output with minimal code; it handles layout, functions, and aggregation well.
- Use `get_top_of_list` + `CL_SALV_FORM_LAYOUT_GRID` when you need a multi-line rich header.
- Classic ALV List (`REUSE_ALV_LIST_DISPLAY`) remains useful in systems without full SALV support or when you need list events not exposed via SALV.

## User Command — ALV Hotspot (Classic List)

Tiny add-on to Example 1 to react on a hotspot click using `AT USER-COMMAND` callback (`&IC1`). Add hotspot to a column, pass the callback FORM, and handle the picked row.

```abap
" 1) Mark a field as hotspot in the field catalog (example: CARRID)
CLEAR ls_fcat.
ls_fcat-fieldname = 'CARRID'.
ls_fcat-seltext_l = 'Carrier'.
ls_fcat-hotspot   = 'X'.
APPEND ls_fcat TO lt_fcat.

" 2) Pass user-command callback when calling ALV
CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
  EXPORTING
    i_callback_program      = sy-repid
    i_callback_user_command = 'ALV_USER_COMMAND'
    is_layout               = ls_layout
    it_fieldcat             = lt_fcat
  TABLES
    t_outtab                = gt_sflight.

" 3) Handle command (&IC1 for hotspot/double-click)
FORM alv_user_command USING r_ucomm LIKE sy-ucomm
                            rs_selfield TYPE slis_selfield.
  IF r_ucomm = '&IC1'.
    READ TABLE gt_sflight INDEX rs_selfield-tabindex INTO DATA(ls_row).
    IF sy-subrc = 0.
      MESSAGE |Carrier { ls_row-carrid } Conn { ls_row-connid }| TYPE 'I'.
      " Example navigation (adapt to real tcode/params):
      " SET PARAMETER ID 'CAR' FIELD ls_row-carrid.
      " CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.
```

Optional — SALV double‑click

```abap
" After creating lo_alv in Example 2
TRY.
    DATA(lo_col) = CAST cl_salv_column_table( lo_alv->get_columns( )->get_column( 'CARRID' ) ).
    lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
  CATCH cx_salv_not_found.
ENDTRY.

DATA(lo_events) = lo_alv->get_event( ).

CLASS lcl_hndl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_dbl FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.
CLASS lcl_hndl IMPLEMENTATION.
  METHOD on_dbl.
    MESSAGE |Row { row } Column { column }| TYPE 'I'.
  ENDMETHOD.
ENDCLASS.

SET HANDLER lcl_hndl=>on_dbl FOR lo_events.
```
