;* СОЗДАНИЕ СЕГМЕНТА СТЭКА *
STACKSEG SEGMENT PARA STACK "STACK"
         DW      32   DUP(0)
STACKSEG ENDS
;* СОЗДАНИЕ СЕГМЕНТА ДАННЫХ *
DSEG SEGMENT PARA PUBLIC "DATA"
    MES1 DB     0DH,"START ARRAY  - $"
    MES2 DB     0DH,"SORTED ARRAY - $"
    MES3 DB     0DH,"ELEMENT SUM  - $"
    MES4 DB     0DH,"MAX ELEMENT  - $"
    MES5 DB     0DH,"ENTER YOUR ARRAY:$"
    MES6 DB     0DH,"ENTER YOUR NUMBER FOR SEARCH:$"
    MES7 DB     0DH,"COORDINATES FOUND: $"
    MES8 DB     "( $"
    MES9 DB     " ; $"
    MES10 DB    " ) $"
    MES11 DB    " $"
    N    EQU    16
    MAS  DW     17 DUP (?)
    MASCP DW    17 DUP (?)
    SRCH DW     ?
    TMP  DW     ?
    OUTPT DW    ?
    I    DW     0
    J    DW     0
DSEG ENDS
 
WRT MACRO   STRING
    MOV     AH,9            ; Функция вывода строки
    LEA     DX,STRING       ; Загружаем адрес строки
    INT     21H             ; Вызов прерывания DOS
ENDM
;--------------------------------------------------------------------------
;* СОЗДАНИЕ СЕГМЕНТА КОДА *
CSEG     SEGMENT PARA PUBLIC "CODE"
;* НАЧАЛО ОСНОВНОЙ ПРОЦЕДУРЫ
 MAIN    PROC    FAR
         ASSUME  CS: CSEG, DS: DSEG, SS: STACKSEG        
   ;* MAGIC * (РАЗМЕЩЕНИЕ ПРОГРАММЫ В ПАМЯТИ?)
    PUSH     DS
    MOV      AX, 0
    PUSH     AX
    MOV      AX, DSEG       ; *ИНИЦИАЛИЗАЦИЯ СЕГМЕНТНОГО
    MOV      DS, AX         ;  РЕГИСРА 'DS'*
   ;* MAGIC END'S *
   
    ;ВВОД МАССИВА
   WRT      MES5
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
   CALL     INPUT_PROC
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
   ;*
   
   WRT      MES1                ; ЗАЛОЖИТЬ СООБЩЕНИЕ ДЛЯ ВЫВОДА
   CALL     ARRAY_MSG_PROC      ; ВЫВЕСТИ ИЗНАЧАЛЬНЫЙ МАССИВ НА ЭКРАН
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
 
   ; ПОДСЧЕТ СУММЫ ЭЛЕМЕНТОВ И ВЫВОД НА ЭКРАН
   CALL     ARRAY_SUM_PROC         
   WRT      MES3
   CALL     OUTPUT_PROC         ; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'*
   ;*   
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
   
   ; НАХОЖДЕНИЕ МАКСИМАЛЬНОГО ЭЛЕМЕНТА И ВЫВОД НА ЭКРАН
   CALL     ARRAY_MAX_PROC   
   WRT      MES4
   CALL     OUTPUT_PROC         ; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'*
   ;*
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
   
   ; СОРТИРОВКА МАСИВА И ВЫВОД НА ЭКРАН
   CALL     ARRAY_SORT_PROC     ; БЕЗ 'ПУЗЫРЬКА' НЕ РАЗОБРАТЬСЯ
   WRT      MES2
   CALL     ARRAY_MSG_PROC      ; ВЫВЕСТИ ОТСОРТИРОВАНЫЙ МАССИВ НА ЭКРАН
   ;*
   CALL     KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
   
   ; ПОЛУЧИТЬ ПОИСКОВЫЙ
    WRT     MES6                ; ПОПРОСИТЬ ВВЕСТИ ПОИСКОВЫЙ
    CALL    KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
    CALL    INPUT_POISKOVIY     ; ПОЛУЧИТЬ ОТ ПОЛЬЗОВАТЕЛЯ ПОИСКОВЫЙ
    CALL    KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ
    ;* 
    
    ; НАЙТИ КООРДИНАТЫ ВХОЖДЕНИЯ    
    WRT     MES7                ; "ENTRY FOUND"
    CALL    FIND_COORDINATES    ;НАЙТИ ВХОЖДЕНИЯ И ВЫВЕСТИ ИХ НА ЭКРАН   
    CALL    KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ 
    ;*
   
   RET      ;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ
 MAIN ENDP
 ;* КОНЕЦ ОСНОВНОЙ ПРОЦЕДУРЫ 
