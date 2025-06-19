;--------------------------
;  Calculadora.asm
;--------------------------
INCLUDE LIBCALC.INC
.MODEL SMALL
.STACK 180h
.DATA
;---------------------------------
;  Mensaje de bienvenida y menu
;          de opciones
;--------------------------------
    Bienvenida      db 'Bienvenido a la Calculadora$'
    MENUMSG         db 'Menu de Opciones$'
    F1MSG           db 'F1 Sumar$'
    F2MSG           db 'F2 Restar$'
    F3MSG           db 'F3 Multiplicar$'
    F4MSG           db 'F4 Dividir$'
    F5MSG           db 'F5 Salir$'
    MSGOPCION       db 'Seleccione la opcion:$'
    PosicionX       dW 0
    PosicionY       dW 0
    PosicionX2      dW 0
    PosicionY2      dW 0
;---------------------------------
;        Mensaje de error
;---------------------------------
    Error           db 'Error: Opcion no valida$'
    ErrorLength     equ $ - Error
;---------------------------------
;      Mensaje de despedida
;---------------------------------
    Despedida       db 'Gracias por usar la Calculadora$'
    DespedidaLength equ $ - Despedida
;---------------------------------
;    Variables para almacenar
;       los resultados
;---------------------------------
    MSGNUMERO1      db 'Ingrese el primer numero: $'
    MSGNUMERO2      db 'Ingrese el segundo numero: $'
    MSGRESULTADO    db 'El resultado es: $'
    MSGDIVISION     db 'Division por cero no permitida$'
    MSGREPETIR      db 'Desea repetir la operacion? (S/N): $'
    MSGSUMAN        db 'Suma de numeros$'
    MSGRESTAN       db 'Resta de numeros$'
    MSGMULTIPLICAN  db 'Multiplicacion de numeros$'
    MSGDIVIDEN      db 'Division de numeros$'
    MSGMAXDIVDEN    db 'El numero maximo de digitos para el dividendo es de 5$'
    MSGMXDVISOR     db 'El numero maximo de digitos para el divisor es 1$'
;---------------------------------
    Resultado       db 13 DUP(0)
    Numero1         db 11 DUP(0)
    Numero2         db 11 DUP(0)
    NumeroDivisor   db 2 DUP(0)
    NumeroDividendo db 8 DUP(0)
    Resultadodiv    db 6 DUP(0)
    NumeroMultiplicacion    db 4 DUP(0), '$'
    NumeroMultiplicado      db 2 DUP(0), '$'
    Residuo         db 2 DUP(0), '$'
    Lengthd         dw 0 
    DigitN1         db 0
    DigitN2         db 0
    partial_product DB 10 DUP(0), '$'  ; Buffer para producto parcial
    temp_result     DB 10 DUP(0), '$' 
;---------------------------------
;    Variables para el menu
    Opcion          db 0
    Tecla           db 0
;---------------------------------
.CODE
;---------------------------------
;     Inicio del programa
;---------------------------------
Main PROC FAR
    ; Inicializar segmento de datos
   Protocolo
   CALL MENU_CALCULADORA
   
    ret 
Main ENDP
;---------------------------------
;     Rutina del menu
;---------------------------------
MENU_CALCULADORA PROC
    SET_VIDEO_12H
    MOV PosicionY2, 70
    MOV PosicionX2, 640
START_MENU:

    CALL PAINT_RECT
    PRINT_STRING 2, 30, MENUMSG, 15
    PRINT_STRING 7, 27, Bienvenida, 9
    PRINT_STRING 10, 28, MSGOPCION, 12
    PRINT_STRING 12, 28 , F1MSG, 9
    PRINT_STRING 14, 28 , F2MSG, 9
    PRINT_STRING 16, 28 , F3MSG, 9
    PRINT_STRING 18, 28 , F4MSG, 9
    PRINT_STRING 28, 64, F5MSG, 12

WAIT_FOR_INPUT:

    GET_KEY Tecla
    CMP Tecla, 27 ; ESC
    JE EXIT_MENU
    CMP Tecla, 59 ; F1
    JE SUMAR
    CMP Tecla, 60 ; F2
    JE RESTAR
    CMP Tecla, 61 ; F3
    JE MULTIPLICAR
    CMP Tecla, 62 ; F4
    JE DIVIDIR
    CMP Tecla, 63 ; F5
    JE EXIT_MENU

