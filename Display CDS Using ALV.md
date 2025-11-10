#abap #sap-learning #cookbook #alv #abapcds
# CDS Using ALV

Minimal patterns to load CDS entities and show them in SALV. Works for both plain and parameterized CDS view entities.

## Display a CDS View Entity in SALV
```abap
" Using an aggregated CDS entity
DATA lt_totals TYPE TABLE OF zi_salesheaderagg WITH EMPTY KEY.

SELECT FROM zi_salesheaderagg AS a
  FIELDS a~client, a~doc_id, a~total_amount, a~currency, a~item_count, a~followup_date
  INTO TABLE @lt_totals
  UP TO 200 ROWS.

cl_salv_table=>factory(
  IMPORTING r_salv_table = DATA(lo_alv)
  CHANGING  t_table      = lt_totals ).

lo_alv->get_functions( )->set_all( abap_true ).
lo_alv->display( ).
```

## Display a Parameterized CDS View in SALV
```abap
PARAMETERS p_curr TYPE s_currcode DEFAULT 'EUR'.
DATA lt_bycurr TYPE TABLE OF zi_salesbycurr WITH EMPTY KEY.

SELECT FROM zi_salesbycurr( p_currency = @p_curr ) AS b
  FIELDS b~client, b~doc_id, b~total_amount, b~currency, b~item_count, b~followup_date
  INTO TABLE @lt_bycurr.

cl_salv_table=>factory(
  IMPORTING r_salv_table = DATA(lo_alv2)
  CHANGING  t_table      = lt_bycurr ).
lo_alv2->display( ).
```

Notes
- Prefer view entities typed directly in ABAP (`TYPE TABLE OF zi_...`).
- Parameterized entities are called with `( p_param = @value )` in the `FROM` clause.
- Use [[Minimal ALV Grid]] if you want the absolute smallest SALV setup.
- End-to-end example from tables to CDS to ALV: [[Tables to CDS]].


```
cl_salv_gui_table_ids=>create_for_cds_ciew( '<CDS view name>' )->fullscreen( )->display( ).
```