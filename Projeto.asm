RS equ P1.3 
EN equ P1.2

org 0000h
	LJMP INICIO

org 0100h
INICIO:

;DB de respostas
msg_hora:DB "Hora Atual:", 0
msg_hora2:DB "12:34", 0

msg_temp:DB "Temperatura:", 0
msg_temp2:DB "25 GRAUS", 0 ;Vamos usar o sensor do Edsim51 de temperatura para simular esse valor

msg_ligar:DB "Luzes acessas!", 0
msg_ok:DB "Com Sucesso", 0 ;Vamos ascender os LED's para mostrar que as luzes foram acessas

msg_desligar:DB "Luzes Desligadas", 0 ;Vamos apagar os LED's

msg_som:DB "Emitindo Som:", 0
msg_som2:DB "AGUARDE...", 0 ;Vamos emitir um som com o Buzzer do EdSim

msg_dormir:DB "Entrando em", 0
msg_dormir2:DB "Modo Repouso", 0
msg_dormir3: DB "ZZZZZZZZZZZZ", 0

msg_reiniciar:  DB "Reiniciando", 0
msg_reiniciar2: DB "AGUARDE...", 0

msg_ola:        DB "Ola, Como vai?", 0
msg_ola2:       DB "Posso ajudar?", 0

msg_erro:       DB "Não entendi!!", 0
msg_erro2:      DB "Fale novamente", 0



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