INCORRECT_OPTION:

    PRINT_STRING 24, 30, Error, 4
    JMP WAIT_FOR_INPUT

EXIT_MENU:

    SET_VIDEO_12H
    PRINT_STRING 14, 24, Despedida, 5
    JMP EXIT_CALC

SUMAR:

    CALL SUMAR_NUMEROS
    JMP START_MENU

RESTAR:

    CALL RESTAR_NUMEROS
    JMP EXIT_MENU

MULTIPLICAR:

    CALL MULTIPLICAR_NUMEROS
    JMP EXIT_MENU

DIVIDIR:

    CALL DIVIDIR_NUMEROS
    JMP EXIT_MENU
    
EXIT_CALC:
    
    mov ah,04ch
    int 21h
    
    RET
MENU_CALCULADORA ENDP

;--------------------------------
;       DIBUJAR RECTANGULO
;--------------------------------
PAINT_RECT PROC
    PUSH AX DX BX
    MOV PosicionY, 0
    MOV CX, PosicionY2 

LINEREP:

    MOV CX, PosicionX2
    MOV PosicionX, 0

LINEX:

    DRAW_POINT 7, PosicionX, PosicionY
    INC PosicionX
    LOOP LINEX

REPL:

    INC PosicionY
    DEC PosicionY2
    MOV CX,PosicionY2
    LOOP LINEREP

EXIT:
    POP BX DX AX 
    RET 
PAINT_RECT ENDP
;--------------------------------
;       SUMAR NUMEROS
;--------------------------------
SUMAR_NUMEROS PROC
    PUSH AX CX DX
REPETIR_SUMA:

    SET_VIDEO_12H
    PRINT_STRING 2, 32,MSGSUMAN , 15
    PRINT_STRING 28, 64 , F5MSG, 12

LECTURA_SUMA:

    PRINT_STRING 14, 23, MSGNUMERO1, 9
    LEER_CADENA_ENTER Numero1, 11
    PRINT_STRING 15, 23, MSGNUMERO2, 9
    LEER_CADENA_ENTER Numero2, 11

SUMA_RESULTADO:
    ; Obtener longitudes de las cadenas
    LEA SI, Numero1
    GET_STRING_LENGTH
    MOV DigitN1, AL          
    
    LEA SI, Numero2
    GET_STRING_LENGTH
    MOV DigitN2, AL

CMP_LENGTH:
    ; Comparar longitudes
    MOV AL, DigitN1
    CMP AL, DigitN2
    JG LONGER_NUM1
    JL LONGER_NUM2   
    JMP SUMA_DIGITO

LONGER_NUM1:
    
    PAD_LEFT_ZEROS Numero2, DigitN2, DigitN1
    JMP SUMA_DIGITO

LONGER_NUM2:
   
    PAD_LEFT_ZEROS Numero1, DigitN1, DigitN2
    JMP SUMA_DIGITO

SUMA_DIGITO:
  
    BCD_SUM_STRINGS Numero1, Numero2, Resultado
    
    ; Mostrar resultado
    PRINT_STRING 21, 16, MSGRESULTADO, 9
    PRINT_STRING 21, 40, Resultado, 10
    
    ; Preguntar si desea repetir
    PRINT_STRING 23, 16, MSGREPETIR, 9
    JMP WAIT_REPEAT

WAIT_REPEAT:

    GET_KEY Tecla
    CMP Tecla, 83      
    JNE CHECK_LOWERCASE_S
    JMP REPETIR_SUMA   
    
CHECK_LOWERCASE_S:

    CMP Tecla, 115      
    JNE CHECK_N
    JMP REPETIR_SUMA    
    
CHECK_N:

    CMP Tecla, 78      
    JE SALIR_SUMA
    CMP Tecla, 110      
    JE SALIR_SUMA
    CMP Tecla, 63 
    JE SALIR_SUMA    ; F5 - Salir
    JMP WAIT_REPEAT  

SALIR_SUMA:
    CALL MENU_CALCULADORA 
    POP DX CX AX
    RET
SUMAR_NUMEROS ENDP
;--------------------------------
;       RESTAR NUMEROS
;--------------------------------
RESTAR_NUMEROS PROC
    PUSH AX CX DX
REPETIR_RESTA:
    SET_VIDEO_12H
    PRINT_STRING 2, 32, MSGRESTAN, 15
    PRINT_STRING 28, 64 , F5MSG, 12

