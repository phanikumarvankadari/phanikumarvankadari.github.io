```abap
DATA: it_unique TYPE STANDARD TABLE OF FIS_ZUONR.
it_unique = VALUE #(
  FOR GROUPS value OF <line> IN et_entityset
  GROUP BY <line>-assignmentreference WITHOUT MEMBERS ( value ) ).
```
