;
; HML087_emutator.asm
;
; Created: 24.10.2025 11:12:46
; Author : eleprog
;

; r0 - аппаратно используется в операции умножения
; r1 - 
; r2 -
; r3 -
; r4 -
; r5 -
; r6 -
; r7 -
; r8 -
; r9 -
; r10 -
; r11 -
; r12 -
; r13 -
; r14 -
; r15 -
; r16 - Используется для установки констант в аппаратные регистры
; r17 - 
; r18 -
; r19 -
; r20 -	
; r21 -
; r22 
; r23 - 
; r24 - Используется для хранения значения массива который надо вывести
; r25 - Используется для сохранения регистра SREG в прерываниях
; r26 - XL регистр
; r27 - XH регистр
; r28 - YL регистр
; r29 - YH регистр
; r30 - ZL регистр (используется)
; r31 - ZH регистр (используется)

.org 0x0000 ; таблица векторов прерываний
	RJMP RESET
	RJMP INT0_ISR
	RJMP PCINT0_ISR
	RETI ; TIM0_OVF_ISR
	RETI ; EE_RDY_ISR
	RETI ; ANA_COMP_ISR
	RETI ; TIM0_COMPA_ISR
	RETI ; TIM0_COMPB_ISR
	RETI ; WDT_ISR
	RETI ; ADC_ISR

;.include "1377368.inc" ; E30 325e M20B27 5000RPM USA
;.include "1380873.inc" ; E30 M3 S14 8000RPM Europe
.include "1385468.inc"  ; E30 325i M20B25 7000RPM USA
;.include "1394321.inc" ; E30 318is M42B18 7000RPM USA

RESET:
	CLR r16						; r16 = 0
	OUT SREG, r16				; SREG = 0
	LDI r16, low(RAMEND)		; r16 = 0x9F
    OUT SPL, r16				; Инициализация стека
MAIN:
	; Инициализация портов
    LDI r16, (0<<PIN_DATA)|(0<<PIN_CLOCK)|(0<<PIN_CS)
    OUT DDRB, r16
    LDI r16, (0<<PIN_DATA)|(1<<PIN_CLOCK)|(1<<PIN_CS)
    OUT PORTB, r16

	; Настройка прерываний
	LDI r16, (1<<INT0)|(1<<PCIE); Разрешаем прерывания INT0 и PCINT0
    OUT GIMSK, r16
    LDI r16, (1<<ISC01)|(1<<SE)	; Настройка прерывания INT0 по спадающему фронту и разрешение сна
    OUT MCUCR, r16
    LDI R16, (1<<PIN_CS)		; Настройка маски прерывания PCINT0 для PIN_CS
    OUT PCMSK, R16

	; Читаем значение из массива
	LDI r30, low(dump * 2)
    LDI r31, high(dump * 2)
	LPM r24, Z+

    SEI
LOOP:
	;SLEEP
    RJMP LOOP

INT0_ISR:
	OUT PORTB, r24          ; Записываем байт из массива в PORTB
	LPM r24, Z+				; Читаем следующее значение из массива
	RETI					; Выход из обработчика прерывания
; INT0_ISR

PCINT0_ISR:
    IN r16, PINB			; Читаем PINB
    SBRC r16, PIN_CS		; Пропускаем если CS = 0
    RJMP CS_ACTIVE			; Если CS = 0 ? активен ? включаем выход
CS_INACTIVE:
    CBI DDRB, PIN_DATA		; HI-Z
    CBI PORTB, PIN_DATA		; Отключаем подтягивающий резистор

	IN r25, SREG			; Сохраняем состояние SREG
	LDI r30, low(dump * 2)	; Читаем значение из массива
    LDI r31, high(dump * 2)
    LPM r24, Z+
	OUT SREG, r25			; Восстанавливаем состояние SREG

    RJMP PCINT0_ISR_EXIT	; Переход к метке PCINT0_ISR_EXIT
CS_ACTIVE:
    SBI DDRB, PIN_DATA		; Пин в режим выхода

PCINT0_ISR_EXIT:
	RETI					; Выход из обработчика прерывания
; PCINT0_ISR