;--------------------------------------------------------------------------
 PRINT_MSG PROC
    MOV     BX,AX       ; ЧТО БЫ НЕ ПОТЕРЯТЬ ЗНАЧЕНИЕ В РЕГИСТРЕ    
    MOV     AH,09H      ; ВЫВЕСТИ ТО ЧТО ПОЛОЖЕНО В 'DX'
    INT     21H
    MOV     AX,BX       ; ВЕРНУТЬ ЗНАЧЕНИЕ В 'AX'
    
    RET
 PRINT_MSG ENDP
;--------------------------------------------------------------------------
 ARRAY_MSG_PROC PROC 
    MOV     CX,N        ; КОЛ-ВО ЭЛЕМЕНТОВ МАССИВА В СЧЕТЧИК
    MOV     SI,0        ; НАЧИНАЕТЬСЯ С НУЛЕВОГО    
   FORLOOP:
    MOV     DX,MAS[SI]  ; ЗАКЛАДЫВАЕТЬСЯ ЭЛЕМЕНТ МАСИВА
    ADD     DL,'0'      ; ПРЕОБРАЗОВЫВАЕТСЯ В ASCII
    MOV     AH,02H      ; ВЫВОДИТЬСЯ НА ЭКРАН
    INT     21H
    ADD     SI,2        ; ПЕРЕХОД К СЛЕДУЮЩЕМУ ЭЛЕМЕНТУ   
   LOOP     FORLOOP
    
    RET
 ARRAY_MSG_PROC ENDP
;--------------------------------------------------------------------------
 ARRAY_SUM_PROC PROC
    XOR     DX,DX
    XOR     AX,AX       ; ОБНУЛЯЕМ 'AX'
    MOV     CX,N        ; КОЛ-ВО ЭЛЕМЕНТОВ МАССИВА В СЧЕТЧИК
    MOV     SI,0        ; НАЧИНАЕТЬСЯ С НУЛЕВОГО
   FORLOOP1:
    MOV     DX,MAS[SI]  ; ЗАКЛАДЫВАЕТЬСЯ ЭЛЕМЕНТ МАСИВА
    ADD     AX,DX       ; СУММИРУЮТЬСЯ ЭЛЕМЕНТЫ
    ADD     SI,2        ; ПЕРЕХОД К СЛЕДУЮЩЕМУ ЭЛЕМЕНТУ
   LOOP     FORLOOP1
    
    MOV     OUTPT,AX        ; OUTPT = RESULT
    RET
 ARRAY_SUM_PROC ENDP
