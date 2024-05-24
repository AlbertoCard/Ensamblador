TITLE BOLITA
.MODEL COMPACT
.STACK 100H
.DATA
    UP_DOWN DB 0
    IZQ_DER DB 1
    COL DB 39
    REN DB 23
    COL_INICIO  DB 20H  
    COL_FIN     DB 30H
    ATRIB_BLANCO    DB 01011110B ;00101110B 
    ATRIB_DISPLAY   DB 00111100B
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    
    MOV AH,0
    MOV AL,3
    INT 10H
    ; FIJAR MODO DE VIDEO 3
    
    MOV AH,5
    MOV AL,0
    INT 10H
    ; FIJAR PAGINA ACTIVA 0
    
    MOV AH,1
    MOV CH,5
    MOV CL,0
    INT 10H
    ; DESAPARECE EL CURSOR
    
    MOV AH,7
    MOV AL,25
    MOV BH,00111100B
    MOV CX,0
    MOV DX,184FH
    INT 10H
    ; HACER EL CUADRO DE ALREDEDOR
    
    MOV AH,6
    MOV AL,23
    MOV BH,01001100B
    MOV CX,0101H
    MOV DX,174EH
    INT 10H
    ; HACER CUADRO DE ENMEDIO
    
    
    
    
    MOV AH,6
    MOV AL,1
    MOV BH,01011110B
    MOV CX,0101H
    MOV DX,184EH
    INT 10H
    ; HACER LA LINEA DE ABAJO

    

    
    MOV AH,7
    MOV AL,1
    MOV BH,00101110B
    MOV CX,0101H
    MOV DX,174EH
    INT 10H
    ; HACER LA LINEA DE ARRIBA
    
    CALL DISPLAY_BARRA
    ; MOVER EL CURSOR
    MOV CX,1000
BOLITA:
    MOV AH,2
    MOV DH,REN
    MOV DL,COL
    MOV BH,0
    INT 10H
    
    PUSH CX
    ; DESPLEGAR UNA BOLITA
    
    MOV AH,9
    MOV BH,0
    MOV AL,'*'
    MOV CX,1
    MOV BL,01000000B ;01001100
    INT 10H
    
    
    MOV CX,0AFFFH
ESPERA:
    NOP
    NOP
    LOOP ESPERA
    
    MOV AH,9
    MOV BH,0
    MOV AL,' '
    MOV CX,1
    MOV BL,01001100B
    INT 10H
    
    CALL MUEVE_BOLITA
    ;CALL DESPLIEGA_BARRA
    ; CHECAR SI HAY TECLA
    
   
CICLO_BARRA:
    
    
    MOV AH,1
    INT 16H
    JZ NO_TECLA
    MOV AH,0
    INT 16H
    ; LEER TECLA
    ; ES FLECHA IZQ?
    CMP AH,4BH
    JE FLECHA_IZQ
    CMP AH,4DH
    JE FLECHA_DER
    JMP CICLO_BARRA
FLECHA_IZQ:
    
    CMP COL_INICIO,1
    JE CICLO_BARRA
    CALL BORRA_BARRA
    
    
    DEC COL_INICIO
    DEC COL_FIN
    JMP MUEVE_BARRA
FLECHA_DER:  
    CMP COL_FIN,4EH
    JE CICLO_BARRA
    CALL BORRA_BARRA
    
    
    INC COL_INICIO
    INC COL_FIN
MUEVE_BARRA:
    CALL DISPLAY_BARRA
    JMP CICLO_BARRA
NO_TECLA:
    
        

    POP CX
    DEC CX
    JE FIN
    JMP BOLITA
    ;LOOP BOLITA
FIN:   
    MOV AH,4CH
    INT 21H
MAIN ENDP

MUEVE_BOLITA PROC

    CMP UP_DOWN,1
    JNE RESTA_REN
SUMA_REN:
    INC REN
    CMP REN,24
    JNE SIGUE
    MOV UP_DOWN,0
    MOV REN,23
    JMP SIGUE
RESTA_REN:
    DEC REN
    CMP REN,0
    JNE SIGUE
    MOV UP_DOWN,1
    MOV REN,1
SIGUE:

    CMP IZQ_DER,1
    JNE RESTA_COL
SUMA_COL:
    INC COL
    CMP COL,79
    JNE SIGUE2
    MOV IZQ_DER,0
    MOV COL,78
    JMP SIGUE2
RESTA_COL:
    DEC COL
    CMP COL,0
    JNE SIGUE2
    MOV IZQ_DER,1
    MOV COL,1
SIGUE2:
    RET
MUEVE_BOLITA ENDP

DISPLAY_BARRA PROC
    MOV AH,6
    MOV AL,1
    MOV BH,ATRIB_DISPLAY
    MOV CH,18H
    MOV CL,COL_INICIO
    MOV DH,18H
    MOV DL,COL_FIN
    INT 10H
    ; HACER LA BARRA
    RET
DISPLAY_BARRA ENDP

BORRA_BARRA PROC
    MOV AH,6
    MOV AL,1
    MOV BH,ATRIB_BLANCO
    MOV CH,18H
    MOV CL,COL_INICIO
    MOV DH,18H
    MOV DL,COL_FIN
    INT 10H
    ; HACER LA BARRA
    RET
BORRA_BARRA ENDP
END MAIN