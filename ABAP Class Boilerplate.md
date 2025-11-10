---
layout: default
title: "ABAP Class Boilerplate"
description: ABAP development notes and examples for ABAP Class Boilerplate
---

#abap #sap-learning #cookbook
# ABAP Class Boilerplate

Minimal class with constructor and main method.

```abap
CLASS zcl_demo DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: constructor
           , main IMPORTING iv_name TYPE string
                   RETURNING VALUE(rv_greeting) TYPE string.
ENDCLASS.

CLASS zcl_demo IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.

  METHOD main.
    rv_greeting = |Hello, { iv_name }!|.
  ENDMETHOD.
ENDCLASS.
```
