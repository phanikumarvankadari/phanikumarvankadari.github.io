---
layout: default
title: "SAP Scripts"
description: Complete guide to SAP Scripts (SAPscript) form development and customization
---

# SAP Scripts

SAP Scripts (SAPscript) is SAP's original form development tool for creating business documents like invoices, purchase orders, delivery notes, and other formatted outputs.

## Key Tables

| Table | Description |
|-------|-------------|
| STXH | Text Header Table - Contains text object metadata |
| STXL | Text Lines - Contains actual text content |
| TTXOB | Text Object - Defines text objects |
| TTXID | Text IDs - Text identification |
| TTDTG | Form Header - SAPscript form header information |
| TTDTT | Form Text - SAPscript form text elements |
| TST03 | SAPscript Standard Texts |
| TNAPR | Processing Programs for Output Types |
| NAST | Message Status - Output message control |

## Transaction Codes

| Tcode | Description |
|-------|-------------|
| **SE71** | Form Painter - Main transaction for SAPscript forms |
| **SE72** | Style Maintenance - Character and paragraph formatting |
| **SO10** | Standard Text Maintenance |
| **SE78** | Graphics Administration |
| **SPAD** | Spool Administration |
| **SP01** | Output Management |
| **VV31** | Output Type Maintenance |
| **NACE** | Output Control Configuration |

## Form Structure

### Main Components

1. **Header** - Form attributes and settings
2. **Pages** - Layout definitions
3. **Windows** - Content areas on pages
4. **Page Windows** - Window positioning on pages
5. **Paragraph Formats** - Text formatting styles
6. **Character Formats** - Individual character styling

### Standard Windows

- **MAIN** - Main content window
- **NEXT** - Continuation page main window
- **TOP** - Header window
- **BOTTOM** - Footer window
- **ADDRESS** - Address window

## Sample Print Program

```abap
REPORT ztest_sapscript.

TYPE-POOLS: slis.

DATA: gv_formname TYPE tdform VALUE 'ZTEST_FORM',
      gv_language TYPE tdspras VALUE 'E',
      gv_device   TYPE tddevice VALUE 'PRINTER',
      gv_dialog   TYPE tdialog VALUE ' '.

START-OF-SELECTION.
  PERFORM open_form.
  PERFORM write_form.
  PERFORM close_form.

*&---------------------------------------------------------------------*
*& Form OPEN_FORM
*&---------------------------------------------------------------------*
FORM open_form.
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      device         = gv_device
      dialog         = gv_dialog
      form           = gv_formname
      language       = gv_language
    EXCEPTIONS
      canceled       = 1
      device         = 2
      form           = 3
      options        = 4
      unclosed       = 5
      mail_options   = 6
      archive_error  = 7
      invalid_fax_no = 8
      more_params_needed_in_batch = 9
      spool_error    = 10
      codepage       = 11
      OTHERS         = 12.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form WRITE_FORM
*&---------------------------------------------------------------------*
FORM write_form.
  " Start main window
  CALL FUNCTION 'START_FORM'
    EXPORTING
      form     = gv_formname
      language = gv_language
    EXCEPTIONS
      form     = 1
      format   = 2
      unended  = 3
      unopened = 4
      unused   = 5
      OTHERS   = 6.

  " Write text element
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER'
      window  = 'MAIN'
    EXCEPTIONS
      element = 1
      window  = 2
      OTHERS  = 3.

  " Write variables
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM'
      window  = 'MAIN'
    EXCEPTIONS
      element = 1
      window  = 2
      OTHERS  = 3.

  " End form
  CALL FUNCTION 'END_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CLOSE_FORM
*&---------------------------------------------------------------------*
FORM close_form.
  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
```

## Text Elements and Control Commands

### Common Control Commands

```abap
" Include other texts
/: INCLUDE &ZTEXTNAME&

" Variable output with formatting
&CUSTOMER-NAME(C)&
&INVOICE-AMOUNT(12.2)&

" Conditional text
/: IF &CUSTOMER-TYPE& = 'PREMIUM'
Premium Customer Benefits
/: ENDIF

" Looping through internal tables
/: DEFINE &LOOP_VAR&
/: LOOP
&ITEM-MATNR& &ITEM-MAKTX& &ITEM-NETPR&
/: ENDLOOP

" New page
/: NEW-PAGE

" Protect text from page break
/: PROTECT ... /: ENDPROTECT

" Call ABAP subroutine
/: PERFORM GET_DATA IN PROGRAM ZREPORT USING &VAR1& &VAR2&
/: CHANGING &RESULT&

" Window calls
/: WINDOW TOP
/: WINDOW MAIN
```

