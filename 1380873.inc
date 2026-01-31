.equ PIN_DATA  = 0
.equ PIN_CLOCK = 1
.equ PIN_CS    = 2

.equ _0 = (0<<PIN_DATA)|(1<<PIN_CLOCK)|(1<<PIN_CS)
.equ _1 = (1<<PIN_DATA)|(1<<PIN_CLOCK)|(1<<PIN_CS)

; The coder for HML087 1380873 (E30 M3 S14 8000RPM Europe)
; AC 05 00 00 A0 16 1A 7B

dump:
    .db _0, _0, _1, _1, _0, _1, _0, _1
    .db _1, _0, _1, _0, _0, _0, _0, _0
    .db _0, _0, _0, _0, _0, _0, _0, _0
    .db _0, _0, _0, _0, _0, _0, _0, _0
    .db _0, _0, _0, _0, _0, _1, _0, _1
    .db _0, _1, _1, _0, _1, _0, _0, _0
    .db _0, _1, _0, _1, _1, _0, _0, _0
    .db _1, _1, _0, _1, _1, _1, _1, _0