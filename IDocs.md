---
layout: default
title: "IDocs"
description: Complete guide to IDoc development, configuration, and monitoring
---

#abap #sap-learning #interfaces
# IDocs

Comprehensive guide for IDoc/ALE integration development and administration.

## Transaction Codes

### IDoc Development & Configuration

| Tcode | Description |
|-------|-------------|
| **WE30** | IDoc Type Development - Create/modify IDoc structures |
| **WE31** | IDoc Segment Development - Define segment structures |
| **WE32** | IDoc Segment Documentation |
| **WE60** | IDoc Documentation - Create documentation for IDoc types |
| **WE81** | Message Type Assignment - Define new message types |
| **WE82** | IDoc Type Assignment - Assign IDoc types to message types |
| **WE83** | IDoc Processing Code Assignment |
| **WE84** | Logical Message Assignment |

### Partner Profile Configuration

| Tcode | Description |
|-------|-------------|
| **WE20** | Partner Profile Maintenance - Define partner settings |
| **WE21** | Port Maintenance - Configure communication ports |
| **WE19** | Test Tool for IDocs - Manual IDoc testing |
| **WE40** | Process Code Maintenance - Define inbound processing codes |
| **WE41** | Outbound Process Code - Define outbound processing codes |
| **WE42** | Process Code Assignment to IDoc Type |

### IDoc Monitoring & Administration

| Tcode | Description |
|-------|-------------|
| **WE02** | IDoc List - Monitor IDocs by various criteria |
| **WE05** | IDoc List - Enhanced monitoring with filters |
| **WE09** | IDoc Search - Find IDocs with advanced search |
| **WE07** | IDoc Statistics - Performance analysis |
| **WE14** | IDoc/EDI Monitor - Real-time monitoring |
| **WE15** | IDoc Documentation Display |
| **WE46** | IDoc Status Maintenance - Custom status codes |
| **WE47** | Status Code Assignment |

### IDoc Processing & Workflow

| Tcode | Description |
|-------|-------------|
| **BD87** | Reprocess IDocs - Mass reprocessing of failed IDocs |
| **BD10** | Send Material Master - Material data distribution |
| **BD12** | Send Customer Master - Customer data distribution |
| **BD14** | Send Vendor Master - Vendor data distribution |
| **BD21** | Create Customer Distribution Model |
| **BD22** | Create Vendor Distribution Model |
| **BD64** | Distribution Model Maintenance |
| **BD50** | Activate Change Pointers - Enable change document triggers |
| **BD61** | Change Pointer Monitoring |

### RFC & ALE Configuration

| Tcode | Description |
|-------|-------------|
| **BD54** | Logical System Maintenance |
| **SM59** | RFC Destination Maintenance |
| **WE57** | RFC Destination for IDoc Processing |
| **SALE** | ALE Configuration Menu - Central configuration |
| **SCC4** | Client Configuration - Define client role |
| **BD55** | Client/Logical System Assignment |

### Testing & Troubleshooting

| Tcode | Description |
|-------|-------------|
| **WE16** | Translation IDoc Types - Convert between IDoc versions |
| **WE17** | IDoc Translation Tool |
| **WE18** | IDoc Translation Result Display |
| **BD59** | Check Customizing Settings |
| **BD79** | Consistency Check for Distribution Model |
| **BD93** | Consistency Check Message Control |

## IDoc Structure Components

### Control Record (EDIDC)
- **DOCNUM** - IDoc Number
- **DOCREL** - IDoc Version  
- **STATUS** - Processing Status
- **DIRECT** - Direction (1=Outbound, 2=Inbound)
- **MESTYP** - Message Type
- **IDOCTYP** - IDoc Type
- **RCVPOR** - Receiver Port
- **RCVPRT** - Receiver Partner Type
- **RCVPRN** - Receiver Partner Number

