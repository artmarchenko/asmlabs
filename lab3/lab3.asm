; (40x 2 -23) / x  якщо 0 < x ≤ 7
; 38x 3 +5         якщо x ≤ 0
; 126 /x           якщо x > 7

;* СОЗДАНИЕ СЕГМЕНТА СТЭКА *
STACKSEG SEGMENT PARA STACK "STACK"
	     DW      32   DUP(0)
STACKSEG ENDS
;* СОЗДАНИЕ СЕГМЕНТА ДАННЫХ *
DSEG SEGMENT PARA PUBLIC "DATA"
							  ; ПРОМЕЖУТОЧНЫЕ ПЕРЕМЕННЫЕ ДЛЯ УРАВНЕНИЙ
	X 	  DW ?
	REZ	  DW ?
	REZ2  DW ?
	
	TEMP  DW 126
	FL    DB 0 				  ; ФЛАГ НЕГАТИВНОГО(1)/ПОЗИТИВНОГО(0) ЧИСЛА
	DUMP  DB 5, ?, 4 DUP('?') ; СТРУКТКРА ДАННЫХ ДЛЯ ХРАНЕНИЯ ВВОДА
	ERRCD DB 0				  ; ФЛАГ ОШИБКИ
							  ; 0 - ОШИБОК НЕТ
							  ; 1 - ОШИБКА
	COMATXT DB ','
	ERRTXT  DB '*ERROR*'
			DB ' - SOMETHING WENT WRONG$'
	MSGTXT  DB 'ENTER YOUR NUMBER:$'
	MSG2TXT DB 'ANSWER:  $'	
	CELOETXT DB 'CELOE:$'
	OSTATOKTXT DB 'OSTATOK:$'
DSEG ENDS
;--------------------------------------------------------------------------
;* СОЗДАНИЕ СЕГМЕНТА КОДА *
CSEG     SEGMENT PARA PUBLIC "CODE"
;* НАЧАЛО ОСНОВНОЙ ПРОЦЕДУРЫ
 MAIN 	 PROC    FAR
         ASSUME  CS: CSEG, DS: DSEG, SS: STACKSEG		 
   ;* MAGIC * (РАЗМЕЩЕНИЕ ПРОГРАММЫ В ПАМЯТИ?)
	PUSH     DS
	MOV 	 AX, 0
	PUSH 	 AX
	MOV 	 AX, DSEG       ; *ИНИЦИАЛИЗАЦИЯ СЕГМЕНТНОГО
	MOV 	 DS, AX         ;  РЕГИСРА 'DS'*
   ;* MAGIC END'S *
      
	CALL     ENTER_MSG_PROC		
	CALL 	 INPUT_PROC		;ВЫЗОВ ПРОЦЕДУРЫ "ВВОДА ДАННЫХ"
	CMP 	 ERRCD,1		; *ЕСЛИ ЕСТЬ ОШИБКА
	JE 		ERR_EXIT		;  ПЕРЕЙТИ К ВЫВОДУ СООБЩЕНИЯ*
	
	MOV 	 BX,AX			 ; ЧТО БЫ НЕ ПОТЕРЯТЬ ВВЕДЕННОЕ ЧИСЛО
	CALL     ENTER_MSG2_PROC
	MOV 	 AX,BX			 ; ЧТО БЫ НЕ ПОТЕРЯТЬ ВВЕДЕННОЕ ЧИСЛО
		
	CMP FL,1
			
	JE		 EQUATION2		 ; ЕСЛИ 'AX' < 0
	
	CMP AX,0
	JE		 EQUATION2		 ; ЕСЛИ 'AX' = 0
	CMP AX,7
	JA 		 EQUATION3		 ; ЕСЛИ 'AX' > 7
	JMP 	 EQUATION1		 
	
   EQUATION1:				 ; УРАВНЕНИЕ 1
	CALL 	 EQUATION1_PROC  ; ЕСЛИ ПЕРВОЕ УСЛОВИЕ ИСТИНА	
	CALL 	 ENTER_CELOE_PROC
	MOV 	 AX,REZ
	CALL	 OUTPUT_PROC	 ;ВЫЗОВ ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ"	
	CALL	 ENTER_OSTATOK_PROC
	MOV 	 AX,REZ2		 ;ВЫВЕСТИ ОСТАТОК
	CALL	 OUTPUT_PROC
	MOV 	 AL,'/'
	INT 	 29H
	MOV 	 AX,X
	CALL 	 OUTPUT_PROC
	JMP 	FINISH			 ; ЧТО БЫ НЕ СЧИТАТЬ ДРУГИЕ УРАВНЕНИЯ
	
   EQUATION2:
	CALL 	 EQUATION2_PROC  ; ЕСЛИ ВТОРОЕ УСЛОВИЕ ИСТИНА			
	CALL 	 OUTPUT_PROC
	JMP 	FINISH			 ; ЧТО БЫ НЕ СЧИТАТЬ ДРУГИЕ УРАВНЕНИЯ
	
   EQUATION3:
	CALL 	 EQUATION3_PROC  ; ЕСЛИ ТРЕТЬЕ УСЛОВИЕ ИСТИНА
	CALL 	 ENTER_CELOE_PROC
	MOV 	 AX,REZ
	CALL	 OUTPUT_PROC	 ;ВЫЗОВ ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ"	
	CALL	 ENTER_OSTATOK_PROC
	MOV 	 AX,REZ2		 ;ВЫВЕСТИ ОСТАТОК
	CALL	 OUTPUT_PROC
	MOV 	 AL,'/'
	INT 	 29H
	MOV 	 AX,X
	CALL 	 OUTPUT_PROC
	JMP 	FINISH			 ; ЧТО БЫ НЕ СЧИТАТЬ ДРУГИЕ УРАВНЕНИЯ
	
   FINISH:	
	
	CMP 	 ERRCD,0		; *ЕСЛИ ОШИБОК НЕТ
	JE      EXIT_POINT      ;  ВЫЙТИ ИЗ ПРОГРАММЫ*

   ERR_EXIT:
	CALL ERRMSG_PROC        ; ВЫВОД СООБЩЕНИЯ ОБ ОШИБКЕ НА ЭКРАН
		
   EXIT_POINT:		        ; ДЛЯ "ВНЕШТАТНОГО" ВЫХОДА 
	
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ
 MAIN ENDP
 ;* КОНЕЦ ОСНОВНОЙ ПРОЦЕДУРЫ 
