;--------------------------
;  MENU PARA CALCULADORA
;--------------------------
INCLUDE LIBCALC.INC
.MODEL SMALL
.STACK 100h
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
    menuLength      db 5
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
    Resultado       db 0
    Numero1         db 0
    Numero2         db 0
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
    GOTOXY 30, 2
    PRINT_COLOR_MSG 15, MENUMSG
    GOTOXY 27, 7
    PRINT_COLOR_MSG 9, Bienvenida
    GOTOXY 28, 12
    PRINT_COLOR_MSG 9, F1MSG
    GOTOXY 28, 14
    PRINT_COLOR_MSG 9, F2MSG
    GOTOXY 28, 16
    PRINT_COLOR_MSG 9, F3MSG
    GOTOXY 28, 18
    PRINT_COLOR_MSG 9, F4MSG
    GOTOXY 64, 28
    PRINT_COLOR_MSG 12, F5MSG
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
    GOTOXY 30, 24
    PRINT_COLOR_MSG 4, Error
    JMP WAIT_FOR_INPUT
EXIT_MENU:
    PRINT_COLOR_MSG 7, Despedida
    JMP EXIT_CALC
SUMAR:
    CALL SUMAR_NUMEROS
    JMP EXIT_MENU
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
    SET_VIDEO_12H
    CALL LEER_NUMEROS
    POP DX CX AX
    RET
SUMAR_NUMEROS ENDP
;--------------------------------
;       RESTAR NUMEROS
;--------------------------------
RESTAR_NUMEROS PROC
    PUSH AX CX DX
    SET_VIDEO_12H
    CALL LEER_NUMEROS
    POP DX CX AX
    RET
RESTAR_NUMEROS ENDP
;--------------------------------
;       MULTIPLICAR NUMEROS
;--------------------------------
MULTIPLICAR_NUMEROS PROC
    PUSH AX CX DX
    SET_VIDEO_12H
    CALL LEER_NUMEROS
    POP DX CX AX
    RET
MULTIPLICAR_NUMEROS ENDP
;--------------------------------
;       DIVIDIR NUMEROS
;--------------------------------
DIVIDIR_NUMEROS PROC
    PUSH AX CX DX
    SET_VIDEO_12H
    CALL LEER_NUMEROS
    POP DX CX AX
    RET
DIVIDIR_NUMEROS ENDP
;--------------------------------
;       LEER NUMEROS
;--------------------------------
LEER_NUMEROS PROC
    PUSH AX CX DX
    CLC
    
    POP DX CX AX
    RET
LEER_NUMEROS ENDP

END Main
