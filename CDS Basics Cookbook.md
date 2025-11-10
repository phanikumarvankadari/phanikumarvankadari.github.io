---
layout: default
title: "CDS Basics Cookbook"
description: ABAP development notes and examples for CDS Basics Cookbook
---

#abap #sap-learning #abapcds #cookbook
# CDS Basics Cookbook

Quick, copy‑paste friendly snippets that demonstrate foundational ABAP CDS concepts with short explanations. Prefer modern view entities; legacy SQL views are shown only for context.

## All-in-One Boilerplate View Entity
- Combines parameters, associations, built-in functions, aggregation, conversions, and semantics. Authorization is enabled; add a matching DCL role to enforce checks.
```sql
@EndUserText.label: 'All-in-One Flights Boilerplate'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_Flight_All
  with parameters
    p_carrid     : abap.char(3),
    p_days_ahead : abap.int4
  as select from sflight as f
    association to scarr as _Carrier on _Carrier.carrid = f.carrid
{
  key f.carrid,
  key f.connid,

  // Aggregates per carrier/connection
  count( * )                        as flight_count,
  round( avg( f.price ), -2 )       as avg_price_rounded,

  // Calculations and conversions
  dats_add_days( min( f.fldate ), $parameters.p_days_ahead ) as first_flight_plus_days,
  cast( max( f.fldate ) as abap.char(8) )                    as last_flight_char,

  // Currency semantics
  @Semantics.amount.currencyCode: 'currency'
  sum( f.price )                    as amount_total,
  f.currency                        as currency,

  // Association field via path
  _Carrier.carrname                 as carrier_name
}
where f.carrid = $parameters.p_carrid
group by f.carrid, f.connid, f.currency, _Carrier.carrname
```

## Minimal View Entity
- Modern, DDIC‑independent runtime object with no `sqlViewName`.
```sql
@EndUserText.label: 'Flights (minimal)'
define view entity ZI_Flight_Min as select from sflight as f {
  key f.carrid,
  key f.connid,
  key f.fldate,
      f.price,
      f.currency
}
```

## Associations and Path Expressions
- Prefer associations over explicit joins; consume via path expressions.
```sql
@EndUserText.label: 'Flights with Carrier'
define view entity ZI_Flight as select from sflight as f
  association to scarr as _Carrier on _Carrier.carrid = f.carrid
{
  key f.carrid,
  key f.connid,
  key f.fldate,
      f.price,
      f.currency,
      _Carrier.carrname        as carrier_name  // path expression
}
```

## Parameters
- Parameterized views support input at SELECT time.
```sql
@EndUserText.label: 'Flights by Carrier (param)'
define view entity ZI_FlightByCarrid
  with parameters p_carrid: abap.char(3)
  as select from sflight as f
  where f.carrid = $parameters.p_carrid
{
  key f.carrid,
  key f.connid,
  key f.fldate,
      f.price,
      f.currency
}
```

## Calculated Fields and Built‑in Functions
- Use string, date/time, numeric, and conversion functions inline.
```sql
@EndUserText.label: 'Flights with Calculations'
define view entity ZI_FlightCalc as select from sflight as f {
  key f.carrid,
  key f.connid,
  key f.fldate,
      round( f.price, -2 )          as rounded_price,
      dats_add_days( f.fldate, 10 ) as future_date,
      concat( f.carrid, f.connid )  as id_concat,
      cast( f.fldate as abap.char(8) ) as fldate_char
}
```

## Aggregation and Grouping
- Classic example using `count(*)` and `group by`.
```sql
@EndUserText.label: 'Flights Aggregation'
define view entity ZI_FlightAgg as select from sflight as f {
  key f.carrid,
  key f.connid,
      count( * ) as flight_count,
      round( avg( f.price ), 0 ) as avg_price
}
group by f.carrid, f.connid
```

## Joins (When You Need Them)
- Associations are preferred, but explicit joins remain valid.
```sql
@EndUserText.label: 'Flights join Carrier'
define view entity ZI_FlightJoin as select from sflight as f
  left outer to scarr as c on c.carrid = f.carrid
{
  key f.carrid,
  key f.connid,
  key f.fldate,
      c.carrname as carrier_name
}
```

## Currency/Unit Semantics
- Use `@Semantics.amount.currencyCode` and `@Semantics.quantity.unitOfMeasure`.
```sql
@EndUserText.label: 'Flight Amounts with Currency Semantics'
@Semantics.amount.currencyCode: 'currency'
define view entity ZI_FlightAmount as select from sflight as f {
  key f.carrid,
  key f.connid,
  key f.fldate,
      f.price    as amount,
      f.currency as currency
}
```

## Declarative Access Control (DCL)
- Enable checks and define a CDS role in a separate `.dcl` artifact.
```sql
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flights secured by carrid'
define view entity ZI_FlightSec as select from sflight as f {
  key f.carrid,
  key f.connid,
  key f.fldate,
      f.price,
      f.currency
}
```

```sql
// File: ZI_FlightSec.dcl
@EndUserText.label: 'Role: Limit by CARRID (PFCG)'
define role ZR_FlightSec {
  grant select on entity ZI_FlightSec
    where carrid = aspect pfcg_auth( 'S_CARRID', 'CARRID' );
}
```

## Legacy Style (Context Only)
- Older `define view` with `@AbapCatalog.sqlViewName`—avoid for new models.
```sql
@AbapCatalog.sqlViewName: 'ZV_FLIGHT'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Legacy CDS View (example)'
define view ZV_Flight as select from sflight {
  carrid, connid, fldate, price, currency
}
```

## From CDS to Service (Heads‑up)
- Publish via service definition/binding; actual exposure artifacts live elsewhere.
```abap
" service definition
define service Z_UI_Service {
  expose ZI_Flight    as Flights;
  expose ZI_FlightAgg as FlightAggs;
}
```

Tips
- Prefer view entities; use associations and path expressions liberally.
- Push calculations to DB (code pushdown) and annotate semantics for UIs.
- Keep authorization declarative with DCL roles and `@AccessControl`.
