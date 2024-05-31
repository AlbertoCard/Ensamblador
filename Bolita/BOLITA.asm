TITLE BOLITA
.MODEL COMPACT
.STACK 100H
.DATA
    UP_DOWN DB 1
    IZQ_DER DB 1
    COL DB 39
    REN DB 1
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
    MOV CX,2
    MOV BL,00111100B
    INT 10H
    
    MOV CX,0FFFFH
ESPERA:
    NOP
    NOP
    LOOP ESPERA
    
    MOV AH,9
    MOV BH,0
    MOV AL,' '
    MOV CX,5
    MOV BL,01001100B
    INT 10H
    
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
    POP CX
    DEC CX
    JE FIN
    JMP BOLITA
    ;LOOP BOLITA
FIN:   
    MOV AH,4CH
    INT 21H
MAIN ENDP
END MAIN