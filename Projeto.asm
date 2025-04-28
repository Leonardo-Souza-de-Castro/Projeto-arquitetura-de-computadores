;Obs: Para o projeto rodar, precisamos mudar os pinos do LED para p0

RS equ P1.3 
EN equ P1.2
ORG 0000h
	LJMP INICIO
ORG 0100h

INICIO:
	MOV SCON, #01010000B ;Configurando SCON
	MOV PCON, #10000000B ;Ativa o SCON
	MOV TMOD, #20H ;CT1 no modo 2
	MOV TH1, #243  ;valor para a recarga
	MOV TL1, #243  ;valor para a primeira contagem
	MOV IE,#90H ; Habilita interrupção serial
	SETB TR1
	MOV R0, #30H

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

	MOV DPTR, #msg_emitir_som
	ACALL COMPARAR_STRING
	JZ SOM

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
	MOV A, #42H
	ACALL posicionaCursor
	MOV DPTR, #msg_hora2
	ACALL escreveString
	MOV R0, #30H
	RET

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
	RET

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
	RET

SOM:
	ACALL lcd_init
	ACALL clearDisplay
	ACALL delay_longo
	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_som
	ACALL escreveString
	MOV A, #41H
	ACALL posicionaCursor
	MOV DPTR, #msg_som2
	ACALL escreveString
	MOV R0, #30H
	RET

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

	ACALL delay
	ACALL clearDisplay
	ACALL delay_longo

	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_dormir3
	ACALL escreveString
	MOV R0, #30H
	RET

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
	MOV R0, #30H
	RET

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
	RET

CLIMA:
	ACALL lcd_init
	ACALL clearDisplay

	ACALL delay_longo
	MOV A, #01H
	ACALL posicionaCursor
	MOV DPTR, #msg_temp
	ACALL escreveString
	MOV A, #44H
	ACALL posicionaCursor
	MOV DPTR, #msg_temp2
	ACALL escreveString
	MOV R0, #30H
	RET

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

msg_emitir_som:  DB 'E','m','i','t','a',' ','u','m',' ','s','o','m','$',0

msg_repouso_pergunta:      DB 'E','n','t','r','a','r',' ','e','m',' ','m','o','d','o',' ','r','e','p','o','u','s','o','$',0

msg_reiniciar3:  DB 'R','e','i','n','i','c','i','a','r','$',0

msg_ola3:        DB 'O','l','a','$',0

;DB de respostas
msg_hora:     DB  'H','o','r','a',' ','A','t','u','a','l',':',0
msg_hora2:    DB  '1','2',':','3','4',0

msg_temp:     DB  'T','e','m','p','e','r','a','t','u','r','a',':',0
msg_temp2:    DB  '2','5',' ','G','R','A','U','S',0

msg_ligar:    DB  'L','u','z','e','s',' ','a','c','e','s','a','s','!',0
msg_ok:       DB  'C','o','m',' ','S','u','c','e','s','s','o','!',0

msg_desligar: DB  'L','u','z','e','s',' ','D','e','s','l','i','g','a','d','a','s',0

msg_som:      DB  'E','m','i','t','i','n','d','o',' ','S','o','m',':',0
msg_som2:     DB  'A','G','U','A','R','D','E','.','.','.','.',0

msg_dormir:   DB  'E','n','t','r','a','n','d','o',' ','e','m',0
msg_dormir2:  DB  'M','o','d','o',' ','R','e','p','o','u','s','o',0
msg_dormir3:  DB  'Z','Z','Z','Z','Z','Z','Z','Z','Z','Z','Z','Z',0

msg_reiniciar:  DB 'R','e','i','n','i','c','i','a','n','d','o',0
msg_reiniciar2: DB 'A','G','U','A','R','D','E','.','.','.','.',0

msg_ola:        DB 'O','l','a',' ','C','o','m','o',' ','v','a','i','?',0
msg_ola2:       DB 'P','o','s','s','o',' ','a','j','u','d','a','r','?',0

msg_erro:       DB 'N','a','o',' ','e','n','t','e','n','d','i','!',0
msg_erro2:      DB 'F','a','l','e',' ','n','o','v','a','m','e','n','t','e',0
