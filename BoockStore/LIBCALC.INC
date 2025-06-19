Protocolo MACRO 
    mov ax, @data
    mov ds, ax
    mov es, ax
ENDM


DRAW_POINT MACRO color_point, x_point, y_point
    PUSH CX DX                          ;Dibuja un punto en la pantalla (En modo grafico)
        MOV AH,0CH                      ;Func 0C/Int 10h
        MOV AL,color_point              ;color 0-15
        MOV BH,0                        ;pagina (0 por default en esta aplicacion)
        MOV CX,x_point                  ;Columna
        MOV DX,y_point                  ;Fila
        INT 10H                         ;Interrupt 10h Video functions
    POP  DX CX
ENDM 

SET_VIDEO_12H MACRO
    push ax
    mov ah, 00h
    mov al, 12H
    int 10h
    pop ax
ENDM

GET_KEY MACRO Tecla
    LOCAL EXTENDED_KEY, END_GET_KEY
    PUSH AX
    MOV AH, 0
    INT 16H
    CMP AL, 0          ; Si AL = 0, es una tecla extendida (F1-F12, flechas, etc.)
    JE EXTENDED_KEY
    MOV Tecla, AL      ; Tecla normal (ESC, letras, n??meros)
    JMP END_GET_KEY
EXTENDED_KEY:
    MOV Tecla, AH      ; Tecla extendida, usar scan code de AH
END_GET_KEY:
    POP AX 
ENDM


PRINT_STRING MACRO row, col, msg, color
    push ax
    push bx
    push dx
    
    ; Posicionar cursor
    mov ah,02h
    mov bh,00h
    mov dh,row
    mov dl,col
    int 10h

    ; Configurar color y escribir
    mov ah,09h
    mov bl,color
    mov dx, OFFSET msg
    int 21h

    pop dx
    pop bx
    pop ax
ENDM
READ_CHAR MACRO char_var
    PUSH AX
    MOV AH, 01h         ; DOS function to read character with echo
    INT 21h             ; DOS interrupt
    MOV char_var, AL    ; Store character in variable
    POP AX
ENDM

READ_C MACRO
    PUSH AX
    MOV AH, 01
    INT 21H 
    POP AX
ENDM

LEER_CADENA_ENTER MACRO etiqueta_buffer, maximo
    LOCAL leer_loop, fin_lectura, validar_digito

    push ax
    push bx
    push cx
    push dx
    push si

    mov si, OFFSET etiqueta_buffer ; SI apunta al buffer
    xor cx, cx                     ; CX cuenta caracteres

leer_loop:
    mov ah, 01h
    int 21h                        ; Leer caracter en AL

    cmp al, 13                     
    je fin_lectura

validar_digito:
    cmp al, '0'                    ; Verificar si es menor que '0'
    jb leer_loop                   ; Si es menor, ignorar y seguir leyendo
    cmp al, '9'                    ; Verificar si es mayor que '9'
    ja leer_loop                   ; Si es mayor, ignorar y seguir leyendo

    mov [si], al                  ; Guardar AL en [SI]
    inc si
    inc cx
    cmp cx, maximo
    jb leer_loop                  ; Si aún no alcanza el máximo, repetir

fin_lectura:
    mov byte ptr [si], '$'        ; Terminar cadena con '$'

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
ENDM

GET_STRING_LENGTH MACRO
    LOCAL LOOP_LENGTH, END_LENGTH
    PUSH SI
    MOV AL, 0           ; Contador de longitud
LOOP_LENGTH:
    CMP BYTE PTR [SI], 0    ; Verificar si es fin de cadena
    JE END_LENGTH
    CMP BYTE PTR [SI], '$'  ; Verificar si es terminador DOS
    JE END_LENGTH
    INC SI              
    INC AL              
    JMP LOOP_LENGTH
END_LENGTH:
    POP SI              
ENDM

