# ABAP Conversions (Inline)

Inline conversions let you convert values directly in expressions without temp variables.
Use them for clear, safe, and concise code.

## Operators
- CONV type( expr ) – converts to the target ABAP type.
- EXACT type( expr ) – converts with lossless check; raises on overflow/precision loss.
- xsdbool( cond ) – converts a logical expression to `abap_bool` ('X' / space).

## Examples
```abap
" String -> Integer
DATA(i) = CONV i( '123' ).            " 123

" Integer -> String
DATA(s) = CONV string( i ).           " '123'

" String -> Packed/Decimal
DATA p TYPE p LENGTH 8 DECIMALS 2.
p = CONV p( '123.45' ).               " 123.45

" String (ISO) -> Date/Time
DATA(d) = CONV d( '20251106' ).       " DATS 2025-11-06
DATA(t) = CONV t( '142355' ).         " TIMS 14:23:55

" Narrowing with safety: EXACT raises on overflow
TRY.
    DATA(int1) = EXACT int1( 300 ).   " CX_SY_CONVERSION_ERROR (300 > 255)
  CATCH cx_sy_conversion_error.
    int1 = 255.                       " fallback
ENDTRY.

" NUMC conversion (zero-padded numeric text)
DATA n5 TYPE numc5.
n5 = CONV numc5( 42 ).                " '00042'

" xsdbool for boolean chars
DATA(ok) TYPE abap_bool.
ok = xsdbool( i > 0 ).                " 'X' or ' '

" Use inline conversions inside other expressions
DATA txt TYPE string.
txt = |Count: { CONV string( lines( itab ) ) }|.
```


```

Tips
- Prefer CONV/EXACT over implicit moves to make intent explicit.
- Guard EXACT with TRY/CATCH when narrowing or parsing user input.
- For locale-aware rendering, format in string templates, not with CONV.
