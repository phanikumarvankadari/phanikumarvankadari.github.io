---
layout: default
title: "Get Unique Values from Itab"
description: ABAP development notes and examples for Get Unique Values from Itab
---

```abap
DATA: it_unique TYPE STANDARD TABLE OF FIS_ZUONR.
it_unique = VALUE #(
  FOR GROUPS value OF <line> IN et_entityset
  GROUP BY <line>-assignmentreference WITHOUT MEMBERS ( value ) ).
```
