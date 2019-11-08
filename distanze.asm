# Esercizio 2.

# Programma che legge da input un numero N di valori e che, ad ogni passo di ricorsione, raggruppa i 2 valori più vicini,
# sostituendo ai loro valori la loro media, sistemando lo stack scalando di una word(4 byte), e stampando la nuova sequenza ottenuta.
# Il programma, prima di entrare nella ricorsione, stampa la sequenza immessa dall'utente.
# Se N è minore o uguale  a zero, il programma esce immediatamente.
# Se N è uno, il programma stampa solo quel numero ed esce.
# In caso di "distanze minori uguali" viene salvata quella della coppia a sinistra.


# Scelta di progetto:
# Per sviluppare il secondo esercizio del progetto, ci siamo accorti di quanto sia importante il Frame Pointer
# come puntatore all'area Stack e come indirizzo base da cui effettuare i confronti sui valori.
# Evita un ripetitivo calcolo dell'offset rispetto allo Stack Pointer, e soprattutto non modifica l'ampiezza dello Stack facendolo scorrere.

# OSSERVAZIONE:
# Il caso base (per il quale devo fermare la ricorsione) è quello in cui ho SOLO 1 numero,

# Mappatura dei registri:
# $s0 <-- N iniziale
# $s1 <-- 4*N
# $s3 <-- usato nel modulo della distanza
# $s5 <-- media
# $s6 <-- inizio dell'array (primo dato inserito)
# $s7 <-- fine dell'array (ultimo dato inserito)
# $t1 <-- 1
# $t2 <-- offset della coppia con distanza minore
# $t3 <-- contatore per determinare la posizione della coppia caricata correntemente 
# $t4 <-- 4   
# $t5 <-- distanza minore
# $t6 <-- flag_posizione: indica la posizione della coppia la cui distanza è la minore
# $t7 <-- 2
# $t8 <-- usato pe caricare gli indirizzi dell'area di memoria statica
# $a  <-- utilizzati come parametri nelle procedure
# $v0 <-- restituisce un valore al ritorno dalle procedure

.data

indN:       .space 4	# qui tengo come riferimento gli N valori che sono presenti nell'array (ad ogni passo aggiornato in ricorsione)
fineArray:  .space 4	# qui salvo l'indirizzo dello stack che sarebbe la fine del mio array (ad ogni passo aggiornato in ricorsione)
inizioArray:.space 4	# qui salvo l'indirizzo dello stack che sarebbe l'inizio del mio array 
input:     .asciiz "Quanti numeri vuoi inserire nella sequenza? : \n" # messaggio iniziale
richiesta: .asciiz "Inserisci numero: \n" 
spazi:     .asciiz "   " 
capo:      .asciiz "\n" 
prima:     .asciiz "Sequenza immessa: \n"
iterazione:.asciiz "Iterazione: \n"


.text
.globl main

# richiesta del numero di dati e allocazione spazio in STACK
main:
		li $v0, 4	     	   # carico 4 in $v0
		la $a0, input	     	   # carico in $a0 l'indirizzo di input
		syscall		     	   # stampo messaggio di input a schermo

		li $v0 , 5           	   # carico in $v0 il codice per la lettura di un intero da input 
	        syscall              	   # chiamata per la lettura dell'intero inserito dall'utente

		ble $v0, $zero, exit 	   # se N<=0 esco subito dal programma
		la $s0, indN		   # carico l'indirizzo di indN	
		sw $v0, 0($s0)		   # scrivo N in data 
		move $s0, $v0		   # in s0 c'è N iniziale, prima della ricorsione

		li $t4 , 4           	   # carico in $t4 il valore 4 per preparare l'offset per l'indirizzo
           	mul $s1 , $t4 , $s0  	   # $s1 = 4*N
		sub $sp, $sp, $s1    	   # alloco 4*N byte in stack, ovvero N word
		move $fp, $sp	     	   # utilizzo il framepointer per puntare alla fine dei miei dati

		
# lettura della sequenza
		move $a2, $s0		   # metto in a2 N iniziale, per passarlo come parametro a lettura
		jal lettura		   # leggo la sequenza di interi tramite procedura

