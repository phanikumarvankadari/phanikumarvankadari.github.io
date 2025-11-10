---
layout: default
title: Object Oriented ABAP
description: Core OOP concepts, classes, interfaces, inheritance, and design patterns in ABAP
---

# Object Oriented ABAP – Important Topics

## Core OOP
Class definition and implementation (CLASS … DEFINITION/IMPLEMENTATION)
Public/Protected/Private visibility sections
Instance vs static attributes (DATA/CLASS-DATA, CONSTANTS)
Instance vs static methods (METHODS/CLASS-METHODS)
Constructors (constructor, class_constructor)
Method signatures (IMPORTING/EXPORTING/CHANGING/RETURNING VALUE)
Functional methods and NEW constructor operator
Read-only attributes and encapsulation (READ-ONLY)

### Class Visibility and Instantiation (CREATE ...)
- Header visibility: `CLASS zcl_demo DEFINITION PUBLIC ...` makes the class type visible to all consumers. For local classes, `PROTECTED`/`PRIVATE` restrict visibility.
- Instantiation visibility: `CREATE PUBLIC` allows anyone to instantiate; alternatives:
  - `CREATE PROTECTED` – only the class, its subclasses, and friends can instantiate (factory-friendly).
  - `CREATE PRIVATE` – only the class (and friends) can instantiate (singleton/factory enforcing).
- Notes: `ABSTRACT` forbids instantiation regardless of CREATE; `FINAL` forbids subclassing, not instantiation.

Examples
```abap
CLASS zcl_open DEFINITION PUBLIC CREATE PUBLIC.  " visible + freely instantiable
ENDCLASS.

CLASS zcl_factory_only DEFINITION PUBLIC CREATE PRIVATE. " use factory to create
ENDCLASS.

CLASS zcl_base DEFINITION PUBLIC ABSTRACT CREATE PROTECTED. " abstract + protected create
ENDCLASS.
```


### Example (Core OOP)
```abap
" Class definition/implementation, visibility, instance/static members, constructors,
" method signatures, functional methods, NEW operator, and READ-ONLY attributes
CLASS zcl_core_oop_example DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS c_version TYPE string VALUE '1.0'.          " static constant
    CLASS-DATA gv_instances TYPE i.                        " static attribute
    DATA mv_name TYPE string READ-ONLY.                    " instance attribute (read-only)
    DATA mv_value TYPE i.                                  " instance attribute
    METHODS constructor IMPORTING iv_name TYPE string.     " instance constructor
    CLASS-METHODS class_constructor.                       " static constructor
    METHODS set_value IMPORTING iv_value TYPE i
                            CHANGING  cv_state TYPE i.     " IMPORTING/CHANGING parameters
    METHODS get_summary RETURNING VALUE(rv_text) TYPE string. " functional method (RETURNING)
    CLASS-METHODS get_version RETURNING VALUE(rv_ver) TYPE string. " static method
  PROTECTED SECTION.
    METHODS compute_double IMPORTING iv_in TYPE i
                           RETURNING VALUE(rv_out) TYPE i. " protected helper
  PRIVATE SECTION.
    DATA mv_secret TYPE i.                                  " encapsulated private state
ENDCLASS.

CLASS zcl_core_oop_example IMPLEMENTATION.
  METHOD class_constructor.
    gv_instances = 0.                                       " init static state
  ENDMETHOD.

  METHOD constructor.
    mv_name = iv_name.                                      " set READ-ONLY attr in ctor
    gv_instances = gv_instances + 1.                        " track instance count (static)
    mv_secret = 42.                                         " private state
  ENDMETHOD.

  METHOD set_value.
    mv_value = iv_value.                                    " IMPORTING param
    cv_state = compute_double( iv_in = cv_state ).          " CHANGING param + protected call
  ENDMETHOD.

  METHOD get_summary.
    rv_text = |{ mv_name } (v={ c_version }) value={ mv_value }|. " RETURNING value
  ENDMETHOD.

  METHOD get_version.
    rv_ver = c_version.                                     " static method returns constant
  ENDMETHOD.

  METHOD compute_double.
    rv_out = iv_in * 2.
  ENDMETHOD.
ENDCLASS.

" Usage: NEW constructor operator and functional method
DATA(lo_obj) = NEW zcl_core_oop_example( iv_name = 'Demo' ).
DATA(state) = 5.
lo_obj->set_value( iv_value = 10 CHANGING cv_state = state ).
DATA(text) = lo_obj->get_summary( ).                        " functional method used in expression
DATA(ver)  = zcl_core_oop_example=>get_version( ).          " static method call
```



