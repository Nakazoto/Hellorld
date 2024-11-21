.ORIGIN: 4268

.TEXT
"HELLORLD!"     ;48 45 4C 4C 4F 52 4C 44 21

.CODE
PSH A           ;FD C8
PSH X           ;FD 88
PSH Y           ;FD 98
PSH U           ;FD A8
LDI XL, 09      ;4A 09
LDI UL, 68      ;6A 68
LDI UH, 42      ;68 42
SJP ED3B        ;BE ED 3B
POP U           ;FD 2A
POP Y           ;FD 1A
POP X           ;FD 0A
POP A           ;FD 8A
RTN             ;9A

.END