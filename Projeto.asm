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
	MOV @R0, A
	CJNE A, #'$', CONTINUAR
	SJMP FIM

CONTINUAR:
	INC R0
	SJMP SALVAR_ACAO

FIM:
	MOV R0, #30H
	sjmp ENVIA

ENVIA:
	MOV A, @R0
	MOV SBUF, A
	WAIT_TX:
		JNB TI, WAIT_TX
		CLR TI
	CJNE A, #'$', CONT
	SJMP $

CONT:
	INC R0
	SJMP ENVIA

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

retornaCursor:
	CLR RS	      
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	SETB P1.4		

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

;DB de respostas
msg_hora:     DB  'H','o','r','a',' ','A','t','u','a','l',':',0
msg_hora2:    DB  '1','2',':','3','4',0

msg_temp:     DB  'T','e','m','p','e','r','a','t','u','r','a',':',0
msg_temp2:    DB  '2','5',' ','G','R','A','U','S',0

msg_ligar:    DB  'L','u','z','e','s',' ','a','c','e','s','a','s','!',0
msg_ok:       DB  'C','o','m',' ','S','u','c','e','s','s','o',0

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
