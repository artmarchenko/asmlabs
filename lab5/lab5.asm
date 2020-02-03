;* СОЗДАНИЕ СЕГМЕНТА СТЭКА *
STACKSEG SEGMENT PARA STACK "STACK"
	     DW      32   DUP(0)
STACKSEG ENDS
;* СОЗДАНИЕ СЕГМЕНТА ДАННЫХ *
DSEG SEGMENT PARA PUBLIC "DATA"
	NUM	  DW 0
	FL    DB 0 				  ; ФЛАГ НЕГАТИВНОГО(1)/ПОЗИТИВНОГО(0) ЧИСЛА
	DUMP  DB 5, ?, 4 DUP('?') ; СТРУКТКРА ДАННЫХ ДЛЯ ХРАНЕНИЯ ВВОДА
	ERRCD DB 0				  ; ФЛАГ ОШИБКИ
							  ; 0 - ОШИБОК НЕТ
							  ; 1 - ОШИБКА
	ERRTXT  DB '*ERROR*'
			DB ' - YOU NEED TO ENTER THE NUMBER$'
	MSGTXT  DB 'ENTER YOU NUMBER:$'
	MSG2TXT DB 'ANSWER:  $'
DSEG ENDS
;--------------------------------------------------------------------------
INCLUDE MACRO.ASM
;--------------------------------------------------------------------------
;* СОЗДАНИЕ СЕГМЕНТА КОДА *
CSEG     SEGMENT PARA PUBLIC "CODE"
;* НАЧАЛО ОСНОВНОЙ ПРОЦЕДУРЫ
 MAIN 	 PROC    FAR
         ASSUME  CS: CSEG, DS: DSEG, SS: STACKSEG		 
    MAGIC		DSEG
      
	PRINTF		MSGTXT	; ПОПРОСИТЬ ВВЕСТИ ЧИСЛО
	
	INPUT		DUMP,ERRCD,NUM,FL
	NEWLINE
	
	CMP			ERRCD,1		;ПРОВЕРИТЬ ОШИБКИ ВВОДА
	JNE		   NO_ERRORS	;ЕСЛИ ОШИБОК НЕТ - 
	PRINTF		ERRTXT		;ИНЧЕ ВЫВЕСТИ СООБЩЕНИЕ ОБ ОШИБКЕ
	MOV			AX,4C00H
	INT			21H
   NO_ERRORS:				;ПРОПУСТИТЬ
	
	ADDITION	NUM,12
	
	PRINTF		MSG2TXT
	OUTPUT		NUM
	
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ
 MAIN ENDP
;* КОНЕЦ ОСНОВНОЙ ПРОЦЕДУРЫ 

CSEG ENDS   ; КОНЕЦ СЕГМЕНТА КОДА
END MAIN	; ВЫХОД ИЗ ПРОГРАММЫ