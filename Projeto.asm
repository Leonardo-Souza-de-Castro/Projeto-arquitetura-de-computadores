;Obs: Para o projeto rodar, precisamos mudar os pinos do LED para p0

RS equ P1.3 
EN equ P1.2

ORG 0000h
	ACALL BV_MENSAGEM
	LJMP INICIO
ORG 0100h

INICIO:
	MOV SCON, #01010000B ;Configurando SCON
	MOV PCON, #10000000B ;Ativa o SCON
	MOV TMOD, #20H ;CT1 no modo 2
	MOV TH1, #243  ;valor para a recarga
	MOV TL1, #243  ;valor para a primeira contagem
	CLR ES ; desativa interrupção serial
	SETB EA ; se precisar das demais
	SETB TR1
	MOV R0, #30H
	MOV R1, #29H

	

SALVAR_ACAO:
	JNB RI, SALVAR_ACAO
	CLR RI
	MOV A, SBUF
	; Veririca se são caracteres de validacao do ASCII como enters e /r
	CJNE A, #0DH, VERIFICA_LF
	SJMP SALVAR_ACAO    
    
VERIFICA_LF:
	; Verifica se é LF (0A)
	CJNE A, #0AH, SALVAR_CARACTERE
	SJMP SALVAR_ACAO    ; Ignora LF e volta para esperar próximo caractere

SALVAR_CARACTERE:
	MOV @R0, A
	CJNE A, #'$', CONTINUAR
	SJMP FIM

CONTINUAR:
	INC R0
	SJMP SALVAR_ACAO

FIM:
	MOV R0, #30H

	MOV DPTR, #msg_horas
	ACALL COMPARAR_STRING
	JZ HORAS

	MOV DPTR, #msg_ligar_luz
	ACALL COMPARAR_STRING
	JZ LUZ

	MOV DPTR, #msg_apagar_luz
	ACALL COMPARAR_STRING
	JZ APAGAR_LUZ

	MOV DPTR, #msg_repouso_pergunta
	ACALL COMPARAR_STRING
	JZ FLAG_REPOUSO

	MOV DPTR, #msg_reiniciar3
	ACALL COMPARAR_STRING
	JZ FLAG_REINICIAR

	MOV DPTR, #msg_ola3
	ACALL COMPARAR_STRING
	JZ FLAG_OLA

	MOV DPTR, #msg_clima
	ACALL COMPARAR_STRING
	JZ FLAG_CLIMA

	ACALL ERRO_MENSAGEM
	LJMP SALVAR_ACAO

FLAG_OLA:
	LJMP OLA
FLAG_CLIMA:
	LJMP CLIMA
FLAG_REINICIAR:
	LJMP REINICIAR
FLAG_REPOUSO:
	LJMP REPOUSO
	

HORAS:
	ACALL lcd_init
	ACALL clearDisplay
	ACALL delay_longo
	MOV A, #03H
	ACALL posicionaCursor
	MOV DPTR, #msg_hora
	ACALL escreveString
	MOV A, #46H
	ACALL posicionaCursor
	MOV DPTR, #msg_hora2
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

LUZ:
	MOV P0, #00000000B
	ACALL lcd_init
	ACALL clearDisplay
	ACALL delay_longo
	MOV A, #02H
	ACALL posicionaCursor
	MOV DPTR, #msg_ligar
	ACALL escreveString
	MOV A, #42H
	ACALL posicionaCursor
	MOV DPTR, #msg_ok
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

APAGAR_LUZ:
	MOV P0, #11111111B
	ACALL lcd_init
	ACALL clearDisplay
	ACALL delay_longo
	MOV A, #00H
	ACALL posicionaCursor
	MOV DPTR, #msg_desligar
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

REPOUSO:
	ACALL lcd_init
	ACALL clearDisplay

	ACALL delay_longo

	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_dormir
	ACALL escreveString
	MOV A, #41H
	ACALL posicionaCursor
	MOV DPTR, #msg_dormir2
	ACALL escreveString

	ACALL delay_longo
	ACALL clearDisplay
	ACALL delay_longo

	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_dormir3
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

REINICIAR:
	ACALL lcd_init
	ACALL clearDisplay
	
	ACALL delay_longo
	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_reiniciar
	ACALL escreveString
	MOV A, #41H
	ACALL posicionaCursor
	MOV DPTR, #msg_reiniciar2
	ACALL escreveString

	ACALL delay_longo
	ACALL LIMPAR_MEMORIA
	ACALL delay_longo
	ACALL clearDisplay
	ACALL delay_longo
	ACALL BV_MENSAGEM
	MOV R0, #30H
	LJMP SALVAR_ACAO