LECTURA_RESTA:
    PRINT_STRING 14, 23, MSGNUMERO1, 9
    LEER_CADENA_ENTER Numero1, 11
    PRINT_STRING 15, 23, MSGNUMERO2, 9
    LEER_CADENA_ENTER Numero2, 11

RESTAR_RESULTADO:
    ;Calculamos las longitudes de las cadenas 
    LEA SI, Numero1
    GET_STRING_LENGTH
    MOV DigitN1, AL
    LEA SI, Numero2
    GET_STRING_LENGTH
    MOV DigitN2, AL

CMP_LENGTH_RESTA:
    ; Comparar longitudes
    MOV AL, DigitN1
    CMP AL, DigitN2
    JG LONGER_NUM1_RESTA
    JL LONGER_NUM2_RESTA
    JMP RESTA_DIGITO

LONGER_NUM1_RESTA:

    PAD_LEFT_ZEROS Numero2, DigitN2, DigitN1
    JMP RESTA_DIGITO

LONGER_NUM2_RESTA:

    PAD_LEFT_ZEROS Numero1, DigitN1, DigitN2
    JMP RESTA_DIGITO
RESTA_DIGITO:

    BCD_SBB_STRINGS Numero1, Numero2, Resultado
    PRINT_STRING 21, 16, MSGRESULTADO, 9
    PRINT_STRING 21, 40, Resultado, 10
    
    ; Preguntar si desea repetir
    PRINT_STRING 23, 16, MSGREPETIR, 9
    JMP WAIT_REPEAT_RESTA

WAIT_REPEAT_RESTA:

    GET_KEY Tecla
    CMP Tecla, 83
    JNE CHECK_LOWERCASE_R
    JMP REPETIR_RESTA

CHECK_LOWERCASE_R:

    CMP Tecla, 115
    JNE CHECK_N_RESTA
    JMP REPETIR_RESTA

CHECK_N_RESTA:

    CMP Tecla, 78
    JE SALIR_RESTA
    CMP Tecla, 110
    JE SALIR_RESTA
    CMP Tecla, 63
    JE SALIR_RESTA    ; F5 - Salir
    JMP WAIT_REPEAT_RESTA

SALIR_RESTA:

    CALL MENU_CALCULADORA
    POP DX CX AX
    RET
RESTAR_NUMEROS ENDP
;--------------------------------
;       MULTIPLICAR NUMEROS
;--------------------------------
MULTIPLICAR_NUMEROS PROC
    PUSH AX CX DX
REPETIR_MULTIPLICACION:
    LIMPIAR_BUFFER Resultado, 13    
    SET_VIDEO_12H
    PRINT_STRING 2, 29, MSGMULTIPLICAN, 15
    PRINT_STRING 28, 64, F5MSG, 12
LECTURA_MULTIPLICACION:
    
    PRINT_STRING 14, 23, MSGNUMERO1, 9
    LEER_4_DIGITOS NumeroMultiplicacion
    PRINT_STRING 15, 23, MSGNUMERO2, 9
    LEER_2_DIGITOS NumeroMultiplicado
    
MULTIPLICACION_DIGITO:
    ; Preparar parametros para BCD_MUL_PROC
    LEA SI, NumeroMultiplicacion
    LEA DI, NumeroMultiplicado
    LEA BX, Resultado
    
    
    CALL BCD_MUL_PROC
    
    PRINT_STRING 21, 16, MSGRESULTADO, 9
    PRINT_STRING 21, 40, Resultado, 10
    
    PRINT_STRING 23, 16, MSGREPETIR, 9
    JMP WAIT_REPEAT_MULTIPLICACION

WAIT_REPEAT_MULTIPLICACION:
    
    GET_KEY Tecla
    CMP Tecla, 83
    JNE CHECK_LOWERCASE_M
    JMP REPETIR_MULTIPLICACION
    
CHECK_LOWERCASE_M:
    
    CMP Tecla, 115
    JNE CHECK_N_MULTIPLICACION
    JMP REPETIR_MULTIPLICACION
    
CHECK_N_MULTIPLICACION:
    
    CMP Tecla, 78
    JE SALIR_MULTIPLICACION
    CMP Tecla, 110
    JE SALIR_MULTIPLICACION
    CMP Tecla, 63
    JE SALIR_MULTIPLICACION    ; F5 - Salir
    JMP WAIT_REPEAT_MULTIPLICACION