;--------------------------------------------------------------------------
 ARRAY_MAX_PROC PROC 
    MOV     AX,MAS[0]   ;ПЕРВЫЙ ЭЛЕМЕНТ ПОМЕЩАЕТСЯ В 'AX'
    MOV     TMP,AX      ;СЧИТАЕМ ЕГО МАКСИМАЛЬНЫМ И ЗАПОМИНАЕМ
    MOV     CX,N        ; КОЛ-ВО ЭЛЕМЕНТОВ МАССИВА В СЧЕТЧИК
    DEC     CX          ; ТАК КАК ПЕРВЫЙ УЖЕ ЭЛЕМЕНТ УЖЕ ПРОЙДЕН
    MOV     SI,2        ;ОДИН ЭЛЕМЕНТ ЯЧЕЙКИ ЗАНИМАЕТ ДВА БИТА
   FORLOOP2:
    MOV     AX,MAS[SI]  ;СЛЕДУЮЩИЙ ЕЛЕМЕНТ ЗАКЛАДЫВАЕТСЯ В 'AX'
    CMP     TMP,AX      ;СРАВНИВАЕТСЯ С ПРЕДПОЛАГАЕМЫМ МАКСИВАЛЬНЫМ
    JL      JNGMAX      ;ЕСЛИ НОВЫЙ ЭЛЕМЕНТ БОЛЬШЕ*
    JMP     NOTMAX      ;ИНЧЕ-
   JNGMAX:
    MOV     AX,MAS[SI]  ; "НА ВСЯКИЙ"
    MOV     TMP,AX      ;*СЧИТАЕМ ЕГО МАКСИМАЛЬНЫМ
   NOTMAX:
    ADD     SI,2        ;-ПЕРЕХОДИМ К СЛЕДУЮЩЕМУ ЭЛЕМЕНТУ
   LOOP     FORLOOP2
   
    MOV     AX,TMP
    MOV     OUTPT,AX
    ;MOV    AX,TMP      ; 'AX' = РЕЗУЛЬТАТ
    
    RET
 ARRAY_MAX_PROC ENDP
;--------------------------------------------------------------------------
 ARRAY_SORT_PROC PROC 
    XOR     CX,CX
    MOV     CX,N
    MOV     BX,0
;$-11:
    MOV     AX,MAS[BX]
    MOV     MASCP[BX],AX
    ADD     BX,2
    LOOP    $-11
 
    XOR    CX,CX    ;ОЧИСТКА СЧЕТЧИКА
   START_SORT:
    MOV    CX,N     ; КОЛ-ВО ЭЛЕМЕНТОВ МАССИВА В СЧЕТЧИК
    DEC    CX       ; ЧТО БЫ ИСПОЛЬЗОВАТЬ КАК АДРЕС (ОТ 0 ДО 8)
    SHL    CX,1     ; ТАК КАК ХРАНИТЬСЯ СЛОВО. (СДВИГ БИТА ВЛЕВО/УМНОЖЕНИЕ НА 2)
   CYCL_START:   
    MOV    BX,CX        ;ДЛЯ ИСПОЛЬЗОВАНИЯ В ИНДЕКСАЦИИ 
    MOV    AX,MAS[BX]   ; ЗАПИСАТЬ В 'AL' ТЕКУЩИЙ ЭЛЕМЕНТ МАССИВА 
    CMP    AX,MAS[BX-2] ; СРАВНЕНИЕ ТЕКУЩЕГО ЭЛЕМЕНТА массива с предыдущим
    JL    EXCHANGE      ; ЕСЛИ "СТАРШИЙ" ЭЛМЕНТ БОЛЬШЕ ПЕРЕХОДИМ В 'EXCHANGE'
    DEC    CX
    LOOP  CYCL_START    ; ИНЧЕ ПРОДОЛЖИТЬ ПРОХОД ПО МАССИВУ
    JMP   CYCL_CLOSE    ; ЕСЛИ ЦИКЛ ЗАКОНЧЕН НА ВЫХОД ИЗ ПРОЦЕДУРЫ
   EXCHANGE:            ;ПОМЕНЯТЬ ЭЛЕМЕНТЫ МЕСТАМИ ЕСЛИ УСЛОВИЕ ВЫПОЛНЕНО
    MOV    DX,MAS[BX]       ; ЗАПОМНИТЬ ТЕКУЩИЙ ЭЛЕМЕНТ      
    MOV    AX,MAS[BX-2]     ;ЗАПОМНИТЬ "МЛАДШИЙ ЭЛЕМЕНТ"
    MOV    MAS[BX],AX       ;ПОММЕНЯТЬ ЕГО МЕСТАМИ С "СТАРШИМ"
    MOV    MAS[BX-2],DX     ;-//-
    JMP    START_SORT
   CYCL_CLOSE:   
    
    XOR    DX,DX        ; НА ВСЯКИЙ ИЗБАВИТСЯ ОТ МУСОРА В 'DX'
    
    RET
 ARRAY_SORT_PROC ENDP