# eseguo il salvataggio di inizio e fine array in dei registri fissi
                move $s7, $fp		   # in $s7 c'è la fine del mio array
		move $fp, $sp		   # porto il frame pointer alla fine dello stack, dove punta sp
		move $s6, $fp		   # in $s6 c'è l'inizio del mio array
                move $fp,$s6 	           # metto fp all'inizio per stampare la prima sequenza

		la $t8, inizioArray	   # carico in t8 l'indirizzo di inizioArray
		sw $s6, 0($t8)		   # scrivo l'indirizzo dell'inizio del mio array presente in stack

		la $t8, fineArray	   # carico in t8 l'indirizzo di fineArray
		sw $s7, 0($t8)		   # scrivo l'indirizzo della fine del mio array presente in stack

# stampa la sequenza appena immessa dall'utente

                li $v0, 4	     	   # carico 4 in $v0
		la $a0, prima	     	   # carico in $a0 l'indirizzo di prima
		syscall			   # stampo prima
		move $a2, $s6		   # passo come parametri alla procedura di stampa l'inizio e la fine del mio array
		move $a1, $s7	
		jal stampa		   # stampo la sequenza tramite procedura
		
  		move $a1, $s0              # passo N come parametro per la procedura ricorsiva
      		jal ricorsione             # chiamata a ricorsione(N)

# uscita dal programma
exit:		

                li $v0 , 10		   # carico in v0 10, il codice di uscita
		syscall			   # esco





# ricorsione #
ricorsione:
      		addi $sp, $sp, -4            # alloco 4 Byte in stack
    		sw $ra, 0($sp)               # memorizzo l'indirizzo di ritorno nello stack
      		li $t1, 1                    # $t1 <-- 1
      		bgt $a1,$t1,corpo_ricorsione # TEST: se $a1 è maggiore di 1, allora devo procedere con la ricorsione
      		j end_ricors                 # altrimenti vai alla fine della ricorsione

corpo_ricorsione:
      		addi $a1, $a1, -1            # N <-- N - 1
      		jal ricorsione               # chiamata a ricorsione(N - 1)


# In setting viene eseguito un ciclo for per prelevare ogni coppia, calcolarne la distanza, e viene assegnato un flag_posizione della coppia interessata
		
		la $t8, indN		     # carico in $t8 l'indirizzo di indN
		lw $t0, 0($t8)		     # metto in t0 N
		move $t3, $t0		     # uso t3 come contatore per determinare la posizione della coppia caricata correntemente
		la $t8, fineArray	     # carico in t8 l'indirizzo di fineArray
		lw $a1, 0($t8)		     # carico in a1 l'indirizzo della fine del mio array
      		addi $a1,$a1,-4		     # diminuisco il riferimento alla posizione dell'array finale di 4 in modo da prendere N-1 coppie:
					     # l'ultimo intero immesso deve solo essere considerato come secondo dato della N-1 coppia
setting:
		beq $fp, $a1, prelievo	     # se ho raggiunto Top of stack - 4byte, interrompo il ciclo 
      		lw $a2, 0($fp)		     # carico in $a2 il primo dato dell'array
		addi $fp, $fp, 4	     # sposto $fp al dato successivo
		lw $a3, 0($fp)		     # carico in $a3 il secondo dato dell'array : ora nei registri a2 e a3 ci sono i parametri per calc_dist
		jal calc_dist		     # al ritorno dalla procedura, in $v0 si trova la distanza della prima coppia
		beq $t3,$t0, primo_flag      # se il contatore è uguale a N allora deve saltare a primo_flag
		bge  $v0,$t5 salto_flag      # se la nuova distanza è maggiore o uguale allora salto a salto_flag per ripetere il ciclo
					     # perchè tengo quella già presente, ovvero quella della coppia di sinistra.
		move $t5,$v0                 # sostituisco con la nuova distanza minore
		move $t6,$t3                 # imposto un nuovo contatore, flag_posizione, che indica la posizione della coppia la cui distanza è la minore
               	addi $t3,$t3,-1              # diminuisco il contatore 
           	j setting		     # ripeto il mio ciclo sino a che non ho esaminato tutte le coppie

# In primo_flag viene viene presa SOLO la distanza della prima coppia dell'array in modo da stabilire un primo flag_posizione
primo_flag:    
		move $t5,$v0                 # sposto il risultato della distanza in $t5
                move $t6,$t3                 # imposto un flag_posizione: ora $t6 vale quanto N
                addi $t3,$t3,-1              # diminuisco il contatore 
	        j setting		     # ritorno a setting

