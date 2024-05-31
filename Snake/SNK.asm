TITLE SNAKE JUEGO DEL SNAKE 
.MODEL SMALL
.STACK 100H
.DATA
    BORDE DB 01110111B ; CIAN FONDO CHAR MAGENTA
    FONDO DB 00000000B ; CAFE EL AREA DE JUEGO
    SNAKE_COLOR DB 00100010B ;COLOR DE SNAKE
    
    SNAKE_COL DB 20 DUP(40)
    SNAKE_REN DB 22,19 DUP(11)
    SNAKE_CHAR DB 'S'
    SNAKE_LARGO DW 5
    INC_COL DB 0
    INC_REN DB -1
    DIRECCION_SNAKE DB 1 ;1 UP, 2 DOWN, 3 LEFT, 4 RIGHT
    
    ; Colocar en el centro del campo de juego
    CENTRO_COL DB 40
    CENTRO_REN DB 11
    
    MANZANA_COLOR DB 01000100B ; COLOR DE LA MANZANA
    MANZANA_CHAR DB 'M'
    MANZANA_REN DB 10
    MANZANA_COL DB 10
    
    SCORE_COLOR DB 01110000B
    SCORE_TEXTO DB 'SCORE:$'
    SCORE DB 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; CAMBIAR EL MODO DE VIDEO
    MOV AH,0
    MOV AL,3
    INT 10H
    
    ; PONER PAGINA ACTIVA LA 0
    MOV AH,5
    MOV AL,0
    INT 10H
    
    CALL HACER_FIELD
    
    ; Establecer posici?n inicial de la serpiente en el centro
    MOV SI, 0 ; Indice de la serpiente
    MOV AL, CENTRO_COL
    MOV SNAKE_COL[SI], AL
    MOV AL, CENTRO_REN
    MOV SNAKE_REN[SI], AL
    
    ; GENERAR Y MOSTRAR LAS MANZANAS
    CALL MANZANAS
    CALL IMPRIMIR_SCORE
    
    MOV CX,500
    
CICLO_PRINCIPAL:
    
    CALL DESPLIEGA_SNAKE
    CALL ESPERA
    CALL BORRA_SNAKE
    MOV AH,11H ;VERIFICAR CHAR
    INT 16H
    JZ NEXT ;NO HAY CHAR
    
SI_HAY_CHAR:
    MOV AH,10H
    INT 16H ;LEER CHAR
    CALL CAMBIA_DIRECCION

NEXT:
    CALL AVANZA_SNAKE
    LOOP CICLO_PRINCIPAL
    
    ; ESPERANDO CHAR
    MOV AH,1
    INT 21H

    
TERMINAR:
    CALL GAME_OVER
    MOV AH, 4CH
    INT 21H
MAIN ENDP
 
HACER_FIELD PROC
    PUSH CX
    ; HACER EL BORDE EXTERIOR, LIMPIANDO LA PANTALLA
    
    MOV AH, 6
    MOV AL, 25 
    MOV CX, 0000H ; RENGLON CERO , COL 0
    MOV DX, 184FH ; RENGOL 18H, COL 4EH
    MOV BH, BORDE
    INT 10H 
    
    MOV AH,7
    MOV AL,0
    MOV CX,0101H
    MOV DX,174EH
    MOV BH,FONDO
    INT 10H
    POP CX
    
    RET
    
HACER_FIELD ENDP
DESPLIEGA_SNAKE PROC
    PUSH CX
    MOV CX, SNAKE_LARGO
    XOR SI, SI
    
MUESTRA_SNAKE:
    ; CAMBIAR A POSICION DE COL Y REN DE LA SNAKE
    MOV AH,2
    MOV DL,SNAKE_COL[SI]
    MOV DH,SNAKE_REN[SI]
    MOV BH,0
    INT 10H
    
    
    ; LEER SI HAY MANZANA
    MOV AH, 8
    MOV BH, 0
    INT 10H
    
    CMP AL, 4DH
    JE MZN
    JMP CONTINUA
MZN:
    CALL INCREMENTAR_SNAKE
    CALL MANZANAS
    ; CAMBIAR A POSICION DE COL Y REN DE LA SNAKE
    MOV AH,2
    MOV DL,SNAKE_COL[SI]
    MOV DH,SNAKE_REN[SI]
    MOV BH,0
    INT 10H
    CMP SCORE, 5
    JE YA
    JMP CONTINUA
YA:
    CALL GAME_OVER
    
CONTINUA:
    ; VALIDAR SI CHOCA
    ;CALL REVISAR_BORDE
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, SNAKE_CHAR
    MOV BH,0
    MOV BL,SNAKE_COLOR ;FONDO
    PUSH CX
    MOV CX,1
    INT 10H
    
    POP CX
    INC SI
    LOOP MUESTRA_SNAKE

    POP CX
    RET
 
DESPLIEGA_SNAKE ENDP
 
ESPERA PROC
    PUSH CX
    MOV CX, 0EEEEH
    
CICLO_ESPERA:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LOOP CICLO_ESPERA
    
    POP CX
    RET
    
ESPERA ENDP
 
AVANZA_SNAKE PROC
    PUSH CX
    MOV CX, SNAKE_LARGO
    MOV SI, SNAKE_LARGO
    DEC SI
    DEC CX
    DEC SI
    ;COPIAR TODOS LOS CHARS ANTERIORES DE LA SNAKE HACIA ATRAS
