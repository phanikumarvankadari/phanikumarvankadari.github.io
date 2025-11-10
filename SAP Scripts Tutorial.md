---
layout: default
title: "SAP Scripts Tutorial"
description: Step-by-step tutorial for creating SAP Scripts forms from scratch
---

# SAP Scripts Tutorial - Complete Guide

This tutorial walks you through creating a complete SAP Script form step by step, from initial setup to final testing.

## Prerequisites

- Access to SAP system with development authorization
- Basic ABAP knowledge
- Understanding of SAP output management

## Tutorial Overview

We'll create an **Invoice Form** with:
- Company header with logo
- Customer address section
- Line items table
- Footer with terms and conditions
- Print program for testing

---

## Step 1: Create the Form Layout

### 1.1 Open Form Painter
```
Transaction: SE71
```

### 1.2 Create New Form
1. Enter form name: `ZINVOICE_FORM`
2. Click **Create**
3. Enter description: "Invoice Form Tutorial"
4. Save and assign to development package

### 1.3 Define Page Format
```
Header → Change → Page Format
- Page Format: A4 PORTRAIT
- First Page: PAGE1
- Next Page: PAGE1
```

## Step 2: Create Page Layout

### 2.1 Define Page Windows
Go to **Pages** → **PAGE1**

Create these windows:

| Window | Position | Size | Type |
|--------|----------|------|------|
| LOGO | 1cm, 1cm | 5cm x 3cm | CONST |
| HEADER | 7cm, 1cm | 11cm x 3cm | CONST |
| ADDRESS | 1cm, 5cm | 8cm x 4cm | CONST |
| MAIN | 1cm, 10cm | 19cm x 15cm | MAIN |
| FOOTER | 1cm, 26cm | 19cm x 2cm | CONST |

### 2.2 Configure Main Window
```
Window: MAIN
- Text Element: ITEM_TABLE
- Page Window: Check "Main Window"
```

## Step 3: Create Text Elements

### 3.1 Logo Window (LOGO)
```
Text Element: COMPANY_LOGO
Window: LOGO

Content:
/: INCLUDE &LOGO& OBJECT GRAPHICS ID BMAP
```

### 3.2 Header Window (HEADER)
```
Text Element: HEADER_INFO
Window: HEADER

Content:
<C1>YOUR COMPANY NAME</C1>
123 Business Street
City, State 12345
Phone: (555) 123-4567
Email: info@company.com
```

### 3.3 Address Window (ADDRESS)
```
Text Element: BILL_TO
Window: ADDRESS

Content:
<B>Bill To:</B>
&CUSTOMER-NAME&
&CUSTOMER-STREET&
&CUSTOMER-CITY&, &CUSTOMER-REGION& &CUSTOMER-POSTAL&
&CUSTOMER-COUNTRY&

<B>Invoice #:</B> &INVOICE-NUMBER&
<B>Date:</B> &INVOICE-DATE&
<B>Due Date:</B> &DUE-DATE&
```

### 3.4 Main Window (MAIN)
```
Text Element: ITEM_HEADER
Window: MAIN

Content:
<B>Description                    Qty    Price    Amount</B>
________________________________________________

Text Element: ITEM_LINE
Window: MAIN

Content:
&ITEM-DESCRIPTION(30)&    &ITEM-QTY(5)&   &ITEM-PRICE(10.2)&   &ITEM-AMOUNT(12.2)&

Text Element: TOTAL_LINE
Window: MAIN

Content:
________________________________________________
<B>                               Total: &TOTAL-AMOUNT(12.2)&</B>
```

### 3.5 Footer Window (FOOTER)
```
Text Element: TERMS
Window: FOOTER

Content:
Payment Terms: Net 30 days | Thank you for your business!
```

## Step 4: Create Print Program

### 4.1 Create ABAP Program
```
Transaction: SE80
Program Name: ZPRINT_INVOICE
Program Type: Report
Description: Invoice Print Program
```

### 4.2 Complete Print Program Code

