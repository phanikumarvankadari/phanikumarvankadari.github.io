---
layout: default
title: "ABAP CDS Overview"
description: ABAP development notes and examples for ABAP CDS Overview
---

#sap
#sap/abapcds
![[Pasted image 20251102194531.png]]
data model phase -> identify different data sources
ABAP CDS -> provide infra to consume-> data model
types of app -> transactional , analytical, ig, search

![[Pasted image 20251102195152.png]]

full stack possibilities of cds cds model:
1. cds entities -> building blocks for abap data models
2. cds access control -> define role based auth. to protect appliction
3. service definition & service binding -> publish service ur data model as a business service that is exposed for consumption

Odata service for sap fiori
inna service -> analytical client
sql service -> odbc based clients


Extensibility -> dedicated extn points at various levl on data models are provided

Imp. of ABAP CDS -> move. application calculation s to database layer to minimise the commn costs.

with CDS -> data models are rdefine and consumed at db layer rather than app layer

CDS entity types:

- Std view-> cds view entity
- cds prodection view 
- cds custome entity
- cds table function
- type def. - cds simple and cds enum type
- domain specific def. of definition of RAP -> behaviour definition 
- Access control def.

deprecated -> ddic viewa


![[Pasted image 20251102214920.png]]


![[Pasted image 20251102215137.png]]

annotation before define -> valid for whole cds

Define statement defines a cds view
![[Introduction to ABAP Core Data Services (CDS).pdf]]


![[Pasted image 20251102215938.png]]

## CDS Capabilities

### Generic/Aggregation Functions

Aggregation functions are used to perform calculations on a set of rows and return a single value.

**Example:**

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_AGGR'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Aggregation Functions'
define view Z_Cds_Aggregation as select from sflight {
    carrid,
    connid,
    count(*) as flight_count
} group by carrid, connid
```

### Conversion Functions

Conversion functions are used to convert a value from one data type to another.

**Example:**

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_CONV'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Conversion Functions'
define view Z_Cds_Conversion as select from sflight {
    carrid,
    connid,
    cast( fldate as abap.char( 8 ) ) as flight_date_char
}
```

### Date/Time Functions

Date and time functions are used to perform operations on date and time values.

**Example:**

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_DATE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Date/Time Functions'
define view Z_Cds_Date_Time as select from sflight {
    carrid,
    connid,
    fldate,
    dats_add_days(fldate, 10, 'FAIL') as future_date
}
```

### Numeric Functions

Numeric functions are used to perform mathematical operations on numeric values.

**Example:**

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_NUM'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Numeric Functions'
define view Z_Cds_Numeric as select from sflight {
    carrid,
    connid,
    price,
    round(price, -2) as rounded_price
}
```

### String Functions

String functions are used to manipulate character strings.

**Example:**

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_STRING'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS String Functions'
define view Z_Cds_String as select from scarr {
    carrid,
    carrname,
    concat(carrid, carrname) as carrier_id_name
}
```

### All-in-One Example

Here is an example of a single CDS view that uses functions from multiple categories:

```sql
@AbapCatalog.sqlViewName: 'Z_CDS_ALL_FUNCS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS All Functions Example'
define view Z_Cds_All_In_One as select from sflight
{
    // Key fields
    key carrid,
    key connid,
    key fldate,

    // --- String Function ---
    // Concatenate carrier ID and connection ID
    concat(carrid, connid) as flight_connection,

    // --- Numeric Function ---
    // Round the price to the nearest integer
    round(price, 0) as rounded_price,

    // --- Date/Time Function ---
    // Add 10 days to the flight date
    dats_add_days(fldate, 10, 'FAIL') as future_date,

    // --- Conversion Function ---
    // Cast the flight date to a character string
    cast(fldate as abap.char(8)) as flight_date_char,

    // --- Aggregation Function ---
    // This is a placeholder as aggregation functions require GROUP BY
    // and cannot be mixed with non-aggregated fields in this manner.
    // See the dedicated aggregation example above.
    1 as aggregation_placeholder

}
```
