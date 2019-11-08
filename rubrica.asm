#Esercizio 1

#Il programma prevede l'inserimento di numeri. In caso si prema un numero non previsto
#viene stampato un messaggio di errore e si torna alla richiesta i input. Inserendo 0, input vuoto o altro che 
#non sia un numero(lettere/simboli), il programma esce.
#Alla pressione di ogni numero per aggiungere un individuo della corrispondente nazionalità, 
# viene aggiornato il dato che viene stampato prima di tornare a richiedere nuovamente input.
#Alla pressione di 8 vengono stampate tutte le statistiche aggiornate all'ultimo inserimento.
#Si usa una JAT per le procedure dello switch. Il resto dell'area dati utilizzato è riservato alle statistiche.

# Scelta di progetto:
# Per sviluppare il primo esercizio del progetto, ci siamo accorti di quanto fosse più semplice
# scegliere di saltare 3 come valore di input, rimandando ad una procedura di Errore per input non previsto,
# e di scegliere invece il valore immediatamente dopo l'ultima nazionalità disponibile, ovvero 8
# per accedere in ogni momento alla statistica demografica.
# 
# Abbiamo scelto l'area statica DATA per salvare dati, sia per esercitarci nell'uso di questa
# sia perchè l'uso dello stack nel secondo esercizio del progetto è forzato per potere applicare la ricorsione.
# Inoltre qui su applicava bene l'idea di un'area statica della memoria.

# Mappatura dei registri:
# $s0 <-- Start Address
# $s1 <-- indirizzo dati statistiche
# $s3 <-- contiene indirizzo della procedura da richiamare a seconda dell'input immesso dall'utente
# $t1 <-- indicatore di stampa statistiche
# $t3 <-- 3
# $t4 <-- 4
# $t7 <-- 1 contatore di stampa
# $t8 <-- 8
# $v0, $a0 <-- usati per le syscall

         .data

jump:    .space 32
stats:   .space 32
prompt:  .asciiz "Inserisci nazionalità cui aggiungere individuo: \n 1=IT; 2=GB; 4=M; 5=D; 6=E; 7=F\n [0 per uscire dal programma; 8 per stampare statistiche]\n"
errore:  .asciiz "Numero inserito non valido! Riprovare \n"
acapo:   .asciiz " \n"
spazio:  .asciiz "          "
msg0:    .asciiz "Fine"
msg1:    .asciiz "Aggiunto individuo italiano \n"
msg2:    .asciiz "Aggiunto individuo inglese \n"
msg3:    .asciiz "Aggiunto individuo malese \n"
msg4:    .asciiz "Aggiunto individuo tedesco \n"
msg5:    .asciiz "Aggiunto individuo spagnolo \n"
msg6:    .asciiz "Aggiunto individuo francese \n"
msg7:    .asciiz "Stampa delle statistiche: \n"
msg8:    .asciiz "Italiani: "
msg9:    .asciiz "Inglesi:  "
msg10:   .asciiz "Malesi :  "
msg11:   .asciiz "Tedeschi: "
msg12:   .asciiz "Spagnoli: "
msg13:   .asciiz "Francesi: "
msg14:   .asciiz "Italiani - Inglesi - Malesi - Tedeschi - Spagnoli - Francesi \n"


         .text
         .globl main

main:
# carico la Jump Address Table con i valori opportuni

         la $s0 , jump     # $s0 contiene lo start address della JAT
         la $t0 , proc0    # salvo l'indirizzo della procedura zero
         sw $t0 , 0($s0)
         la $t0 , proc1    # salvo l'indirizzo della prima procedura
         sw $t0 , 4($s0)
         la $t0 , proc2    # salvo l'indirizzo della seconda procedura
         sw $t0 , 8($s0)
         la $t0 , proc3    # salvo l'indirizzo della terza procedura
         sw $t0 , 16($s0)
         la $t0 , proc4    # salvo l'indirizzo della quarta procedura
         sw $t0 , 20($s0)
         la $t0 , proc5    # salvo l'indirizzo della quinta procedura
         sw $t0 , 24($s0)
         la $t0 , proc6    # salvo l'indirizzo della sesta procedura
         sw $t0 , 28($s0)
         la $t0 , proc7    # salvo l'indirizzo della settima procedura
         sw $t0 , 32($s0)

# richiesta di dati
req:
         li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, prompt		 # carico in a0 l'indirizzo di prompt
         syscall           	 # stampo messaggio prompt a schermo
         li $v0, 5        	 # leggo un intero N da console
         syscall           	 # numero N salvato in $v0

# controllo dell'input
         blt $v0, $0, error      # se N < 0 vado alla procedura di Errore
         li $t3, 3               # salvo 3 in t3
         beq $v0, $t3, error     # se N è realmente 3 vado alla procedura di Errore
         li $t8, 8               # salvo 8 in t8
         bgt $v0, $t8, error     # se N > 8 vado alla procedura di Errore

# calcolo indirizzo della procedura richiesta e la richiamo
         li $t4, 4		 # salvo 4 in t4
         mul $t4, $t4 , $v0 	 # $t4 = $v0* 4
         add  $s2, $t4, $s0      # $s2 = offset + start address
         la $s1, stats           # salvo in s1 l'indirizzo dei dati delle statistiche
         add $s6, $t4, $s1       # calcolo i dati a cui dovrò sommare 1
         lw $s5, 0($s6)          # lo salvo in $s5
         lw $s3, 0($s2)        	 # carico in s3 l'indirizzo della procedura che devo richiamare
	 move $a1, $s1		 # passo come parametro alla procedura l'indirizzo delle statistiche, nel caso fosse richiamata la procedura di stampa
         jal $s3                 # salto alla procedura corrispondente