```abap
REPORT zprint_invoice.

" Data declarations
TYPES: BEGIN OF ty_customer,
         name    TYPE string,
         street  TYPE string,
         city    TYPE string,
         region  TYPE string,
         postal  TYPE string,
         country TYPE string,
       END OF ty_customer,
       
       BEGIN OF ty_item,
         description TYPE string,
         qty         TYPE p DECIMALS 0,
         price       TYPE p DECIMALS 2,
         amount      TYPE p DECIMALS 2,
       END OF ty_item,
       
       tt_items TYPE TABLE OF ty_item.

DATA: gv_formname     TYPE tdform VALUE 'ZINVOICE_FORM',
      gv_language     TYPE tdspras VALUE 'E',
      gv_device       TYPE tddevice VALUE 'PRINTER',
      gs_customer     TYPE ty_customer,
      gt_items        TYPE tt_items,
      gs_item         TYPE ty_item,
      gv_invoice_no   TYPE string,
      gv_invoice_date TYPE string,
      gv_due_date     TYPE string,
      gv_total        TYPE p DECIMALS 2.

" Selection screen
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_invno TYPE string LOWER CASE DEFAULT 'INV-2024-001',
            p_custno TYPE string LOWER CASE DEFAULT 'CUST001'.
SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM prepare_data.
  PERFORM print_invoice.

*&---------------------------------------------------------------------*
*& Form PREPARE_DATA
*&---------------------------------------------------------------------*
FORM prepare_data.
  " Prepare customer data
  gs_customer-name = 'Acme Corporation'.
  gs_customer-street = '456 Client Avenue'.
  gs_customer-city = 'Business City'.
  gs_customer-region = 'BC'.
  gs_customer-postal = '54321'.
  gs_customer-country = 'USA'.
  
  " Prepare invoice header
  gv_invoice_no = p_invno.
  gv_invoice_date = |{ sy-datum+6(2) }/{ sy-datum+4(2) }/{ sy-datum(4) }|.
  gv_due_date = |{ sy-datum+6(2) }/{ sy-datum+4(2) }/{ sy-datum(4) + 30 }|.
  
  " Prepare line items
  CLEAR: gt_items, gv_total.
  
  gs_item-description = 'Professional Services - Hours'.
  gs_item-qty = 40.
  gs_item-price = '125.00'.
  gs_item-amount = gs_item-qty * gs_item-price.
  APPEND gs_item TO gt_items.
  gv_total = gv_total + gs_item-amount.
  
  gs_item-description = 'Software License'.
  gs_item-qty = 1.
  gs_item-price = '500.00'.
  gs_item-amount = gs_item-qty * gs_item-price.
  APPEND gs_item TO gt_items.
  gv_total = gv_total + gs_item-amount.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form PRINT_INVOICE
*&---------------------------------------------------------------------*
FORM print_invoice.
  " Open form
  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      device                      = 'SCREEN'
      dialog                      = 'X'
      form                        = gv_formname
      language                    = gv_language
      options-tddest              = 'LOCL'
    EXCEPTIONS
      canceled                    = 1
      device                      = 2
      form                        = 3
      options                     = 4
      unclosed                    = 5
      mail_options                = 6
      archive_error               = 7
      invalid_fax_no              = 8
      more_params_needed_in_batch = 9
      spool_error                 = 10
      codepage                    = 11
      OTHERS                      = 12.
  
  IF sy-subrc <> 0.
    MESSAGE 'Error opening form' TYPE 'E'.
    RETURN.
  ENDIF.
  
  " Start form
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
  
  " Write header info
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                = 'HEADER_INFO'
      window                 = 'HEADER'
    EXCEPTIONS
      element                = 1
      window                 = 2
      OTHERS                 = 3.
  
  " Write customer address
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                = 'BILL_TO'
      window                 = 'ADDRESS'
    EXCEPTIONS
      element                = 1
      window                 = 2
      OTHERS                 = 3.
  
  " Write item header
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                = 'ITEM_HEADER'
      window                 = 'MAIN'
    EXCEPTIONS
      element                = 1
      window                 = 2
      OTHERS                 = 3.
  
  " Write line items
  LOOP AT gt_items INTO gs_item.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element              = 'ITEM_LINE'
        window               = 'MAIN'
      EXCEPTIONS
        element              = 1
        window               = 2
        OTHERS               = 3.
  ENDLOOP.
  
  " Write total
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                = 'TOTAL_LINE'
      window                 = 'MAIN'
    EXCEPTIONS
      element                = 1
      window                 = 2
      OTHERS                 = 3.
  
  " Write footer
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                = 'TERMS'
      window                 = 'FOOTER'
    EXCEPTIONS
      element                = 1
      window                 = 2
      OTHERS                 = 3.
  
  " End form
  CALL FUNCTION 'END_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.
  
  " Close form
  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened = 1
      OTHERS   = 2.
  
  MESSAGE 'Invoice printed successfully' TYPE 'S'.
ENDFORM.
```