# In salto_flag le coppie con la distanza maggiore vengono scartate evitando così di modificare flag_posizione
salto_flag:    
                addi $t3,$t3,-1              # diminuisco il contatore 
	        j setting		     # ritorno a setting

# In prelievo viene calcolato l'offset di fp tramite flag_posizione per il prelevamento della coppia con la distanza minore
prelievo:
	        sub $t6,$t0,$t6              # ottengo la posizione della coppia
		la $t8, inizioArray	     # carico in t8 l'indirizzo di inizioArray
		lw $a2, 0($t8)		     # carico in a2 l'indirizzo dell'inizio del mio array
                move $fp,$a2                 # ripristino fp all'inizio dell'array 
	        mul $t2,$t6,$t4              # calcolo l'offset con cui arrivo alla coppia desiderata
	        add $fp,$fp,$t2              # sposto fp a seconda dell'offset calcolato
	        lw $a2,0($fp)                # carico il primo intero della coppia presente nell'offset
	        addi $fp,$fp,4               # aumento di 4 fp in modo da prendere il numero successivo e formare la coppia con la distanza minore
	        lw $a3,0($fp)                # carico il secondo numero della coppia: ora nei registri a2 e a3 ci sono i parametri per calc_media
                   
# calcolo della media #
media:
		jal calc_media		     # al ritorno dal calc_media, in v0 c'è la media dei due interi
 		addi $fp,$fp,-4		     # porto il puntatore al primo dato della coppia la cui distanza è minore
		sw $v0,0($fp)		     # sovrascrivo la media dove c'era il primo intero della coppia in esame
                
		li $t7,2		     # carico 2 in t7: $t7 è un flag che serve per capire quando fp è arrivato al penultimo numero
		addi $a1,$a1,4		     # ripristino l'indirizzo finale dell'array in modo da tenere conto di tutti i numeri nella sequenza
                add $t6,$t0,$t6		     # ripristino flag_posizione, che ho decrementato in prelievo
		beq $t0,$t7, riduci_stack    # test per l'ultimo ciclo di ricorsione: se N=2 salto il ciclo di sostituzione_dati, 
					     # avendo ormai la media dei due numeri rimasti. Riduco lo stack e stampo

# sostituzione_dati è un ciclo che prende il numero a destra della coppia con la distanza minore
# e lo sostituisce con l'intero successivo, in modo da scalare l'array
sostituzione_dati:
		beq $fp, $a1, riduci_stack   # test tra valore corrente di fp e la fine dell'array, quando sono uguali esci dal ciclo
		beq $t6,$t7, media_unica     # test che determina se la coppia sostituita è quella finale dell'array
		addi $fp,$fp,8		     # porto il puntatore al primo dato della coppia successiva	
		lw $v0,0($fp)		     # carico il primo intero della coppia successiva
		addi $fp,$fp,-4		     # porto il puntatore al secondo dato della coppia corrente, la cui distanza è la minore
		sw $v0,0($fp)		     # sovrascrivo	
		j sostituzione_dati          # ripeto il ciclo di sostituzione

# media_unica è un label con all'interno dei passi che evitano l'overflow dello stack, richiamata soltanto quando la coppia da sostituire è l'ultima dell'array
media_unica:
		addi $fp,$fp,4		     # porto il puntatore al primo dato della coppia successiva	
		lw $v0,0($fp)		     # carico il primo intero della coppia successiva
		addi $fp,$fp,-4		     # porto il puntatore al secondo dato della coppia corrente, la cui distanza è la minore
		sw $v0, 0($fp)		     # sovrascrivo

# in riduci_stack si riduce l'array di una posizione, dopo che è stato scalato di una posizione a sinistra
riduci_stack:
		la $t8, inizioArray	     # carico in t8 l'indirizzo di inizioArray
		lw $a2, 0($t8)		     # carico in a2 l'indirizzo dell'inizio del mio array
                move $fp,$a2                 # ripristino fp all'inizio dell'array 
                addi $t0, $t0, -1	     # decremento gli N valori che ho in sequenza
		la $t8, indN		     # carico in $t8 l'indirizzo di indN
		sw $t0, 0($t8)		     # aggiorno in data il nuovo N che ho decrementato perchè ho un valore in meno rispetto al precedente passo di ricorsione
	        addi $a1,$a1,-4		     # diminuisco la posizione dell'array finale di 4 in modo da prendere N-1 coppie
		la $t8, fineArray	     # carico in t8 l'indirizzo di fineArray
		sw $a1, 0($t8)		     # aggiorno nell'area dati l'indirizzo corrente che punta alla fine del mio array, che ho appena decrementato di una posiz.
                