# incremento dei dati elaborati nelle procedure (eseguito al ritorno da qualsiasi procedura, perchè comune a tutte)
         bnez $t1, no_incr       # se l'indicatore di stampa statistiche è diverso da 0 salto l'incremento dei dati
         addi $a0 , $s5 , 1      # aggiorno numero individui(uso a0 per economizzare, tanto non contiene dati da preservare)
         sw $a0, 0($s6)          # salvo nuovo dato calcolato
         li $v0, 1		 # carico in v0 1, codice per stampa int
         syscall                 # stampo numero individui aggiornato

# se non ho aggiunto non devo incrementare, quindi salto l'incremento, vado a capo e torno a chiedere input
no_incr:  
         li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, acapo		 # carico in a0 l'indirizzo di acapo
         syscall                 # vado a capo
         li $t1, 0               # metto a 0 l'indicatore di stampa statistiche
         j req                   # salto alla richiesta di input




# " Elenco delle procedure utilizzate " #

# procedura di exit
proc0:
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg0        	 # carico in a0 l'indirizzo di msg0
         syscall		 # stampo messaggio di uscita
   
Exit:    
	 li $v0, 10           	 # esco dal programma (avviene solo in caso di proc0)
         syscall

# Le seguenti procedure stampano messaggi di aggiunta e statistiche aggiornate, diverse in base alla nazionalità,
# ma l'incremento dei dati è identico per tutte. Pertanto viene eseguito al ritorno da queste.

# procedura di aggiunta italiano
proc1:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg1		 # carico in a0 l'indirizzo di msg1
         syscall                 # stampo messaggio msg1 (di aggiunta)	 
         la $a0, msg8		 # carico in a0 l'indirizzo di msg8
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di aggiunta inglese
proc2:    
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg2		 # carico in a0 l'indirizzo di msg2
         syscall                 # stampo messaggio msg2 (di aggiunta)
         la $a0, msg9		 # carico in a0 l'indirizzo di msg9
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di aggiunta malese
proc3:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg3		 # carico in a0 l'indirizzo di msg3
         syscall                 # stampo messaggio msg3 (di aggiunta)
         la $a0, msg10		 # carico in a0 l'indirizzo di msg10
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di aggiunta tedesco
proc4:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg4		 # carico in a0 l'indirizzo di msg4
         syscall                 # stampo messaggio msg4 (di aggiunta)
         la $a0, msg11		 # carico in a0 l'indirizzo di msg11
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di aggiunta spagnolo
proc5:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg5		 # carico in a0 l'indirizzo di msg5
         syscall                 # stampo messaggio msg5 (di aggiunta)
         la $a0, msg12		 # carico in a0 l'indirizzo di msg12
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di aggiunta francese
proc6:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg6		 # carico in a0 l'indirizzo di msg6
         syscall                 # stampo messaggio msg6 (di aggiunta)
         la $a0, msg13		 # carico in a0 l'indirizzo di msg13
         syscall                 # stampo stringa statistiche
         jr $ra                  # torno al chiamante

# procedura di stampa statistica demografica
proc7:   
	 li $v0, 4		 # carico in v0 4, codice per stampa stringa
         la $a0, msg7     	 # carico in a0 l'indirizzo di msg7
         syscall                 # stampo messaggio msg7 (di stampa statistiche)
         la $a0, msg14	 	 # carico in a0 l'indirizzo di msg14
         syscall                 # stampo messaggio msg14 (elenco nazionalita)
         li $t4, 4		 # carico 4 in t4
	 li $t3,3
	 li $t8,8
         li $t7, 1		 # setto t7 a 1, che userò come contatore per le stampe
 
# stampa dei dati aggiornati ad ultima aggiunta. L'elenco avviene leggendo in memoria con un contatore
elenco:   
         beq $t7, $t3, incremento  # test: se raggiungo 3 lo salto perchè vuoto
         mul $a3, $t4, $t7         # a3= 4 * t7 (contatore) calcolo spiazzamento
         add $a2, $a1, $a3         # a2= start address + calcolo posizione dato
         lw $a0, 0($a2)            # carico il dato in a0
         li $v0, 1		   # carico 1 in v0, codice di una print int
         syscall                   # stampo il dato caricato
         li $v0, 4	 	   # carico in v0 4, codice per stampa stringa
         la $a0, spazio	   	   # carico in a0 l'indirizzo di spazio
         syscall                   # stampo dello spazio

incremento:  
	 addi $t7, $t7, 1          # incremento il contatore di stampa
         bne $t7, $t8, elenco      # finchè il contatore non arriva a 8 torno alla procedura elenco
         li $t1, 1		   # una volta finito, resetto il contatore stampe
         jr $ra			   # torno al chiamante


# Procedura di Messaggio di Errore
error:   
	 li $v0, 4         	   # carico in v0 4, codice per stampa stringa
         la $a0, errore		   # carico in a0 l'indirizzo di errore
         syscall		   # stampo messaggio di Errore
         j req		   	   # richiedi nuovamente un input valdio