OLA:
	ACALL lcd_init
	ACALL clearDisplay

	ACALL delay_longo
	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_ola
	ACALL escreveString
	MOV A, #41H
	ACALL posicionaCursor
	MOV DPTR, #msg_ola2
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

CLIMA:
	ACALL lcd_init
	ACALL clearDisplay
	ACALL MEDIR_TEMP 

	ACALL delay_longo
	
	MOV A, #02H
	ACALL posicionaCursor
	MOV DPTR, #msg_temp
	ACALL escreveString

	ACALL delay_longo

	MOV A, R4            ; A = temperatura (0–255)
	MOV B, #100          ; Dividir por 100 para obter as centenas
	DIV AB                ; A = centenas, B = resto (dezenas e unidades)
	ADD A, #30h           ; Converte centenas para ASCII
	MOV R6, A             ; Armazena a centena (ASCII)

	MOV A, B              ; A = resto (dezenas e unidades)
	MOV B, #10            ; Dividir por 10 para obter as dezenas
	DIV AB                ; A = dezenas, B = unidades
	ADD A, #30h           ; Converte dezenas para ASCII
	MOV R7, A             ; Armazena a dezena (ASCII)

	MOV A, B              ; A = unidades
	ADD A, #30h           ; Converte unidades para ASCII
	MOV R5, A             ; Armazena a unidade (ASCII)

	; Exibe centenas (se não for zero)
	MOV A, #0C4h          ; Posição no LCD: linha 2, coluna 4
	ACALL posicionaCursor
	MOV A, R6
	ACALL sendCharacter

	; Exibe dezenas
	MOV A, #0C5h          ; Posição no LCD: linha 2, coluna 5
	ACALL posicionaCursor
	MOV A, R7
	ACALL sendCharacter

	; Exibe unidades
	MOV A, #0C6h          ; Posição no LCD: linha 2, coluna 6
	ACALL posicionaCursor
	MOV A, R5
	ACALL sendCharacter

	ACALL delay_longo
	
	MOV A, #48H
	ACALL posicionaCursor
	MOV DPTR, #msg_temp2
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	LJMP SALVAR_ACAO

ERRO_MENSAGEM:
	ACALL lcd_init
	ACALL clearDisplay

	ACALL delay_longo
	MOV A, #02H
	ACALL posicionaCursor
	MOV DPTR, #msg_erro
	ACALL escreveString
	MOV A, #41H
	ACALL posicionaCursor
	MOV DPTR, #msg_erro2
	ACALL escreveString
	MOV R0, #30H
	ACALL LIMPAR_REGISTRADORES
	RET

LIMPAR_MEMORIA:
	INC R1
	MOV @R1, #00H
	CJNE R1, #50H, LIMPAR_MEMORIA
	MOV R2, #00H
	MOV R3, #00H
	MOV R4, #00H
	MOV R5, #00H
	MOV R6, #00H
	MOV R7, #00H
	MOV R1, #29H
	RET

LIMPAR_REGISTRADORES:
	MOV R2, #00H
	MOV R3, #00H
	MOV R4, #00H
	MOV R5, #00H
	MOV R6, #00H
	MOV R7, #00H
	RET

BV_MENSAGEM:
	ACALL lcd_init
	ACALL clearDisplay

	ACALL delay_longo
	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_bv
	ACALL escreveString

	ACALL delay_longo
	ACALL clearDisplay
	RET

COMPARAR_STRING:
	MOV R0, #30H

COMPARAR_LOOP:
	MOV A, @R0        ; Caractere atual da RAM
	MOV B, A  ; Guarda o caractere da RAM
	CLR A
	MOVC A, @A+DPTR     ; Caractere atual da ROM
	CJNE A, B, NAO_IGUAL
	CJNE A, #'$', CONTINUAR_2
	CLR A
	RET

CONTINUAR_2:
	INC R0
	INC DPTR
	SJMP COMPARAR_LOOP

NAO_IGUAL:
	RET
	
escreveString:
	MOV R2, #0
rot:
	MOV A, R2
	MOVC A,@A+DPTR ;lê a tabela da memória de programa
	ACALL sendCharacter ; send data in A to LCD module
	INC R2
	JNZ rot ; if A is 0, then end of data has been reached - jump out of loop
	RET
MEDIR_TEMP:
	CLR P3.6
	SETB P3.6
	JB P3.2, $

	CLR P3.7
	MOV A, P2
	SETB P3.7
	
	MOV B, #2

	MUL AB
	
	MOV R4, A
	MOV R5, B
	RET
