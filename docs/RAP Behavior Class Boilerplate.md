#abap #sap-learning #cookbook #rap
# RAP Behavior Class Boilerplate

Minimal RAP behavior pool implementation skeleton (unmanaged save as example).

```abap
" Behavior definition (example)
" behavior for Z_I_Flight alias Flight
" implementation in class ZBP_I_FLIGHT unique
" unmanaged save

CLASS zbp_i_flight DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES: if_abap_behv.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zbp_i_flight IMPLEMENTATION.
  METHOD if_abap_behv~save.
    " TODO: persist changes (create/update/delete) for entity
  ENDMETHOD.

  METHOD if_abap_behv~finalize.
  ENDMETHOD.

  METHOD if_abap_behv~lock.
  ENDMETHOD.

  METHOD if_abap_behv~read.
  ENDMETHOD.

  METHOD if_abap_behv~rba.
  ENDMETHOD.
ENDCLASS.
```

Notes
- Swap to `managed implementation in class ...` if using managed save.
- Add determinations/validations methods as needed in the behavior definition and implement here.
