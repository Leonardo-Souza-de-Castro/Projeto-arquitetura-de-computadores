ORG 0000H

INICIO:
ORG 0100H


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