;--------------------------------------------------------------------------
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ"
  ENTER_MSG_PROC PROC	 
	 MOV 	 AH,9				
	 MOV 	 DX,OFFSET MSGTXT	; ВЫВЕСТИ СООБЩЕНИЕ
	 INT 	 21H
	 MOV 	 AL,0AH				; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
	 INT 	 29H
	 RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ	
  ENTER_MSG_PROC ENDP
 ;* КОНЕЦ ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ"
;--------------------------------------------------------------------------
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ2"
  ENTER_MSG2_PROC PROC
	 MOV 	 AL,0AH				; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
	 INT 	 29H
	 MOV 	 AH,9				
	 MOV 	 DX,OFFSET MSG2TXT	; ВЫВЕСТИ СООБЩЕНИЕ
	 INT 	 21H
	 RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ	
  ENTER_MSG2_PROC ENDP
 ;* КОНЕЦ ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ2"
;--------------------------------------------------------------------------
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ ОБ ОШИБКЕ"
  ERRMSG_PROC PROC
	 MOV 	 AL,0AH				; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
	 INT 	 29H
	 MOV 	 AH,9				
	 MOV 	 DX,OFFSET ERRTXT	; ВЫВЕСТИ СООБЩЕНИЕ
	 INT 	 21H
	 MOV     AX,4C00h			; ЗАВЕРШИТЬ ПРОГРАММУ
     INT     21h
  ERRMSG_PROC ENDP
 ;* КОНЕЦ ПРОЦЕДУРЫ "ВЫВОДА СООБЩЕНИЯ ОБ ОШИБКЕ"
;--------------------------------------------------------------------------
 ;* УРАВНЕНИЕ 1
  EQUATION1_PROC PROC
	 MOV X,AX
	 MOV BX,AX
	 MUL BX
	 MOV BX,40
	 MUL BX
	 MOV BX,23
	 SUB AX,BX
	 MOV BX,X
	 DIV BX
	 MOV REZ,AX
	 MOV REZ2,DX
	 
	 RET
  EQUATION1_PROC ENDP
;--------------------------------------------------------------------------
 ;* УРАВНЕНИЕ 2
  EQUATION2_PROC PROC
	 MOV X,AX
	 MOV BX,AX
	 IMUL BX
	 MOV BX,X
	 IMUL BX
	 MOV BX,38
	 IMUL BX
	 ADD AX,5
	 
	 RET
  EQUATION2_PROC ENDP
;--------------------------------------------------------------------------
 ;* УРАВНЕНИЕ 3
  EQUATION3_PROC PROC
	 MOV X,AX
	 MOV BX,AX
	 MOV AX,TEMP
	 XOR DX,DX
	 DIV BX
	 MOV REZ,AX
	 MOV REZ2,DX

	 RET
  EQUATION3_PROC ENDP
