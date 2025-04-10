#ifndef __m_util_inc
#define __m_util_inc

; push double register to stack
;
; usage: PUSHD Z
.macro PUSHD
	push @0H
	push @0L
.endmacro

; pop double register from stack
;
; usage: POPD Z
.macro POPD
	pop @0L
	pop @0H
.endmacro

; load immediate word to double register
;
; usage: LDIW Z, CONSTANT_PTR
.macro LDIW
	ldi @0H, HIGH(@1)
	ldi @0L, LOW(@1)
.endmacro

; compute a pointer from a constant base and an offset
; used for e.g. indexing tables
;
; usage: ldi ZL, OFFSET
;        LEAC Z, MY_TABLE
.macro LEAC
	clr @0H
	subi @0L, LOW(-@1)
	sbci @0H, HIGH(-@1)
.endmacro

#endif