### Data Records (EDID4)
- **SEGNAM** - Segment Name
- **MANDT** - Client
- **DOCNUM** - IDoc Number
- **SEGNUM** - Segment Number
- **PSGNUM** - Parent Segment Number
- **HLEVEL** - Hierarchy Level
- **SDATA** - Segment Data

### Status Records (EDIDS)
- **DOCNUM** - IDoc Number
- **STATUS** - Status Code
- **UNAME** - User Name
- **REPID** - Program Name
- **TABNAM** - Table Name

## Common Status Codes

| Status | Description | Action Required |
|--------|-------------|-----------------|
| **01** | IDoc created | Processing pending |
| **02** | Error in syntax check | Fix IDoc structure |
| **03** | IDoc passed to application | In processing |
| **12** | IDoc passed to application with errors | Check application log |
| **53** | IDoc processed successfully | Complete |
| **51** | Application document created | Complete |
| **26** | Error in ALE service | Check customizing |
| **29** | Error in control record | Verify partner profile |
| **30** | IDoc ready for dispatch | Outbound processing |
| **64** | Error during syntax check of IDoc | Data validation failed |

## Sample Processing Code

### Inbound Processing Function Module Template

```abap
FUNCTION z_idoc_input_orders.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_METHOD) TYPE  BDWFAP_PAR
*"     VALUE(MASS_PROCESSING) TYPE  BDWFAP_PAR
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFAP
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER OPTIONAL
*"----------------------------------------------------------------------

  DATA: lv_docnum TYPE edidc-docnum,
        ls_status TYPE bdidocstat,
        lv_success TYPE abap_bool.

  LOOP AT idoc_contrl INTO DATA(ls_control).
    lv_docnum = ls_control-docnum.
    
    " Initialize status record
    CLEAR ls_status.
    ls_status-docnum = lv_docnum.
    ls_status-status = '53'.  " Successfully processed
    ls_status-msgty = 'S'.
    ls_status-msgid = 'B1'.
    ls_status-msgno = '311'.
    ls_status-msgv1 = lv_docnum.

    " Process IDoc data segments
    PERFORM process_idoc_segments USING lv_docnum
                                CHANGING lv_success.
    
    IF lv_success = abap_true.
      ls_status-status = '53'.
      ls_status-msgty = 'S'.
    ELSE.
      ls_status-status = '51'.
      ls_status-msgty = 'E'.
      ls_status-msgno = '312'.
    ENDIF.

    APPEND ls_status TO idoc_status.
  ENDLOOP.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& Form PROCESS_IDOC_SEGMENTS
*&---------------------------------------------------------------------*
FORM process_idoc_segments USING iv_docnum TYPE edidc-docnum
                          CHANGING cv_success TYPE abap_bool.

  DATA: lt_segments TYPE TABLE OF edidd,
        ls_segment TYPE edidd.

  " Read segments for this IDoc
  READ TABLE idoc_data INTO ls_segment WITH KEY docnum = iv_docnum.
  
  LOOP AT idoc_data INTO ls_segment WHERE docnum = iv_docnum.
    CASE ls_segment-segnam.
      WHEN 'E1EDK01'.  " Document header
        PERFORM process_header_segment USING ls_segment.
      WHEN 'E1EDP01'.  " Item data
        PERFORM process_item_segment USING ls_segment.
      WHEN 'E1EDK03'.  " Date segment
        PERFORM process_date_segment USING ls_segment.
    ENDCASE.
  ENDLOOP.

  cv_success = abap_true.

ENDFORM.
```

### Outbound Processing Example