## Inheritance & Polymorphism
Inheritance and redefinition (INHERITING FROM, REDEFINITION)
Polymorphism and dynamic dispatch
Upcast and downcast (?= and CAST)
Abstract and final classes (ABSTRACT, FINAL)
Friends and controlled access (FRIENDS)

### Casting
Casting changes a reference variable’s static type within a class/interface hierarchy. Upcasting (subclass → superclass/interface) is implicit and safe. Downcasting (superclass/interface → subclass) requires a runtime check using `?=` or `CAST type( ref )`. If the dynamic type is incompatible, a `CX_SY_MOVE_CAST_ERROR` is raised. Guard downcasts with `IF ref IS INSTANCE OF type` or `CASE TYPE OF`. Casting never changes the underlying object—only which members the compiler exposes. Prefer interfaces to avoid unnecessary downcasts and keep code loosely coupled.

```abap
" Upcast (implicit)
DATA lr_sub   TYPE REF TO zcl_sub.
DATA lr_super TYPE REF TO zcl_super.
CREATE OBJECT lr_sub.
lr_super = lr_sub.
```

```abap
" Guarded downcast
IF lr_super IS INSTANCE OF zcl_sub.
  DATA(lr_sub2) = CAST zcl_sub( lr_super ). " or: lr_sub2 ?= lr_super
  lr_sub2->do_sub_only( ).
ENDIF.
```

```abap
" Downcast with TRY/CATCH
TRY.
    DATA(lr_sub3) ?= lr_maybe_super.
    lr_sub3->do_work( ).
  CATCH cx_sy_move_cast_error.
    " handle incompatible type
ENDTRY.
```

```abap
" Interface cast
DATA lr_if TYPE REF TO zif_worker.
lr_if = lr_sub.               " upcast to interface
IF lr_if IS INSTANCE OF zcl_sub.
  DATA(lr_back) = CAST zcl_sub( lr_if ).
ENDIF.
```

## Interfaces & Events
Interfaces (INTERFACE, INTERFACES) and multiple interface implementation
Method aliases for interfaces (ALIASES)
Events and event handlers (EVENTS, FOR EVENT, RAISE EVENT)

## Exceptions
Class-based exceptions (CX_ROOT hierarchy)
TRY/CATCH/CLEANUP blocks
RAISE EXCEPTION NEW and RESUMABLE exceptions

## References, RTTI & Generics
Object references and data references (REF TO)
GET REFERENCE OF and dereferencing (->*)
RTTI/RTTS (CL_ABAP_TYPEDESCR, CL_ABAP_CLASSDESCR)
Field-symbols vs references in OO contexts
Shared Memory Objects (area classes, SHARED MEMORY)

## Design Patterns & Architecture
Factory pattern and static factories (GET_INSTANCE)
Singleton (CREATE PRIVATE + class factory)
Strategy, Adapter, Decorator patterns via interfaces
Observer via events and handlers
Dependency inversion and constructor injection
Interface-first design and testability
Global vs local classes (SE24/ADT) and package encapsulation

## Testing & Quality
ABAP Unit test classes (FOR TESTING, RISK LEVEL, DURATION)
Test doubles (CL_ABAP_TESTDOUBLE) and interfaces for seams
TEST-SEAM and TEST-INJECTION
ABAP Doc for classes and methods

## Modern ABAP OOP Features
Constructor expressions (NEW, VALUE, REF)
Inline declarations and expressions (DATA(...), FINAL)
Clean Core extensibility with wrappers and APIs

## RAP-related OOP (context)
Behavior implementation classes (Handler), Determinations/Validations/Actions
Factory and repository concepts in RAP services

## Boilerplate Templates