SALIR_MULTIPLICACION:

    CALL MENU_CALCULADORA
    POP DX CX AX
    RET
MULTIPLICAR_NUMEROS ENDP
;--------------------------------
;       DIVIDIR NUMEROS
;--------------------------------
DIVIDIR_NUMEROS PROC
    PUSH AX CX DX
REPETIR_DIVISION:
    
    LIMPIAR_BUFFER Resultadodiv, 5    ; borra el buffer y pone '$'
    SET_VIDEO_12H
    PRINT_STRING 2, 32, MSGDIVIDEN, 15
    PRINT_STRING 28, 64, F5MSG, 12
    
LECTURA_DIVISION:
    
    PRINT_STRING 14,23, MSGNUMERO1, 9
    LEER_5_DIGITOS   NumeroDividendo
    PRINT_STRING 15,23, MSGNUMERO2, 9
    
LEER_DIVISOR:
    
    LEER_1_DIGITO NumeroDivisor
    ; Verificar si el divisor es cero
    MOV AL, NumeroDivisor[0]
    CMP AL, '0'
    JE DIVISION_CERO
    JMP REALIZAR_DIVISION
    
DIVISION_CERO:
    
    PRINT_STRING 17, 23, MSGDIVISION, 4
    JMP REPETIR_KEY
    
REALIZAR_DIVISION:
    
    BCD_DIV_STRINGS  NumeroDividendo, NumeroDivisor, Resultadodiv, Residuo
    
    PRINT_STRING 21,16, MSGRESULTADO,9
    PRINT_STRING 21,40, Resultadodiv,10
    
REPETIR_KEY:  
    
    PRINT_STRING 23, 16, MSGREPETIR, 9
    JMP WAIT_REPEAT_DIVISION
    
WAIT_REPEAT_DIVISION:
    
    GET_KEY Tecla
    CMP Tecla, 83
    JNE CHECK_LOWERCASE_D
    JMP REPETIR_DIVISION
    
CHECK_LOWERCASE_D:
    
    CMP Tecla, 115
    JNE CHECK_N_DIVISION
    JMP REPETIR_DIVISION
    
CHECK_N_DIVISION:
    
    CMP Tecla, 78
    JE SALIR_DIVISION
    CMP Tecla, 110
    JE SALIR_DIVISION
    CMP Tecla, 63
    JE SALIR_DIVISION    ; F5 - Salir
    JMP WAIT_REPEAT_DIVISION
    
SALIR_DIVISION:
    
    CALL MENU_CALCULADORA
    POP DX CX AX
    RET
DIVIDIR_NUMEROS ENDP
;--------------------------------
BCD_MUL_PROC PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP
    
    MOV CX, 6
    MOV AL, '0'
CLEAR_RESULT:
    MOV [BX], AL
    INC BX
    LOOP CLEAR_RESULT
    MOV BYTE PTR [BX], '$'
    SUB BX, 6          
    
    MOV AL, [DI+1]     ; Obtener digito de unidades (digito de la derecha)
    AND AL, 0FH        ; Convertir de ASCII a BCD
    CMP AL, 0
    JE MULT_TENS_DIGIT
    
    MOV DL, AL         ; Guardar multiplicador en DL
    MOV CX, 4          
    
MULT_ONES_LOOP:
    ; Obtener digito del multiplicando (de derecha a izquierda)
    PUSH SI
    PUSH CX
    ADD SI, 4          ; Ir al final del multiplicando
    SUB SI, CX         ; Retroceder CX posiciones
    MOV AL, [SI]       ; Obtener digito actual
    POP CX
    POP SI
    
    AND AL, 0FH        ; Convertir de ASCII a BCD
    
    MUL DL             
    AAM                
    

    PUSH BX
    ADD BX, 6          ; Ir al final del buffer
    SUB BX, CX         ; Retroceder CX posiciones
    
    ; Sumar unidades al resultado
    MOV DH, [BX]       ; Obtener valor actual
    SUB DH, '0'        ; Convertir a BCD
    ADD AL, DH         ; Sumar al resultado de la multiplicaci??n
    
    ; Manejar acarreo en unidades
    CMP AL, 9
    JLE NO_CARRY_ONES
    SUB AL, 10         ; Restar 10 para obtener el d??gito
    ADD AH, 1          ; Incrementar decenas (acarreo)
    
