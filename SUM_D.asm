title Sum_B
.model small
.stack 100h
.Data
;Mendoza Garcia Brayan 21170398
msg1 db 10,13,'Dame un digito $'
msg2 db 10,13,'Dame otro digito $'
msg3 db 10,13,'La suma es : $'
msg4 db 10,13,'La resta es : $'
digito1 db ?
digito2 db ?
suma db ?
resta db ?
.code
main proc
    mov ax,@data
    mov ds,ax
    ;Desplegar mensaje
    lea dx,msg1
    mov ah,9
    int 21h
    ;Leer primer digito
    mov ah,1
    int 21h
    ;CHAR en AL, Se convierte a num
    AND AL, 0FH
    ;Se guarda en el digito1
    MOV DIGITO1, AL
    MOV AL, 4CH
    ;Desplegar mensaje
    lea dx,msg2
    mov ah,9
    int 21h
    ;Leer segundo digito
    MOV AH, 1
    INT 21H
    ;CHAR en AL, Se convierte a num
    AND AL, 0FH
    ;Se guarda en el digito2
    MOV DIGITO2, AL
    MOV AL, 4CH
    
    MOV AL, DIGITO1
    ADD AL, DIGITO2
    MOV SUMA, AL
    
    LEA DX, MSG3
    MOV AH, 9
    INT 21H
    
    ;Despelgar Suma
    MOV DL, SUMA
    OR DL, 30h 
    MOV AH, 2
    INT 21H
    
    ;Resta
    MOV AL, DIGITO1
    SUB AL, DIGITO2
    MOV RESTA, AL
    
    LEA DX, MSG4
    MOV AH, 9
    INT 21H
    
    ;Desplegar resta
    MOV DL, RESTA
    OR DL, 30h 
    MOV AH, 2
    INT 21H
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP
    END MAIN