;-------------------------------------------------------------------------- 
 ;* НАЧАЛО ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ"
  OUTPUT_PROC PROC
    
    MOV      AX,OUTPT
    MOV      BX,AX      ; РАЗМЕЩЕНИЕ ЧИСЛА В РЕГИСТРЕ AX
    OR       BX,BX      ; *ЕСЛИ ЧИЛО ПОЛОЖИТЕЛЬНОЕ
    JNS     M1          ;  ПЕРЕЙТИ В M1.    
    MOV      AL,"-"     ;  ИНЧЕ РАЗМЕСТИТ В РЕЗУЛЬТАТЕ СИМВОЛ МИНУСА.
    INT      29H        ;  ВЫВЕСТИ МИНУС НА ЭКРАН*
    NEG      BX         ; ИЗМЕНИТЬ СТАРШИЙ БИТ ЧИСЛА("УБРАТЬ МИНУС")
   M1:                  ; ТОЧКА ПРЕХОДА ЕСЛИ ЧИСЛО ПОЗИТИВНОЕ
    MOV      AX,BX      ; ОБНОВИТЬ ЧИСЛО В РЕГИСТРЕ 'AX'(ИЗ-ЗА "NEG BX")
    XOR      CX,CX      ; ОБНУЛИТЬ РЕГИСТР СЧЕТЧИКА
    MOV      BX,10      ; ДЛЯ РАЗДЕЛЕНИЯ ЧИСЛА НА РАЗРЯДЫ
   M2:                  ; НАЧАЛО ЦИКЛА "РАЗМЕЩЕНИЕ ЧИСЛА В СТЕКЕ"
    XOR      DX,DX      ; ОБНУЛЕНИЕ 'DX'
    DIV      BX         ; ДЕЛЕНИЕ 'AX' НА 'BX'(ОТДЕЛЕНИЕ РАЗРЯДА)
    ADD      DL,"0"     ; DECIMAL TO ASCII
    PUSH     DX         ; РАЗМЕЩЕНИЕ РЕЗУЛЬТАТА В СТЕКЕ
    INC      CX         ; УВЕЛИЧЕНИЕ СЧЕТЧИКА
    TEST     AX,AX      ; *ЕСЛИ ЕЩЕ ОСТАЛИСЬ ЦИФРЫ В ЧИСЛЕ
    JNZ      M2         ;  ПОВТОРИТЬ "РАЗМЕЩЕНИЕ В СТЕКЕ"
   M3:                  ; НАЧАЛО ЦИКЛА ВЫВОДА ЧИСЛА ИЗ СТЕК НА ЭКРАН
    POP      AX         ; ДОСТАТЬ ВЕРХНЮЮ ЦИФРУ ИЗ СТЭКА
    INT      29H        ; ВЫВЕСТИ ЕЁ НА ЭКРАН
   LOOP     M3          ; ПОВТОРИТЬ 'M3' ПОКА СЧЕТЧИК НЕ '0'
    
    RET     ;ВОЗВРАЩАЕМ УПРАВЛЕНИЕ ВЫЗЫВАЮЩЕЙ ПРОЦЕДУРЕ  
   OUTPUT_PROC ENDP
  ;* КОНЕЦ ПРОЦЕДУРЫ "ВЫВОДА ДАННЫХ" 
;-------------------------------------------------------------------------- 
 KARETKA_JMP_PROC PROC 
    MOV     BX,AX               ; ЧТО БЫ НЕ ПОТЕРЯТЬ ЗНАЧЕНИЕ
    MOV     AL,0AH              ; ПЕРЕЙТИ НА СЛЕДУЩУЮ СТРОКУ
    INT     29H
    MOV     AX,BX               ; *ВЕРНУТЬ ЗНАЧЕНИЕ В 'AX'..
   
    RET
 KARETKA_JMP_PROC ENDP
