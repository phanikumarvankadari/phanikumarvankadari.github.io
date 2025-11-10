---
layout: default
title: Tables to CDS
description: ABAP development notes and examples for Tables to CDS
---

#abap #sap-learning #abapcds #cookbook
# Tables to CDS

Step-by-step guide to go from custom DB tables to CDS view entities with associations, semantics, authorization, and exposure.

## 1) Create Header Table (DDL)
```sql
define table zt_sales_h {
  key client     : abap.clnt not null;
  key doc_id     : abap.numc(10) not null;
      created_by : abap.uname;
      created_at : abap.tims;
      created_on : abap.dats;
      currency   : abap.cuky(5);
}
```

## 2) Create Item Table (DDL)
```sql
define table zt_sales_i {
  key client   : abap.clnt not null;
  key doc_id   : abap.numc(10) not null; // header reference
  key item_no  : abap.numc(6)  not null;
      material : abap.matnr;
      qty      : abap.quan(13,3);
      uom      : abap.unit(3);
      price    : abap.curr(15,2);
      currency : abap.cuky(5);
}
```

Note
- Keep DB-level FK constraints as desired; CDS associations below model the relationship for consumption.

## 3) Item View Entity (reuse in associations)
```sql
@EndUserText.label: 'Sales Item (entity)'
@AccessControl.authorizationCheck: #CHECK
@Semantics.amount.currencyCode: 'currency'
define view entity ZI_SalesItem as select from zt_sales_i as i {
  key i.client,
  key i.doc_id,
  key i.item_no,
      i.material,
      i.qty,
      i.uom,
      i.price   as amount,
      i.currency
}
```

## 4) Header View Entity with Association/Composition
```sql
@EndUserText.label: 'Sales Header (entity)'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_SalesHeader
  as select from zt_sales_h as h
    composition [0..*] to ZI_SalesItem as _Items
      on _Items.client = h.client and _Items.doc_id = h.doc_id
{
  key h.client,
  key h.doc_id,
      h.created_by,
      h.created_on,
      h.created_at,
      h.currency,
      _Items
}
```

## 5) Aggregated Header Projection (totals, counts, built-ins)
```sql
@EndUserText.label: 'Sales Header with Totals'
@AccessControl.authorizationCheck: #CHECK
@Semantics.amount.currencyCode: 'currency'
define view entity ZI_SalesHeaderAgg as select from ZI_SalesItem as i
  inner join ZI_SalesHeader as h on h.client = i.client and h.doc_id = i.doc_id
{
  key h.client,
  key h.doc_id,
      sum( i.amount )                  as total_amount,
      h.currency                       as currency,
      count( distinct i.item_no )      as item_count,
      dats_add_days( h.created_on, 7 ) as followup_date
}
group by h.client, h.doc_id, h.currency
```

## 6) Parameterized Filter Projection
```sql
@EndUserText.label: 'Sales by Currency (param)'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_SalesByCurr
  with parameters p_currency: abap.cuky(5)
  as select from ZI_SalesHeaderAgg as a
  where a.currency = $parameters.p_currency
{
  key a.client,
  key a.doc_id,
      a.total_amount,
      a.currency,
      a.item_count,
      a.followup_date
}
```

## 7) Declarative Access Control (DCL)
```sql
// File: ZI_SalesHeader.dcl
@EndUserText.label: 'Role: Only own documents (PFCG)'
define role ZR_SalesOwn {
  grant select on entity ZI_SalesHeader
    where created_by = aspect pfcg_auth( 'S_USER', 'UNAME' );
}
```

## 8) Service Definition (Heads‑up)
```abap
define service Z_Sales_Service {
  expose ZI_SalesHeader    as SalesHeaders;
  expose ZI_SalesItem      as SalesItems;
  expose ZI_SalesHeaderAgg as SalesHeaderTotals;
}
```

## 9) Consume in ABAP (Path Expression)
```abap
SELECT FROM zi_salesheader AS h
  FIELDS h~doc_id,
         h~created_by,
         _Items[ item_no = '000010' ]-material AS first_material
  INTO TABLE @DATA(lt_result)
  UP TO 20 ROWS.
```

## 10) Show CDS in ALV
```abap
" Example A: Display aggregated header totals in SALV
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

" Example B: Parameterized CDS projection to SALV
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