```abap
DATA: lv_mestyp TYPE edidc-mestyp VALUE 'ORDERS',
      lv_idoctp TYPE edidc-idoctp VALUE 'ORDERS05',
      lv_rcvprt TYPE edidc-rcvprt VALUE 'KU',
      lv_rcvprn TYPE edidc-rcvprn VALUE '1000',
      lt_idoc_data TYPE TABLE OF edidd,
      ls_idoc_control TYPE edidc,
      ls_idoc_data TYPE edidd.

" Fill control record
ls_idoc_control-mestyp = lv_mestyp.
ls_idoc_control-idoctp = lv_idoctp.
ls_idoc_control-rcvprt = lv_rcvprt.
ls_idoc_control-rcvprn = lv_rcvprn.
ls_idoc_control-direct = '1'.  " Outbound

" Fill header segment
ls_idoc_data-segnam = 'E1EDK01'.
ls_idoc_data-sdata = 'Header data here...'.
APPEND ls_idoc_data TO lt_idoc_data.

" Fill item segments
ls_idoc_data-segnam = 'E1EDP01'.
ls_idoc_data-sdata = 'Item data here...'.
APPEND ls_idoc_data TO lt_idoc_data.

" Create IDoc
CALL FUNCTION 'IDOC_OUTPUT_ORDERS'
  EXPORTING
    control_record         = ls_idoc_control
  TABLES
    data_records          = lt_idoc_data
  EXCEPTIONS
    error_creating_idoc   = 1
    error_in_idoc_control = 2
    error_writing_idoc    = 3
    OTHERS               = 4.
```

## Distribution Model Configuration

### Steps to Create Distribution Model

1. **Define Logical Systems** (BD54)
   ```
   Logical System: CLNT100_DEV
   Logical System: CLNT200_QAS
   ```

2. **Create Distribution Model** (BD64)
   ```
   Model Name: ORDERS_DISTRIBUTION
   Message Type: ORDERS
   Sender: CLNT100_DEV
   Receiver: CLNT200_QAS
   ```

3. **Configure Partner Profile** (WE20)
   ```
   Partner Type: LS (Logical System)
   Partner Number: CLNT200_QAS
   Message Type: ORDERS
   Process Code: ORDERS
   ```

## Change Pointer Configuration

### Enable Change Pointers for Master Data

```abap
" Activate change pointers for material master
CALL FUNCTION 'CHANGE_POINTERS_ACTIVATE'
  EXPORTING
    object_class = 'MATERIAL'
  EXCEPTIONS
    OTHERS = 1.

" Create change documents
CALL FUNCTION 'CHANGE_DOCUMENTS_READ'
  EXPORTING
    objectclass = 'MATERIAL'
    objectid    = '000000000000100001'
  TABLES
    editpos     = lt_change_docs.
```

## Error Handling & Monitoring

### Common Error Resolution

```abap
" Reprocess failed IDocs
SUBMIT rbdapp01 WITH docnum = '0000000001234567'
                WITH p_reproc = 'X'.

" Check IDoc status programmatically
SELECT * FROM edids
  INTO TABLE lt_status
  WHERE docnum = lv_docnum
  ORDER BY logdat DESCENDING, logtim DESCENDING.

READ TABLE lt_status INTO ls_status INDEX 1.
IF ls_status-status NE '53'.
  " Handle error
ENDIF.
```

## Best Practices

### Performance Optimization
1. **Batch Processing** - Use BD87 for mass reprocessing
2. **Change Pointers** - Enable only for required objects
3. **Archiving** - Regular cleanup of processed IDocs
4. **Monitoring** - Implement automated status checking

### Security Considerations
1. **Authorization** - Restrict access to sensitive tcodes
2. **Partner Validation** - Verify partner authenticity
3. **Data Encryption** - Use secure communication channels
4. **Audit Trail** - Maintain processing logs

### Development Guidelines
1. **Error Handling** - Comprehensive status management
2. **Documentation** - Detailed segment descriptions
3. **Testing** - Use WE19 for thorough testing
4. **Version Control** - Manage IDoc type changes carefully

## TODO
- Structure, segments, control records ✓
- Inbound/outbound processing and status codes ✓  
- Partner profiles and ports ✓
- Advanced filtering and search techniques
- Custom IDoc type development examples
- Integration with workflow and BPM

## See Also
- [ALE](ALE.html)
- [RFC](RFC.html)
- [Enterprise Services](Enterprise%20Services.html)