;-------------------------------------------------------------------------- 
   INPUT_PROC PROC  
    MOV     SI,0
    MOV     CX,N
    
    START:
    MOV     AH,1H       ;ВВЕСТИ СИМВОЛ ИЗ КОНСОЛИ
    INT     21H
    SUB     AL,30H      ;ПРЕОБРАЗОВАТЬ ЕГО
    XOR     AH,AH       ;УБРАТЬ ИНСТРУКЦИЮ ИЗ ПОЛУРЕГИСТРА
    MOV     MAS[SI],AX  ;ЗАПИСАТЬ ВВЕДЕННОЕ В МАССИВ
    ADD     SI,2        ;ШАГ 2 ИЗ-ЗА DW   
    LOOP    START 
   
    RET
   INPUT_PROC ENDP
;-------------------------------------------------------------------------- 
INPUT_POISKOVIY PROC
    MOV     AH,01H              ; СЧИТАТЬ СИМВОЛ В РЕГИСТР 'AL'
    INT     21H
    SUB     AL,30H
    XOR     AH,AH               ; ПОЧИСТИТЬ 'AX' ОТ '01H'
    MOV     SRCH,AX             ; ЗАПОМНИТЬ ПОИСКОВЫЙ
    
    RET
INPUT_POISKOVIY ENDP
;--------------------------------------------------------------------------
FIND_COORDINATES PROC 
    MOV     I,0             ; НАЧАТЬ С ПЕРВОГО ЭЛЕМЕНТА
    MOV     J,0
    MOV     CX,16           ; 16 ЭЛЕМЕНТОВ В МАССИВЕ
    
   FORLOOP13:
    ; ПРЕОБРАЗОВАТЬ 'I' 
    MOV     BX,I
    MOV     AX,8            ; (4*2) 4 ДЛИНА РЯДКА, 2 ИЗ-ЗА DW 
    MUL     BX
    MOV     BX,AX
    ; ПРЕОБРАЗОВАТЬ 'J' 
    MOV     SI,J
    SHL     SI,1
    
    MOV     AX,MASCP[BX+SI]     ; ВЗЯТЬ ЭЛЕМЕНТ МАССИВА ПО АДРЕСУ
    MOV     BX,SRCH 
    CMP     J,4
    JNE    CONTINUE_LINE
    MOV     J,0
    ADD     I,1
   CONTINUE_LINE:
    CMP     AX,BX               ; СРАВНИТЬ С ПОИСКОВЫМ
    JNE    NOT_PRINT_COORD      ; ЕСЛИ НЕ СОВПАЛИ ПЕРЕПРЫГУНТЬ ВЫВОД КООРДИНАТЫ НА ЭКРАН
    
    MOV     TMP,CX              ; 'OUTPUT_PROC' ЗАТИРАЕТ 'CX'
    ;ВЫВОД КООРДИНАТЫ НА ЭКРАН
    CALL    KARETKA_JMP_PROC    ; ПЕРЕВЕСТИ КАРЕТКУ 
    WRT     MES8                ; "( "  
    MOV     AX,I                ; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'
    INC     AX                  ; НЕ ПРОГРАММИСТСТСТСКАЯ КООРДИНАТА
    MOV     OUTPT,AX            ; OUTPUT_PROC РАБОТАЕТ С OUTPT
    CALL    OUTPUT_PROC         ; ВЫВОДИТ ЦИФРУ
    WRT     MES9                ; " ; "
    MOV     AX,J                ; 'OUTPUT_PROC' РАБОТАЕТ С 'AX'
    INC     AX                  ; НЕ ПРОГРАММИСТСТСТСКАЯ КООРДИНАТА
    MOV     OUTPT,AX            ; OUTPUT_PROC РАБОТАЕТ С OUTPT
    CALL    OUTPUT_PROC         ; ВЫВОДИТ ЦИФРУ
    WRT     MES10               ; " )"
    ;*
    MOV     CX,TMP              ; ВОЗВРАЩАЕТСЯ СЧЕТЧИК   
    
   NOT_PRINT_COORD: 
    ADD     J,1
    LOOP        FORLOOP13
        
    RET
 FIND_COORDINATES ENDP
;--------------------------------------------------------------------------
 
 
CSEG ENDS   ; КОНЕЦ СЕГМЕНТА КОДА
END MAIN    ; ВЫХОД ИЗ ПРОГРАММЫ