;Sub-Rotinas -> Display
lcd_init:
	CLR RS		

	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CALL delay		

	SETB EN		
	CLR EN		

	SETB P1.7		

	SETB EN		
	CLR EN		

	CALL delay		


	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	SETB P1.6		
	SETB P1.5		

	SETB EN		
	CLR EN		

	CALL delay		


	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	SETB P1.7		
	SETB P1.6		
	SETB P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay		
	RET

sendCharacter:
	SETB RS  		
	MOV C, ACC.7		
	MOV P1.7, C		
	MOV C, ACC.6		
	MOV P1.6, C		
	MOV C, ACC.5		
	MOV P1.5, C		
	MOV C, ACC.4		
	MOV P1.4, C		

	SETB EN		
	CLR EN		

	MOV C, ACC.3		
	MOV P1.7, C		
	MOV C, ACC.2		
	MOV P1.6, C		
	MOV C, ACC.1		
	MOV P1.5, C		
	MOV C, ACC.0		
	MOV P1.4, C		

	SETB EN		
	CLR EN		

	CALL delay		
	RET

posicionaCursor:
	CLR RS	         
	SETB P1.7		
	MOV C, ACC.6		
	MOV P1.6, C		
	MOV C, ACC.5		
	MOV P1.5, C		
	MOV C, ACC.4		
	MOV P1.4, C		

	SETB EN		
	CLR EN		

	MOV C, ACC.3		
	MOV P1.7, C		
	MOV C, ACC.2		
	MOV P1.6, C		
	MOV C, ACC.1		
	MOV P1.5, C		
	MOV C, ACC.0		
	MOV P1.4, C		

	SETB EN		
	CLR EN		

	CALL delay		
	RET

clearDisplay:
	CLR RS	      
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay		
	RET

delay:
	MOV R0, #50
	DJNZ R0, $
	RET

delay_longo:
	MOV R3, #100     ; 100 * delay curto (~50 * instruções)
loop_delay:
	ACALL delay
	DJNZ R3, loop_delay
	RET

;DB de pergunta
msg_horas:   DB 'Q','u','e',' ','h','o','r','a','s',' ','s','a','o','?','$',0

msg_clima:       DB 'C','o','m','o',' ','e','s','t','a',' ','o',' ','c','l','i','m','a','?','$',0

msg_ligar_luz:   DB 'A','s','c','e','n','d','e','r',' ','a','s',' ','l','u','z','e','s','$',0

msg_apagar_luz:  DB 'A','p','a','g','a','r',' ','a','s',' ','l','u','z','e','s','$',0

msg_repouso_pergunta:	DB 'E','n','t','r','a','r',' ','e','m',' ','m','o','d','o',' ','r','e','p','o','u','s','o','$',0

msg_reiniciar3:  DB 'R','e','i','n','i','c','i','a','r','$',0

msg_ola3:        DB 'O','l','a','$',0

;DB de respostas
msg_hora:     DB  'H','o','r','a',' ','A','t','u','a','l',':',0
msg_hora2:    DB  '1','2',':','3','4',0

msg_temp:     DB  'T','e','m','p','e','r','a','t','u','r','a',':',0
msg_temp2:    DB  ' ','C',0

msg_ligar:    DB  'L','u','z','e','s',' ','a','c','e','s','a','s','!',0
msg_ok:       DB  'C','o','m',' ','S','u','c','e','s','s','o','!',0

msg_desligar: DB  'L','u','z','e','s',' ','D','e','s','l','i','g','a','d','a','s',0

msg_dormir:   DB  'E','n','t','r','a','n','d','o',' ','e','m',0
msg_dormir2:  DB  'M','o','d','o',' ','R','e','p','o','u','s','o',0
msg_dormir3:  DB  'Z','Z','Z','Z','Z','Z','Z','Z','Z','Z','Z','Z',0

msg_reiniciar:  DB 'R','e','i','n','i','c','i','a','n','d','o',0
msg_reiniciar2: DB 'A','G','U','A','R','D','E','.','.','.','.',0

msg_ola:        DB 'O','l','a',' ','C','o','m','o',' ','v','a','i','?',0
msg_ola2:       DB 'P','o','s','s','o',' ','a','j','u','d','a','r','?',0

msg_erro:       DB 'N','a','o',' ','e','n','t','e','n','d','i','!',0
msg_erro2:      DB 'F','a','l','e',' ','n','o','v','a','m','e','n','t','e',0

msg_bv:       DB 'O','l','a' ,' ','B','e','m',' ','v','i','n','d','o',0
msg_bv2:      DB 'C','o','l','o','q','u','e',' ','e','s','p','a','c','o',0
msg_bv3:      DB 'N','o',' ','1',' ','c','o','m','a','n','d','o',0