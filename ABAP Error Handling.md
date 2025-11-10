# ABAP Error Handling

## Class-Based Exceptions (CX_ROOT hierarchy)
```abap
TRY.
    RAISE EXCEPTION NEW cx_sy_no_handler( ).
  CATCH cx_root INTO DATA(cx).
    DATA(msg) = cx->get_text( ).
ENDTRY.
```
## TRY/CATCH/CLEANUP and RESUMABLE exceptions
```abap
TRY.
    RAISE EXCEPTION RESUMABLE NEW cx_sy_arithmetic_error( ).
  CATCH BEFORE UNWIND cx_sy_arithmetic_error INTO DATA(e1).
    " handle and resume
    RESUME.
  CLEANUP.
    " free resources
ENDTRY.
```
## System/Legacy Error Codes (SY-SUBRC patterns)
```abap
SELECT SINGLE * FROM mara INTO @DATA(ls_mara) WHERE matnr = @lv_matnr.
IF sy-subrc <> 0.
  " not found
ENDIF.
```
## MESSAGE Handling (A/E/I/S/W/X) and RAISING
```abap
MESSAGE e001(zm) WITH lv_matnr.     " raises error message from msg class ZM
" In methods:
RAISE EXCEPTION TYPE cx_static_check EXPORTING textid = cx_static_check=>others.
```
## Function Module Exceptions (EXCEPTIONS, MESSAGE ... RAISING)
```abap
CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING nr_range_nr = '01' object = 'ZDOC'
  IMPORTING number = DATA(lv_num)
  EXCEPTIONS interval_not_found = 1 others = 2.
IF sy-subrc <> 0.
  " handle FM exception
ENDIF.
```
## BAPI Return Structures (BAPIRET2 single/table)
```abap
DATA lt_ret TYPE STANDARD TABLE OF bapiret2.
CALL FUNCTION 'BAPI_SOMETHING'
  TABLES return = lt_ret.
READ TABLE lt_ret WITH KEY type = 'E' TRANSPORTING NO FIELDS.
IF sy-subrc = 0.
  " error present; display messages
ENDIF.
```
## Authorization Errors (AUTHORITY-CHECK, exception classes)
```abap
AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
  ID 'MATNR' FIELD lv_matnr
  ID 'WERKS' FIELD lv_werks
  ID 'ACTVT' FIELD '02'.
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW cx_no_authority( ).
ENDIF.
```
## Database/Open SQL Exceptions (e.g., CX_SY_OPEN_SQL_DB)
```abap
TRY.
    UPDATE ztab SET qty = qty + 1 WHERE id = @lv_id.
  CATCH cx_sy_open_sql_db INTO DATA(sqlx).
    " log sqlx->get_text( )
ENDTRY.
```
## Conversion/Casting Exceptions (CONV/EXACT, CX_SY_CONVERSION, CX_SY_MOVE_CAST_ERROR)
```abap
TRY.
    DATA(i1) = EXACT int1( 300 ).
  CATCH cx_sy_conversion_error.
    i1 = 255.
ENDTRY.

TRY.
    DATA(lo_sub) ?= lo_super.
  CATCH cx_sy_move_cast_error.
ENDTRY.
```
## File/IO and RFC/HTTP Exceptions (e.g., CX_ROOT derivatives)
```abap
TRY.
    cl_gui_frontend_services=>gui_download( EXPORTING filename = lv_path CHANGING data_tab = lt_data ).
  CATCH cx_root INTO DATA(iox).
    " handle frontend/file error
ENDTRY.
```
## Application Log (SLG1) and Logging Utilities
```abap
DATA(lo_log) = cl_bal_log=>create( i_s_log = VALUE bal_s_log( object = 'ZOBJ' subobject = 'ZSUB' ) ).
cl_bal_log=>add_msg( i_log_handle = lo_log i_s_msg = VALUE bal_s_msg( msgty = 'E' msgid = 'ZM' msgno = '001' ) ).
cl_bal_db=>save( ).
```
## Assertions and Guards (ASSERT, CHECK, VALIDATE)
```abap
ASSERT NOT lv_matnr IS INITIAL.
CHECK lv_qty > 0. " exit method early if not
```
## Transaction Control (COMMIT/ROLLBACK, LUW boundaries)
```abap
CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'...
IF line_exists( lt_ret[ type = 'E' ] ).
  ROLLBACK WORK.
ELSE.
  COMMIT WORK AND WAIT.
ENDIF.
```
## OData/RAP Error Handling (failed, reported, messages)
```abap
" In RAP behavior implementation
APPEND VALUE #( %tky = <key> %msg = new_message( id = 'Z' number = '001' severity = if_abap_behv_message=>severity-error ) ) TO reported-entity.
failed-entity = VALUE #( ( %tky = <key> ) ).
```
## Unit Test Failures and Test Doubles (ABAP Unit)
```abap
CLASS ltcl_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS test_raises FOR TESTING.
ENDCLASS.
CLASS ltcl_test IMPLEMENTATION.
  METHOD test_raises.
    cl_abap_unit_assert=>assert_raises( cx_static_check = abap_true act = VALUE string( ) ).
  ENDMETHOD.
ENDCLASS.
```
## Cleanup/Finally Patterns and Resource Handling
```abap
DATA(lo_res) = NEW zcl_resource( ).
TRY.
    lo_res->open( ).
    lo_res->work( ).
  CATCH cx_root.
    " log and react
  CLEANUP.
    lo_res->close( ).
ENDTRY.
```