NO_CARRY_ONES:
    ADD AL, '0'        ; Convertir a ASCII
    MOV [BX], AL       ; Guardar en resultado
    
    ; Procesar decenas si existen
    CMP AH, 0
    JE CONTINUE_ONES
    
    ; Sumar decenas al resultado
    DEC BX             ; Mover a posici??n de decenas
    MOV DH, [BX]       ; Obtener valor actual
    SUB DH, '0'        ; Convertir a BCD
    ADD AH, DH         ; Sumar decenas
    
    ; Manejar acarreo en decenas
    CMP AH, 9
    JLE NO_CARRY_TENS
    SUB AH, 10         ; Ajustar decenas
    
    ; Propagar acarreo a la siguiente posici??n
    DEC BX
    MOV DH, [BX]
    SUB DH, '0'
    INC DH
    ADD DH, '0'
    MOV [BX], DH
    INC BX             ; Regresar a posici??n de decenas
    
NO_CARRY_TENS:
    ADD AH, '0'        ; Convertir a ASCII
    MOV [BX], AH       ; Guardar decenas
    
CONTINUE_ONES:
    POP BX
    LOOP MULT_ONES_LOOP
    
MULT_TENS_DIGIT:
    ; Multiplicar por el d??gito de las decenas del multiplicador
    MOV AL, [DI]       ; Obtener d??gito de decenas (d??gito de la izquierda)
    AND AL, 0FH        ; Convertir de ASCII a BCD
    CMP AL, 0
    JE MULT_DONE
    
    MOV DL, AL         ; Guardar multiplicador en DL
    MOV CX, 4          ; Procesar los 4 d??gitos del multiplicando
    
MULT_TENS_LOOP:
    ; Obtener d??gito del multiplicando (de derecha a izquierda)
    PUSH SI
    PUSH CX
    ADD SI, 4          ; Ir al final del multiplicando
    SUB SI, CX         ; Retroceder CX posiciones
    MOV AL, [SI]       ; Obtener d??gito actual
    POP CX
    POP SI
    
    AND AL, 0FH        ; Convertir de ASCII a BCD
    
    MUL DL             ; Multiplicar: AL = AL * DL
    AAM                ; Ajustar para BCD: AH = decenas, AL = unidades
    
    ; Calcular posici??n en resultado (desplazado una posici??n a la izquierda)
    PUSH BX
    ADD BX, 5          ; Posici??n para multiplicaci??n por decenas
    SUB BX, CX         ; Retroceder CX posiciones
    
    ; Sumar unidades al resultado
    MOV DH, [BX]       ; Obtener valor actual
    SUB DH, '0'        ; Convertir a BCD
    ADD AL, DH         ; Sumar al resultado
    
    ; Manejar acarreo en unidades
    CMP AL, 9
    JLE NO_CARRY_TENS_ONES
    SUB AL, 10         ; Ajustar unidades
    ADD AH, 1          ; Incrementar decenas
    
NO_CARRY_TENS_ONES:
    ADD AL, '0'        ; Convertir a ASCII
    MOV [BX], AL       ; Guardar unidades
    
    ; Procesar decenas si existen
    CMP AH, 0
    JE CONTINUE_TENS_ONES
    
    ; Sumar decenas al resultado
    DEC BX             ; Mover a posici??n de decenas
    MOV DH, [BX]       ; Obtener valor actual
    SUB DH, '0'        ; Convertir a BCD
    ADD AH, DH         ; Sumar decenas
    
    ; Manejar acarreo en decenas
    CMP AH, 9
    JLE NO_CARRY_TENS_TENS
    SUB AH, 10         ; Ajustar decenas
    
    ; Propagar acarreo
    DEC BX
    MOV DH, [BX]
    SUB DH, '0'
    INC DH
    ADD DH, '0'
    MOV [BX], DH
    INC BX             ; Regresar a posici??n de decenas
    
NO_CARRY_TENS_TENS:
    ADD AH, '0'        ; Convertir a ASCII
    MOV [BX], AH       ; Guardar decenas
    
CONTINUE_TENS_ONES:
    POP BX
    LOOP MULT_TENS_LOOP
    
MULT_DONE:
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
BCD_MUL_PROC ENDP
;--------------------------------
END Main