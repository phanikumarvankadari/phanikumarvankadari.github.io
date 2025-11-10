---
layout: default
title: MESSAGE - Error Log
description: ABAP development notes and examples for MESSAGE - Error Log
---

#abap #sap-learning #odata #message #error-handling

# MESSAGE - Error Log

Quick patterns for collecting, exporting, and raising messages. See [[ABAP Error Handling]] for broader context and more variants.

## OData v2: Collect BAPI messages into `lt_message`
```abap
" lt_return: TABLE OF BAPIRET2 from your backend call
DATA: lt_return    TYPE STANDARD TABLE OF bapiret2,
      lt_message   TYPE /iwbep/t_mgw_tech_messages,
      lv_has_error TYPE abap_bool.

" Request-scoped Gateway message container
DATA(lo_msg) = /iwbep/cl_mgw_msg_container=>get_message_container( ).

" Map BAPIRET2 entries to the message container
LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<m>).
  lo_msg->add_message(
    iv_msg_type   = <m>-type         " 'S','I','W','E','A','X'
    iv_msg_id     = <m>-id
    iv_msg_number = <m>-number
    iv_msg_v1     = <m>-message_v1
    iv_msg_v2     = <m>-message_v2
    iv_msg_v3     = <m>-message_v3
    iv_msg_v4     = <m>-message_v4 ).

  IF <m>-type = 'E' OR <m>-type = 'A' OR <m>-type = 'X'.
    lv_has_error = abap_true.
  ENDIF.
ENDLOOP.

" Export collected messages to an internal table
lo_msg->get_messages( IMPORTING et_messages = lt_message ).

" Optional: raise business exception for proper OData error response
IF lv_has_error = abap_true.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING message_container = lo_msg.
ENDIF.
```

## Shortcut: Add all BAPIRET2 at once and choose leading message
```abap
IF     line_exists( lt_return[ type = 'E' ] )
   OR  line_exists( lt_return[ type = 'A' ] )
   OR  line_exists( lt_return[ type = 'X' ] ).

  mo_context->get_message_container( )->add_messages_from_bapi(
    EXPORTING
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING
      textid            = /iwbep/cx_mgw_busi_exception=>business_error
      message_container = mo_context->get_message_container( ).
ENDIF.
```

## Application Log (SLG1) — minimal pattern
```abap
DATA(lo_log) = cl_bal_log=>create(
  i_s_log = VALUE bal_s_log( object = 'ZOBJ' subobject = 'ZSUB' ) ).
cl_bal_log=>add_msg(
  i_log_handle = lo_log
  i_s_msg      = VALUE bal_s_msg( msgty = 'E' msgid = 'ZM' msgno = '001' ) ).
cl_bal_db=>save( ).
```
