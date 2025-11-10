---
layout: default
title: OData Error Handling
description: ABAP development notes and examples for OData Error Handling
---

#abap #sap-learning #cookbook #odata
# OData Error Handling

Boilerplate patterns for OData V2 error handling in DPC_EXT.

## Business Exception with Message
```abap
METHOD my_entityset_get_entityset.
  TRY.
      " ... your logic
    CATCH cx_root INTO DATA(lx).
      DATA(lo_msg) = /iwbep/if_message_container=>get_message_container( ).
      lo_msg->add_message( iv_msgid = 'ZMSG' iv_msgno = '001' iv_msgty = 'E' iv_msgv1 = lx->get_text( ) ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
  ENDTRY.
ENDMETHOD.
```

## Technical Exception
```abap
RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
  EXPORTING textid = /iwbep/cx_mgw_tech_exception=>internal_error
            previous = lx.
```

## Map BAPIRET2 to OData Messages
```abap
DATA(lo_msg) = /iwbep/if_message_container=>get_message_container( ).
LOOP AT lt_return INTO DATA(ls_ret).
  lo_msg->add_message( iv_msgid = ls_ret-id iv_msgno = ls_ret-number iv_msgty = ls_ret-type
                       iv_msgv1 = ls_ret-message_v1 iv_msgv2 = ls_ret-message_v2 ).
ENDLOOP.
RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
  EXPORTING message_container = lo_msg.
```