PAD_LEFT_ZEROS MACRO buffer, currentLength, targetLength
    LOCAL MoverCaracteres, RellenarCeros, FinPadding
    PUSH SI
    PUSH DI
    PUSH AX
    PUSH BX
    PUSH CX
    
    ; Calcular cuántos ceros agregar
    XOR CH, CH              ; Limpiar CH para usar CX como contador
    MOV CL, targetLength    ; Cargar longitud objetivo
    SUB CL, currentLength   ; Restar longitud actual
    
    ; Si no hay que agregar ceros, salir
    CMP CL, 0
    JLE FinPadding
    
    ; Guardar número de ceros a agregar
    MOV BL, CL              ; Guardar en BL el número de ceros
    
    ; Calcular la posición del final de la cadena
    MOV SI, OFFSET buffer
    XOR AH, AH
    MOV AL, currentLength   ; Cargar la longitud actual en AL
    ADD SI, AX              ; SI apunta al final de la cadena
    
    MOV DI, SI
    XOR CH, CH
    MOV CL, BL              ; Recuperar número de ceros
    ADD DI, CX              ; DI apunta a donde terminará la cadena
    
    ; Mover caracteres de derecha a izquierda
    XOR CH, CH
    MOV CL, currentLength   ; Cargar el número de caracteres a mover
MoverCaracteres:
    DEC SI
    DEC DI
    MOV AL, [SI]
    MOV [DI], AL
    LOOP MoverCaracteres
    
    ; Rellenar con ceros al inicio
    MOV DI, OFFSET buffer
    XOR CH, CH
    MOV CL, BL              ; Recuperar número de ceros
RellenarCeros:
    MOV BYTE PTR [DI], '0'
    INC DI
    LOOP RellenarCeros
    
    ; Asegurarse de que la cadena esté terminada con $
    MOV SI, OFFSET buffer
    XOR AH, AH
    MOV AL, targetLength    ; Ahora usamos la longitud objetivo
    ADD SI, AX              ; SI apunta al final de la cadena después del padding
    MOV BYTE PTR [SI], '$'  ; Añadir terminador de cadena
    
FinPadding:
    POP CX
    POP BX
    POP AX
    POP DI
    POP SI
ENDM

BCD_SUM_STRINGS MACRO num1, num2, result
    LOCAL SUM_len, SUM_setup, SUM_sum, SUM_carry
    LOCAL SUM_trim, SUM_next, SUM_shift, SUM_done
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    lea SI, num1
    xor BP, BP
SUM_len:
    cmp byte ptr [SI], '$'
    je SUM_setup
    inc BP
    inc SI
    jmp SUM_len

SUM_setup:
    lea BX, result
    mov AX, BP
    add BX, AX
    mov byte ptr [BX], '$'

    lea SI, num1
    add SI, BP
    dec SI             
    lea DI, num2
    add DI, BP
    dec DI             

    lea BX, result
    add BX, AX
    dec BX             

    mov CX, BP         
    xor DX, DX         

SUM_sum:
    cmp CX, 0
    je SUM_carry

    mov AL, [SI]
    sub AL, '0'
    mov AH, [DI]
    sub AH, '0'

    add AL, AH
    add AL, DL

    mov AH, 0
    AAA
    mov DL, AH         ; DL = nuevo carry

    add AL, '0'
    mov [BX], AL

    dec SI
    dec DI
    dec BX
    dec CX
    jmp SUM_sum

SUM_carry:
    cmp DL, 0
    je SUM_trim

    add DL, '0'
    mov [BX], DL
   
SUM_trim:
    ; Eliminar ceros a la izquierda
    lea SI, result
SUM_next:
    cmp byte ptr [SI], '0'
    jne SUM_done          ; si no es '0', salta
    cmp byte ptr [SI+1], '$'
    je SUM_done          

    mov DI, SI
SUM_shift:
    mov AL, [DI+1]
    mov [DI], AL
    inc DI
    cmp AL, '$'
    jne SUM_shift
    jmp SUM_next

SUM_done:
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
ENDM


BCD_SBB_STRINGS MACRO Num1, Num2, Resultado
    LOCAL lenr, reps, res_loop
    PUSH AX BX CX DX SI DI

    MOV SI, OFFSET Num1
    XOR CX, CX
lenr:
    CMP BYTE PTR [SI], '$'
    JE reps
    INC SI
    INC CX
    JMP lenr

reps:
    MOV SI, OFFSET Num1
    MOV DI, OFFSET Num2
    MOV BX, OFFSET Resultado
    ADD SI, CX
    DEC SI
    ADD DI, CX
    DEC DI

    MOV AX, CX
    ADD BX, AX
    MOV BYTE PTR [BX], '$'

    DEC BX
    CLC                     ; clear borrow

res_loop:
    MOV AL, [SI]
    SUB AL, '0'
    MOV AH, [DI]
    SUB AH, '0'

    SBB AL, AH
    AAS
    ADD AL, '0'
    MOV [BX], AL

    DEC SI
    DEC DI
    DEC BX
    LOOP res_loop

    POP DI SI DX CX BX AX