# stampa dell'array #
		li $v0, 4	     	     # carico 4 in $v0
		la $a0, iterazione   	     # carico in $a0 l'indirizzo di iterazione
		syscall		     	     # stampo messaggio di input a schermo
                jal stampa		     # stampo la sequenza tramite procedura: ora nei registri a1 e a2 ci sono i parametri per stampa
		                             # ovvero gli indirizzo di fine e inizio array

end_ricors:
     		lw $ra, 0($sp)               # carico in $ra l'indirizzo di ritorno alla procedura ricorsiva
      		addi $sp, $sp, 4             # dealloco 4 Byte
      		jr $ra                       # ritorno al chiamante







# " Elenco delle procedure utilizzate " #


# Procedura che calcola la media dei valori passati come argomenti
calc_media:                                 
		add $v0, $a2, $a3	     # faccio la somma dei due parametri in v0
		li $a0, 2		     # carico 2 in un registro temporaneo
		div $v0, $v0, $a0	     # divido la somma, e metto la media finale in v0
      		jr $ra			     # torno al chiamante


# Procedura che calcola la distanza dei due numeri
calc_dist:       			    
		sub $v0, $a2, $a3            # metto in v0 la differenza dei due parametri
		abs $v0, $v0		     # tengo il valore assoluto( essendo la distanza |b-a| )
      		jr $ra			     # torno al chiamante


# Procedura di lettura
lettura: 	li $a3 , 0           	     # salvo 0 in $a3, che userò come contatore nel for_lettura	

for_lettura: 	
		li $v0 , 4	             # carico 4 in $v0
		la $a0 , richiesta           # carico in $a0 l'indirizzo di richiesta
		syscall		             # stampo messaggio di richiesta a schermo
		li $v0 , 5                   # carico in $v0 il codice per la lettura di un intero da input 
	        syscall                      # chiamata per la lettura dell'intero inserito dall'utente
		sw $v0, 0($fp)               # memorizzo il numero in cima allo stack
      		addi $fp, $fp, 4   	     # mi sposto in stack 4 byte, per scrivere la wrod successiva
		addi $a3, $a3, 1             # incremento il numero di valori rimasti da inserire
     		bne $a3, $a2, for_lettura    # TEST: se il contatore è diverso da N allora ho altri numeri da inserire
		li $a3,0		     # resetto $a3
		li $v0, 4	     	     # carico 4 in $v0
		la $a0, capo	     	     # carico in $a0 l'indirizzo di capo
		syscall			     # vado a capo
		jr $ra			     # torno al chiamante


# Procedura di stampa
stampa:
		beq $fp, $a1, exit_sequenza  # test tra valore corrente di fp e la fine dell'array, quando sono uguali esci dal ciclo
               	lw $a0, 0($fp)		     # carico il dato cui punta fp
		li $v0, 1		     # carico 1 in v0, il codice per una read int
		syscall			     # stampa a schermo dell'intero
		addi $fp, $fp, 4	     # punto all'intero successivo
		li $v0, 4 		     # carico 4 in $v0
		la $a0, spazi 		     # carico in $a0 l'indirizzo di spazi
		syscall 		     # stampo messaggio di input a schermo
		j stampa		     # ripeto il ciclo di stampa
		
# label che si raggiunge dopo l'uscita dal ciclo della stampa immessa dall'utente
# qui si ripristina fp all'inizio e si fa una chiamata syscall per mandare a capo
exit_sequenza:  
		move $fp,$a2		     # riporto il mio framepointer all'inizio dell'array
	        li $v0, 4	     	     # carico 4 in $v0
		la $a0, capo	     	     # carico in $a0 l'indirizzo di capo
		syscall			     # vado a capo nella stampa
		jr $ra			     # torno al chiamante