;--------------------------------------------------------------------------
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВВОДА ДАННЫХ"
 INPUT_PROC PROC

	MOV ERRCD,0  		; ОБНУЛЕНИЕ КОДА ОШИБКИ
   ;* ВВОД ДАННЫХ С КЛАВИТУРЫ *
	LEA 	 DX,DUMP	; РАЗМЕЩЕНИЕ В 'DX' СТРУКТУРЫ 'DUMP'
	MOV 	 AH,10		; КОД '10' ПРЕРЫВНИЯ 21..
	INT 	 21H		; ..ОТВЕЧАЕТ ЗА ВВОД ДАННЫХ С КЛАВИАТУРЫ
   ;* КОНЕЦ ПРОЦЕДУРЫ "ВВОДА ДАННЫХ"
   ;* ОПРЕДЕЛЕНИЕ КОЛ-ВА ВВЕДЕНЫХ СИМОВЛОВ
	LEA 	 SI,DUMP+1 	; РАЗМЕЩЕНИЕ В 'SI' АДРЕСА С КОЛ-ВОМ ВВЕДЕНЫХ ЗНАКОВ
	XOR 	 CX,CX		; ОБНУЛЕНИЕ СЧЕТЧИКА
	MOV 	 CL,[SI]	; "УСТАНОВКА" СЧЕТЧИКА
	CMP 	 CX,0		; *ЕСЛИ НИЧЕГО НЕ ВВЕДЕНО
	JE 		SOME_ERR    ; ВЫВЕСТИ КОД ОШИБКИ
   ;* ОПРЕДЕЛЕНИЕ ПОЗИТИВНОСТИ ЧИСЛА
	MOV 	 FL,0		; ДЛЯ СБРОСА ФЛАГА ПОЗ/НЕГ ЧИСЛА
	INC 	 SI			; *ПЕРЕХОД С КОЛ-ВА ВВЕДЕНЫХ СИМВОЛОВ
						;  НА ПЕРВЫЙ ВВЕДЕННЫЙ СИМВОЛ.
	MOV 	 AL,[SI]	;  РАЗМЕЩЕНИЕ ЕГО В РЕГИСТР ДЛЯ ОБРАБОТКИ.
	CMP 	 AL,'-'		;  ПРОВЕРКА МИНУС ЛИ ЭТО.
	JNE 	NO_MINUS	;  ЕСЛИ МИНУСА НЕТ - ПЕРЕХОД*
	MOV		 FL,1		; УСТАНОКА ФЛАГА НЕГАТИВНОГО ЧИСЛА
	DEC 	 CL			; УЧЕСТЬ МИНУС В КОЛ-ВЕ ВВЕДЕННЫХ СИМВОЛОВ
	CMP 	 CX,0		; *ЕСЛИ КРОМЕ МИНУСА НИЧЕГО НЕ ВВЕДЕНО
	JE 		SOME_ERR	;  ВЫЙТИ ИЗ ПРОГРАММЫ*
	INC 	 SI			; ПЕРЕЙТИ К СЛЕДУЮЩЕМУ РАЗРЯДУ ЧИСЛА   
   NO_MINUS:   			;* НАЧАЛО РАБОТЫ С ЧИСЛОМ
	XOR 	 AX,AX		; ОЧИСТКА 'AX'
	XOR 	 DI,DI		; ОЧИСТКА 'DI'
	MOV 	 DI,10		; ДЛЯ РАЗДЕЛЕНИЯ ЧИСЛА НА РАЗРЯДЫ
	DEC 	 SI			; ВОЗВРАЩАЕМСЯ К РАБОЧЕМУ СИМВОЛУ
   FOR_LOOP:			; НАЧАЛО ЦИКЛА ПРОХОДА ПО ЧИСЛУ(ПОРАЗРЯДНО)
	INC 	 SI			; ПЕРЕХОД К ПЕРВОМУ СИМВОЛУ
	XOR 	 BX,BX		; ОБНУЛЕНИЕ 'BX'
	MOV 	 BL,[SI]	; РАЗМЕЩЕНИЕ ЧИСЛА В РЕГИСТР
	SUB 	 BL,'0'		; ПРЕОБРАЗОВАНИЕ ASCII TO DEC
	CMP 	 BL,9		; *ЕСЛИ ВВЕДЕНА НЕ ЦИФРА
	JA 		SOME_ERR	;  ВЫЙТИ ИЗ ПРОГРАММЫ*
	MUL 	 DI			; *УМНОЖАЕМ 'AX' НА 10 ДЛЯ ДОБАВЛЕНИЯ МЕСТА
						;  ПОД НОВЫЙ СИМВОЛ* (1 -> 10 + 'BX' = 11)
	ADD 	 AX,BX		;  ПРИБАВЛЯЕМ К ЧИСЛУ В 'AX' ПОЛУЧЕННУЮ ЦИФРУ
   LOOP 	FOR_LOOP    ; "КОНЕЦ" ЦИКЛА ПРОХОДА ПО ЧИСЛУ
	CMP 	 FL,1		; *ЕСЛИ ЧИСЛО НЕ ОТРИЦАТЕЛЬНОЕ
	JNE 	NOT_NEG		;  НИЧЕГО НЕ ДЕЛАЕМ.
	NEG 	 AX			;  ИНЧЕ - ДЕЛАЕМ ЕГО НЕГАТИВНЫМ.
   NOT_NEG: 
    CMP 	 ERRCD,0    ; *ЕСЛИ ОШИБОК НЕТ
    JE		 EXIT		;  НА ВЫХОД ИЗ ПРОЦЕДУРЫ*
   
   SOME_ERR:
    MOV		 ERRCD,1	; ПОДНЯТЬ ФЛАГ ОШИБКИ - 1
	
   EXIT:
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ			
 INPUT_PROC ENDP
 ;* КОНЕЦ ПРОЦЕДУРЫ "ВВОДА ДАННЫХ"
