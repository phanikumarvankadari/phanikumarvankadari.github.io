---
layout: default
title: ABAP Report Boilerplate
description: ABAP development notes and examples for ABAP Report Boilerplate
---

#abap #sap-learning #cookbook
# ABAP Report Boilerplate

Minimal REPORT structure with selection screen and error handling.

```abap
REPORT z_demo_report.

PARAMETERS p_carrid TYPE s_carr_id OBLIGATORY.

START-OF-SELECTION.
  TRY.
      PERFORM run.
    CATCH cx_root INTO DATA(lx).
      MESSAGE lx->get_text( ) TYPE 'E'.
  ENDTRY.

FORM run.
  DATA lt_scarr TYPE TABLE OF scarr WITH EMPTY KEY.
  SELECT * FROM scarr INTO TABLE lt_scarr WHERE carrid = @p_carrid.
  IF sy-subrc <> 0.
    MESSAGE 'No carrier found' TYPE 'I'.
  ELSE.
    LOOP AT lt_scarr INTO DATA(ls).
      WRITE: / ls-carrid, ls-carrname.
    ENDLOOP.
  ENDIF.
ENDFORM.
```

## Minimal SELECT + LOOP variant
```abap
REPORT z_demo_min.

SELECT carrid, carrname FROM scarr INTO TABLE @DATA(lt_scarr) UP TO 10 ROWS.
LOOP AT lt_scarr INTO DATA(ls_scarr).
  WRITE: / ls_scarr-carrid, ls_scarr-carrname.
ENDLOOP.
```