## Step 5: Add Global Variables

### 5.1 Define Global Variables
In SE71, go to **Utilities** → **Global Variables**

```abap
" Customer variables
CUSTOMER-NAME    TYPE C LENGTH 50
CUSTOMER-STREET  TYPE C LENGTH 50  
CUSTOMER-CITY    TYPE C LENGTH 30
CUSTOMER-REGION  TYPE C LENGTH 10
CUSTOMER-POSTAL  TYPE C LENGTH 10
CUSTOMER-COUNTRY TYPE C LENGTH 30

" Invoice variables  
INVOICE-NUMBER   TYPE C LENGTH 20
INVOICE-DATE     TYPE C LENGTH 10
DUE-DATE         TYPE C LENGTH 10

" Item variables
ITEM-DESCRIPTION TYPE C LENGTH 50
ITEM-QTY         TYPE P DECIMALS 0
ITEM-PRICE       TYPE P DECIMALS 2
ITEM-AMOUNT      TYPE P DECIMALS 2

" Total
TOTAL-AMOUNT     TYPE P DECIMALS 2
```

## Step 6: Create Style (Optional)

### 6.1 Create Character Format
```
Transaction: SE72
Style: ZINVOICE_STYLE
```

Create formats:
- **B** = Bold text
- **C1** = Company header (Bold, 14pt)
- **SMALL** = Small text (8pt)

## Step 7: Testing and Validation

### 7.1 Test Form Layout
```
SE71 → Utilities → Test
```

### 7.2 Test Print Program
```
SE80 → Execute program ZPRINT_INVOICE
```

### 7.3 Debug Variables
Add breakpoints in print program to verify:
- Customer data population
- Item loop processing  
- Total calculation

## Step 8: Enhancement Tips

### 8.1 Add Logo
1. Upload company logo using SE78
2. Reference in LOGO window: `/: INCLUDE &COMPANY_LOGO& OBJECT GRAPHICS ID BMAP`

### 8.2 Conditional Logic
```
/: IF &CUSTOMER-TYPE& = 'PREMIUM'
Special discount applied!
/: ENDIF
```

### 8.3 Standard Text Integration
```
/: INCLUDE TERMS_CONDITIONS OBJECT TEXT ID ST LANGUAGE EN
```

### 8.4 Multiple Pages
```
/: NEW-PAGE
```

## Common Issues and Solutions

### Issue: Variable Not Displaying
**Solution:** Check Global Variables definition and ensure variable names match exactly

### Issue: Window Overlap
**Solution:** Verify window positions and sizes don't overlap in Page Painter

### Issue: Text Too Long
**Solution:** Use PROTECT/ENDPROTECT for text that shouldn't break:
```
/: PROTECT
Critical content here
/: ENDPROTECT
```

### Issue: Performance Problems
**Solution:** Prepare all data before calling OPEN_FORM, minimize database calls inside form

## Next Steps

1. **Transport** the form to test/production systems
2. **Integrate** with business documents (invoices, POs, etc.)
3. **Configure** output management (NACE)
4. **Create** variants for different document types
5. **Consider migration** to Smart Forms or Adobe Forms for new developments

## Additional Resources

- **SE71** - Form development
- **SE72** - Style maintenance  
- **SO10** - Standard texts
- **NACE** - Output control
- **SPAD** - Printer configuration

This tutorial provides a complete foundation for SAP Script development. Practice with different layouts and requirements to master the technology!