## Text Element Types

### Element Types in Forms

1. **TEXT** - Static text content
2. **VARIABLE** - Dynamic data fields
3. **INCLUDE** - Include other text objects
4. **LOOP** - Repeat sections with table data

### Text Formatting

```abap
" Paragraph formats
<P1> - Paragraph format 1
<P2> - Paragraph format 2

" Character formats
<C1> - Character format 1
<C2> - Character format 2

" Combined formatting
<P1,C1>Formatted text</C1></P1>
```

## Standard Texts (SO10)

### Creating Standard Texts

```abap
" Text Object: TEXT
" Text Name: ZTERMSCONDITIONS
" Text ID: ST (Standard Text)
" Language: EN

" Including in SAPscript
/: INCLUDE ZTERMSCONDITIONS OBJECT TEXT ID ST LANGUAGE EN
```

### Reading Standard Text in ABAP

```abap
DATA: it_lines TYPE TABLE OF tline,
      wa_header TYPE thead.

CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = 'ST'
    language                = sy-langu
    name                    = 'ZTERMSCONDITIONS'
    object                  = 'TEXT'
  IMPORTING
    header                  = wa_header
  TABLES
    lines                   = it_lines
  EXCEPTIONS
    id_not_found           = 1
    language_not_found     = 2
    name_not_found         = 3
    not_found              = 4
    object_not_found       = 5
    reference_check        = 6
    wrong_access_to_archive = 7
    OTHERS                 = 8.
```

## Integration with Print Programs

### Calling from ABAP Reports

```abap
" Open form with options
DATA: ls_control_param TYPE ssfctrlop,
      ls_composer_param TYPE ssfcompop,
      ls_job_output_info TYPE ssfcrescl.

ls_control_param-no_dialog = 'X'.
ls_control_param-preview   = 'X'.

CALL FUNCTION 'SSF_OPEN'
  EXPORTING
    control_parameters = ls_control_param
  IMPORTING
    job_output_info    = ls_job_output_info
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.

" Call the form function
CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = 'ZTEST_FORM'
  IMPORTING
    fm_name           = lv_fm_name
  EXCEPTIONS
    no_form           = 1
    no_function_module = 2
    OTHERS            = 3.

CALL FUNCTION lv_fm_name
  EXPORTING
    control_parameters = ls_control_param
    output_options     = ls_composer_param
    user_settings      = space
    " Add your data here
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.

CALL FUNCTION 'SSF_CLOSE'
  EXCEPTIONS
    job_output_info   = ls_job_output_info
    formatting_error  = 1
    internal_error    = 2
    send_error        = 3
    OTHERS            = 4.
```

## Best Practices

### Form Design

1. **Consistent Layout** - Use standard page formats
2. **Reusable Elements** - Create standard texts for common content
3. **Proper Windows** - Define windows for different content areas
4. **Style Standards** - Use consistent paragraph and character formats

### Performance

1. **Minimize Database Calls** - Prepare data before form processing
2. **Efficient Loops** - Use internal tables efficiently
3. **Text Optimization** - Avoid unnecessary text includes

### Maintenance

1. **Version Control** - Transport forms properly
2. **Documentation** - Document form structure and data requirements
3. **Testing** - Test with various data scenarios
4. **Backup** - Keep copies of working forms

## Common Issues and Solutions

### Form Not Found
```abap
" Check form exists in target system
SELECT SINGLE * FROM ttdtg 
WHERE formname = 'ZTEST_FORM'
AND   language = 'EN'.
```

### Variable Not Displaying
```abap
" Ensure variable is defined in Global Definitions
" Check data is populated before form call
" Verify variable name spelling
```

### Page Break Issues
```abap
" Use PROTECT/ENDPROTECT for critical sections
/: PROTECT
Critical content that should not break
/: ENDPROTECT
```

## Migration to Smart Forms

When migrating from SAPscripts to Smart Forms:

1. **Form Structure** - Map windows to Smart Form windows
2. **Text Elements** - Convert to Smart Form text elements
3. **Logic** - Move ABAP logic to Smart Form nodes
4. **Testing** - Thoroughly test converted forms
5. **Performance** - Compare performance between old and new forms






