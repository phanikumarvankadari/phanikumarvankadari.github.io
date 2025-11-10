cds view to alvgrid
```abap
cl_salv_gui_table_ids=>create_for_cds_ciew( '<CDS view name>' )->fullscreen( )->display( ).
```

```abap
" Minimal, production-ready SALV for internal table with header, zebra, optimized layout,
" app toolbar with one custom button and handler
DATA(lo_alv) = cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo) CHANGING t_table = it_data ).
lo->get_display_settings( )->set_list_header( 'My Report' ).  lo->get_display_settings( )->set_striped_pattern( abap_true ).  lo->get_columns( )->set_optimize( abap_true ).
lo->get_functions( )->set_all( abap_true ).                  lo->get_functions( )->add_function( name = 'ZACT' text = 'Action' tooltip = 'Custom Action' position = if_salv_c_function_position=>right_of_salv_functions ).
CLASS lcl_evt DEFINITION. PUBLIC SECTION. CLASS-METHODS on_added FOR EVENT added_function OF cl_salv_events_table IMPORTING e_salv_function. ENDCLASS.
CLASS lcl_evt IMPLEMENTATION. METHOD on_added. IF e_salv_function = 'ZACT'. " TODO: implement handler ENDIF. ENDMETHOD. ENDCLASS.
DATA(lo_ev) = lo->get_event( ). SET HANDLER lcl_evt=>on_added FOR lo_ev. lo->display( ).
```