## Master TRY/CATCH Boilerplate (Aggregate Errors)
```abap
" Collects most common errors into a string table and a single string
DATA lt_errors TYPE STANDARD TABLE OF string WITH EMPTY KEY.
DATA lv_err    TYPE string.

" OPTIONAL: resources to clean up
DATA(lo_res) = NEW zcl_resource( ).

TRY.
    " --- Your main logic here ---------------------------------------
    lo_res->open( ).

    " Example DB operation
    UPDATE ztab SET qty = qty + 1 WHERE id = @lv_id.

    " Example conversion (may raise cx_sy_conversion_error)
    DATA(byte) = EXACT int1( '300' ).

    " Example cast (may raise cx_sy_move_cast_error)
    DATA(lo_sub) ?= lo_super.

    " Example authority check
    AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD 'SE38'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW cx_sy_authorization_error( ).
    ENDIF.

  CATCH cx_sy_open_sql_db           INTO DATA(sqlx).
    APPEND sqlx->get_text( ) TO lt_errors.
  CATCH cx_sy_conversion_error      INTO DATA(convx).
    APPEND convx->get_text( ) TO lt_errors.
  CATCH cx_sy_move_cast_error       INTO DATA(castx).
    APPEND castx->get_text( ) TO lt_errors.
  CATCH cx_sy_authorization_error   INTO DATA(authx).
    APPEND authx->get_text( ) TO lt_errors.
  CATCH cx_http_dest_provider_error INTO DATA(httpdestx).
    APPEND httpdestx->get_text( ) TO lt_errors.
  CATCH cx_http_communication_failure INTO DATA(httpcomx).
    APPEND httpcomx->get_text( ) TO lt_errors.
  CATCH cx_root INTO DATA(cxr). " catch-all fallback
    lv_err = cxr->get_text( ).
    IF cxr IS INSTANCE OF if_t100_message.
      lv_err = CAST if_t100_message( cxr )->get_text( ).
    ENDIF.
    APPEND lv_err TO lt_errors.
  CLEANUP.
    " Always free resources; ignore errors during cleanup
    TRY.
        lo_res->close( ).
      CATCH cx_root.
    ENDTRY.
ENDTRY.

" Combine into a single printable string (newline-separated)
DATA(lv_all_errors) = ``.
LOOP AT lt_errors INTO lv_err.
  lv_all_errors = |{ lv_all_errors }{ cl_abap_char_utilities=>cr_lf }- { lv_err }|.
ENDLOOP.

" Example: log, raise, or return aggregated errors
IF lines( lt_errors ) > 0.
  " TODO: handle lv_all_errors or lt_errors as needed
ENDIF.
```

## OData v2 Boilerplate (BAPIRET2 → Gateway Messages)
```abap
" lt_return: TABLE OF BAPIRET2 from your backend call
" et_messages: TABLE OF /IWBEP/IF_MESSAGE_CONTAINER=>ty_t_message (tech messages)
DATA: lt_return    TYPE STANDARD TABLE OF bapiret2,
      et_messages  TYPE /iwbep/t_mgw_tech_messages,
      lv_has_error TYPE abap_bool.

" Get the OData message container (request-scoped singleton)
DATA(lo_msg) = /iwbep/cl_mgw_msg_container=>get_message_container( ).

LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<m>).
  " Map BAPI message to Gateway message container
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

" Export messages to table (e.g., for returning to caller)
lo_msg->get_messages( IMPORTING et_messages = et_messages ).

" Optional: Raise business exception to produce proper OData error response
IF lv_has_error = abap_true.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING message_container = lo_msg.
ENDIF.
```
## Error Handling: BAPI messages to OData business exception

- Pattern: collect BAPI messages from `lt_return`, push into the GW message
  container, and raise a business exception so the OData client receives
  structured errors.
- Leading message selection: use `gcs_leading_msg_search_option-first` to
  determine which message becomes the main one.

```abap
* Check if BAPIRET2 table has any error messages ('E')
READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'  OR <m>-type = 'A' OR <m>-type = 'X'.

IF sy-subrc = 0.                                   " Found at least one error

  " Add all messages from the BAPIRET2 table to the GW message container
  CALL METHOD mo_context->get_message_container( )->add_messages_from_bapi(
    EXPORTING
      it_bapi_messages       = lt_return           " BAPIRET2[] from the BAPI
      iv_determine_leading_msg =
        /iwbep/if_message_container=>gcs_leading_msg_search_option-first
                                                  " Choose first as leading
  ).

  " Raise a business exception so the framework formats the response
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING
      textid            = /iwbep/cx_mgw_busi_exception=>business_error
      message_container = mo_context->get_message_container( ).

ENDIF.
```
### Correction: error type check (E/A/X)

- Avoid `READ TABLE ... WITH KEY type = 'E' OR ...` — `READ TABLE` does not
  support OR conditions. Use `line_exists( itab[ ... ] )` checks or multiple
  `READ TABLE` calls.

```abap
* Check if there are any 'E', 'A', or 'X' messages
IF     line_exists( lt_return[ type = 'E' ] )
   OR  line_exists( lt_return[ type = 'A' ] )
   OR  line_exists( lt_return[ type = 'X' ] ).

  " Add all messages from the BAPIRET2 table to the GW message container
  mo_context->get_message_container( )->add_messages_from_bapi(
    EXPORTING
      it_bapi_messages         = lt_return
      iv_determine_leading_msg =
        /iwbep/if_message_container=>gcs_leading_msg_search_option-first
  ).

  " Raise a business exception so the framework formats the response
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
    EXPORTING
      textid            = /iwbep/cx_mgw_busi_exception=>business_error
      message_container = mo_context->get_message_container( ).

ENDIF.
```