ENDM

LEER_5_DIGITOS MACRO buffer
    PUSH AX BX CX DX SI
    LEA   SI, buffer  
    MOV   CX, 5
_L5:
    MOV   AH,01h
    INT   21h
    CMP   AL,'0'
    JB    _L5
    CMP   AL,'9'
    JA    _L5
    MOV   [SI], AL
    INC   SI
    LOOP  _L5
_F5:
    MOV   BYTE PTR [SI],'$'
    POP   SI DX CX BX AX
ENDM


LEER_1_DIGITO MACRO buffer
    PUSH AX BX
    LEA SI, buffer
._R1:
    MOV   AH,01h
    INT   21h
    CMP   AL,'0'
    JB    ._R1
    CMP   AL,'9'
    JA    ._R1
    MOV   [SI], AL
    INC SI
    MOV   BYTE PTR [SI],'$'
    POP   BX AX
ENDM


BCD_DIV_STRINGS MACRO Dividendo, Divisor, Resultado, Residuo 
    LOCAL NEXT_DIGIT, DONE, ADD_DECIMAL, DECIMAL_LOOP
    PUSH AX BX CX DX SI DI
    
    ; Convertir divisor de ASCII a binario
    MOV BL, Divisor
    SUB BL, '0'        
    
    ; Inicializar punteros
    LEA SI, Dividendo
    LEA DI, Resultado
    XOR DX, DX         
    
NEXT_DIGIT:
    MOV AL, [SI]       
    CMP AL, '$'        
    JE ADD_DECIMAL
    
    SUB AL, '0'        ; Convertir ASCII a número
    MOV AH, DL         ; AH = resto anterior
    AAD                ; AL = AH*10 + AL
    DIV BL             
    MOV DL, AH         
    ADD AL, '0'       
    
    MOV [DI], AL       
    INC SI            
    INC DI             
    JMP NEXT_DIGIT

ADD_DECIMAL:
    ; Añadir punto decimal
    MOV BYTE PTR [DI], '.'
    INC DI
    
    ; Calcular 2 decimales
    MOV CX, 2          ; Contar para 2 decimales
    
DECIMAL_LOOP:
    MOV AL, 0          ; AL = 0 para multiplicar resto por 10
    MOV AH, DL         ; AH = resto actual
    AAD                ; AL = AH*10 + AL = resto*10
    DIV BL             
    MOV DL, AH         
    ADD AL, '0'        
    
    MOV [DI], AL       
    INC DI
    LOOP DECIMAL_LOOP
    
DONE:
    MOV BYTE PTR [DI], '$'  ; Terminar cadena resultado
    
    ; Guardar residuo final en string Residuo
    LEA DI, Residuo
    MOV AL, DL
    ADD AL, '0'
    MOV [DI], AL
    MOV BYTE PTR [DI+1], '$'
    
    POP DI SI DX CX BX AX
ENDM


LIMPIAR_BUFFER MACRO buffer, count
LOCAL _bcl, _end
    PUSH CX SI
    LEA SI, buffer
    MOV   CX, count
_bcl:
    MOV   BYTE PTR [SI], 0
    INC   SI
    LOOP  _bcl
    MOV   BYTE PTR [SI], '$'
    POP   SI CX
ENDM

LEER_4_DIGITOS MACRO buffer
    PUSH AX BX CX DX SI
    LEA   SI, buffer  
    MOV   CX, 4
_L4:
    MOV   AH,01h
    INT   21h
    CMP   AL,'0'
    JB    _L4
    CMP   AL,'9'
    JA    _L4
    MOV   [SI], AL
    INC   SI
    LOOP  _L4
_F4:
    MOV   BYTE PTR [SI],'$'
    POP   SI DX CX BX AX
ENDM 


LEER_2_DIGITOS MACRO buffer
    PUSH AX BX CX DX SI
    LEA   SI, buffer  
    MOV   CX, 2
_L2:
    MOV   AH,01h
    INT   21h
    CMP   AL,'0'
    JB    _L2
    CMP   AL,'9'
    JA    _L2
    MOV   [SI], AL
    INC   SI
    LOOP  _L2
_F2:
    MOV   BYTE PTR [SI],'$'
    POP   SI DX CX BX AX
ENDM