### Static Utility Class Template
```abap
" A FINAL class exposing only static (CLASS-) methods
CLASS zcl_util_example DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get_version
      RETURNING VALUE(rv_version) TYPE string.
    CLASS-METHODS format
      IMPORTING iv_input TYPE string
      RETURNING VALUE(rv_output) TYPE string.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_util_example IMPLEMENTATION.
  METHOD get_version.
    " TODO: provide version string
  ENDMETHOD.

  METHOD format.
    " TODO: implement formatting logic
  ENDMETHOD.
ENDCLASS.

" Usage
DATA(ver) = zcl_util_example=>get_version( ).
DATA(txt) = zcl_util_example=>format( iv_input = 'demo' ).
```

### Reference (Instance) Class Template
```abap
" A creatable class with instance state and methods
CLASS zcl_ref_example DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor IMPORTING iv_name TYPE string.
    METHODS do_work
      IMPORTING iv_x TYPE i
      EXPORTING ev_y TYPE i
      CHANGING  cv_z TYPE i
      RETURNING VALUE(rv_text) TYPE string.
  PRIVATE SECTION.
    DATA mv_name TYPE string.
ENDCLASS.

CLASS zcl_ref_example IMPLEMENTATION.
  METHOD constructor.
    " TODO: initialize instance
  ENDMETHOD.

  METHOD do_work.
    " TODO: implement behavior, set ev_y/cv_z/rv_text
  ENDMETHOD.
ENDCLASS.

" Usage
DATA(lo_obj) = NEW zcl_ref_example( iv_name = 'Demo' ).
DATA ev TYPE i.
DATA cv TYPE i VALUE 1.
DATA out TYPE string.
out = lo_obj->do_work( iv_x = 2 EXPORTING ev_y = ev CHANGING cv_z = cv ).
```

### Events & Handler Boilerplate
```abap
" Publisher class that raises an event
CLASS zcl_event_publisher DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    EVENTS data_ready EXPORTING VALUE(ev_count) TYPE i.
    METHODS run.
  PRIVATE SECTION.
    DATA mv_count TYPE i.
ENDCLASS.

CLASS zcl_event_publisher IMPLEMENTATION.
  METHOD run.
    mv_count = 42.
    RAISE EVENT data_ready EXPORTING ev_count = mv_count.
  ENDMETHOD.
ENDCLASS.

" Handler class that listens to the event
CLASS zcl_event_handler DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS on_data_ready FOR EVENT data_ready OF zcl_event_publisher
      IMPORTING ev_count sender.
    METHODS get_last RETURNING VALUE(rv_last) TYPE i.
  PRIVATE SECTION.
    DATA mv_last TYPE i.
ENDCLASS.

CLASS zcl_event_handler IMPLEMENTATION.
  METHOD on_data_ready.
    mv_last = ev_count. " handle event payload; sender is available if needed
  ENDMETHOD.

  METHOD get_last.
    rv_last = mv_last.
  ENDMETHOD.
ENDCLASS.

" Wiring: register handler for publisher events and trigger
DATA(lo_pub) = NEW zcl_event_publisher( ).
DATA(lo_hnd) = NEW zcl_event_handler( ).
SET HANDLER lo_hnd->on_data_ready FOR lo_pub.
lo_pub->run( ).
DATA(last) = lo_hnd->get_last( ).
```

### Interface Definition & Implementation Boilerplate
```abap
" Define an interface with one method
INTERFACE zif_worker PUBLIC.
  METHODS do_task
    IMPORTING iv_input TYPE string
    RETURNING VALUE(rv_result) TYPE string.
ENDINTERFACE.

" Implement the interface in a class
CLASS zcl_worker_impl DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_worker.
    ALIASES do_task FOR zif_worker~do_task. " optional alias for convenience
  PRIVATE SECTION.
    DATA mv_name TYPE string.
ENDCLASS.

CLASS zcl_worker_impl IMPLEMENTATION.
  METHOD zif_worker~do_task.
    " TODO: implement real work; using simple echo here
    rv_result = |[{ mv_name }] { iv_input }|.
  ENDMETHOD.
ENDCLASS.

" Usage via interface reference (preferred)
DATA(lo_if) = NEW zcl_worker_impl( ).
DATA(outi)  = lo_if->do_task( iv_input = 'hello' ).

" Usage via class reference with alias
DATA(lo_cl) = NEW zcl_worker_impl( ).
DATA(outc)  = lo_cl->do_task( iv_input = 'world' ).
```