;--------------------------------------------------------------------------
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ"
  OUTPUT_PROC PROC
  
	MOV 	 BX,AX		; РАЗМЕЩЕНИЕ ЧИСЛА В РЕГИСТРЕ AX
	OR 		 BX,BX 		; *ЕСЛИ ЧИЛО ПОЛОЖИТЕЛЬНОЕ
	JNS		M1			;  ПЕРЕЙТИ В M1.	
	MOV 	 AL,"-"		;  ИНЧЕ РАЗМЕСТИТ В РЕЗУЛЬТАТЕ СИМВОЛ МИНУСА.
	INT 	 29H		;  ВЫВЕСТИ МИНУС НА ЭКРАН*
	NEG 	 BX			; ИЗМЕНИТЬ СТАРШИЙ БИТ ЧИСЛА("УБРАТЬ МИНУС")
   M1:					; ТОЧКА ПРЕХОДА ЕСЛИ ЧИСЛО ПОЗИТИВНОЕ
	MOV 	 AX,BX		; ОБНОВИТЬ ЧИСЛО В РЕГИСТРЕ 'AX'(ИЗ-ЗА "NEG BX")
	XOR 	 CX,CX		; ОБНУЛИТЬ РЕГИСТР СЧЕТЧИКА
	MOV 	 BX,10		; ДЛЯ РАЗДЕЛЕНИЯ ЧИСЛА НА РАЗРЯДЫ
   M2:					; НАЧАЛО ЦИКЛА "РАЗМЕЩЕНИЕ ЧИСЛА В СТЕКЕ"
	XOR 	 DX,DX		; ОБНУЛЕНИЕ 'DX'
	DIV 	 BX			; ДЕЛЕНИЕ 'AX' НА 'BX'(ОТДЕЛЕНИЕ РАЗРЯДА)
	ADD 	 DL,"0"		; DECIMAL TO ASCII
	PUSH 	 DX			; РАЗМЕЩЕНИЕ РЕЗУЛЬТАТА В СТЕКЕ
	INC 	 CX			; УВЕЛИЧЕНИЕ СЧЕТЧИКА
	TEST 	 AX,AX		; *ЕСЛИ ЕЩЕ ОСТАЛИСЬ ЦИФРЫ В ЧИСЛЕ
	JNZ 	 M2			;  ПОВТОРИТЬ "РАЗМЕЩЕНИЕ В СТЕКЕ"
   M3:					; НАЧАЛО ЦИКЛА ВЫВОДА ЧИСЛА ИЗ СТЕК НА ЭКРАН
	POP 	 AX			; ДОСТАТЬ ВЕРХНЮЮ ЦИФРУ ИЗ СТЭКА
	INT 	 29H		; ВЫВЕСТИ ЕЁ НА ЭКРАН
   LOOP 	M3			; ПОВТОРИТЬ 'M3' ПОКА СЧЕТЧИК НЕ '0'
	
	RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ	
  OUTPUT_PROC ENDP
 ;* КОНЕЦ ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ"
;--------------------------------------------------------------------------
  ENTER_CELOE_PROC PROC
	 MOV 	 AL,0AH					; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
	 INT 	 29H
	 MOV 	 AH,9				
	 MOV 	 DX,OFFSET CELOETXT		; ВЫВЕСТИ СООБЩЕНИЕ
	 INT 	 21H
	 RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ	
  ENTER_CELOE_PROC ENDP
;--------------------------------------------------------------------------
  ENTER_OSTATOK_PROC PROC
	 MOV 	 AL,0AH					; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
	 INT 	 29H
	 MOV 	 AH,9				
	 MOV 	 DX,OFFSET OSTATOKTXT	; ВЫВЕСТИ СООБЩЕНИЕ
	 INT 	 21H
	 RET		;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ	
  ENTER_OSTATOK_PROC ENDP
;--------------------------------------------------------------------------

CSEG ENDS   ; КОНЕЦ СЕГМЕНТА КОДА
END MAIN	; ВЫХОД ИЗ ПРОГРАММЫ