CICLO_AVANZA:
    MOV AL,SNAKE_REN[SI]
    MOV SNAKE_REN[SI+1], AL
    MOV AL,SNAKE_COL[SI]
    MOV SNAKE_COL[SI+1],AL
    DEC SI
    LOOP CICLO_AVANZA
    ; AVANZAR SNAKE EN LA DIRECCION CORRESPONDIENTE
    MOV AL,INC_REN
    ADD SNAKE_REN,AL
    MOV AL,INC_COL
    ADD SNAKE_COL,AL
    
    POP CX
    RET
    
AVANZA_SNAKE ENDP
 
BORRA_SNAKE PROC
    PUSH CX
    MOV CX, SNAKE_LARGO
    XOR SI, SI
    
QUITA_SNAKE:
    ; CAMBIAR A POSICION DE COL Y REN DE LA SNAKE
    MOV AH,2
    MOV DL,SNAKE_COL[SI]
    MOV DH,SNAKE_REN[SI]
    MOV BH,0
    INT 10H
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, " "
    MOV BH,0
    MOV BL,FONDO
    PUSH CX
    MOV CX,1
    INT 10H
    POP CX
    INC SI
    LOOP QUITA_SNAKE

    POP CX
    RET
 
BORRA_SNAKE ENDP
CAMBIA_DIRECCION PROC
    CMP AH,50H
    JE DOWN
    CMP AH,48H
    JE UP
    CMP AH,4BH
    JE LEFT
    CMP AH,4DH
    JE RIGHT
    JMP FIN
DOWN:
    MOV DIRECCION_SNAKE,2
    MOV INC_COL,0
    MOV INC_REN,1
    JMP FIN
UP:
    MOV DIRECCION_SNAKE,1
    MOV INC_COL,0
    MOV INC_REN,-1
    JMP FIN
LEFT:
    MOV DIRECCION_SNAKE,3
    MOV INC_COL,-1
    MOV INC_REN,0
    JMP FIN
RIGHT:
    MOV DIRECCION_SNAKE,4
    MOV INC_COL,1
    MOV INC_REN,0
FIN:
    RET    
CAMBIA_DIRECCION ENDP
 

MANZANAS PROC
    push cx
    mov cx, 10            ; Iterar 10 veces para imprimir 10 manzanas

MOSTRAR_MANZANA:
    ; Generar n?mero aleatorio para columna (1-77)
    call generarX

    ; Generar n?mero aleatorio para fila (1-22)
    call generarY

    ; Cambiar la posici?n del cursor
    mov ah, 02h
    mov dl, MANZANA_COL
    mov dh, MANZANA_REN
    mov bh, 00h
    int 10h
    
    ; Desplegar el car?cter de la manzana
    mov ah, 09h
    mov al, MANZANA_CHAR
    mov bh, 00h
    mov bl, MANZANA_COLOR ; Fondo
    mov cx, 1
    int 10h
    

    loop MOSTRAR_MANZANA

    pop cx
    ret
MANZANAS ENDP

generarX PROC
    ; Generar n?mero aleatorio entre 1 y 77
    generarX_loop:
    mov ah, 2Ch          ; Obtener la hora
    int 21h
    
    ; ch -> horas; cl -> minutos; dh -> segundos; dl -> centisegundos
    cmp dl, 0            ; Si centisegundos es igual a 0, regenerar
    jz generarX_loop
    
    mov bh, 77
    cmp dl, bh           ; Si centisegundos es mayor o igual que 78, regenerar
    jae generarX_loop
    
    mov MANZANA_COL, dl
    ret
generarX ENDP

generarY PROC
    ; Generar n?mero aleatorio entre 1 y 22
    generarY_loop:
    mov ah, 2Ch          ; Obtener la hora
    int 21h
    
    ; ch -> horas; cl -> minutos; dh -> segundos; dl -> centisegundos
    cmp dl, 0            ; Si centisegundos es igual a 0, regenerar
    jz generarY_loop
    
    mov bh, 22
    cmp dl, bh           ; Si centisegundos es mayor o igual que 23, regenerar
    jae generarY_loop
    
    mov MANZANA_REN, dl
    ret
generarY ENDP
INCREMENTAR_SNAKE PROC
    INC SNAKE_LARGO
    INC SNAKE_LARGO
    INC SNAKE_LARGO
    
    INC SCORE
    CALL IMPRIMIR_SCORE
    
    RET
INCREMENTAR_SNAKE ENDP
IMPRIMIR_SCORE PROC
    PUSH CX
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,69
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, 'S'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,70
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, 'C'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,71
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, 'O'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,72
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, 'R'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,73
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, 'E'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,74
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, ':'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    
    MOV AH,2
    MOV DL,75
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ;Despelgar SCORE
    MOV DL, '0'
    OR DL, 30h 
    
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,76
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ;Despelgar SCORE
    MOV DL, SCORE
    OR DL, 30h 

    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL, DL
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    
    POP CX
    RET
IMPRIMIR_SCORE ENDP

GAME_OVER PROC
    PUSH CX
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,32
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'G'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,33
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'A'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,34
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'M'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,35
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'E'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,37
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'O'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,38
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'V'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,39
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'E'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    ; CAMBIAR LA POSICION DEL CURSOR
    MOV AH,2
    MOV DL,40
    MOV DH,0
    MOV BH,0
    INT 10H
    
    ; DESPLEGAR EL CHAR DEL SNAKE
    MOV AH,9
    MOV AL,'R'
    MOV BH,0
    MOV BL,SCORE_COLOR ;FONDO
    MOV CX,1
    INT 10H
    
    POP CX
    
    MOV AH, 4CH
    INT 21H
GAME_OVER ENDP

    END MAIN

    ;TAREA
    ;COMO HACER UN NUMERO ALEATORIO
    ;DESPLEGAR UNA COLUMNA Y RENGLON ALEATORIO PARA LAS MANZANAS