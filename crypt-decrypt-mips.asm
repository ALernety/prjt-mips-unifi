# Title:	Messaggi Cifrati				Filename: Progetto Assembly
# Authori:			Date: inizio 20/03/2019
# Matricole:	
# Description:	criptazione e decriptazione messaggi di testo
# Input:	messaggio.txt, chiave.txt
# Output:	messaggioCifrato.txt, messaggioDecrifato.txt
################# Data segment #####################
.data
message:	.asciiz "~/Downloads/prjt-mips-unifi/messaggio.txt"		# file in input
keyword:	.asciiz "~/Downloads/prjt-mips-unifi/chiave.txt"		# file di chiave
msgCifrato:	.asciiz "~/Downloads/prjt-mips-unifi/messaggioCifrato.txt"	# file in output
msgDecifrato:	.asciiz "~/Downloads/prjt-mips-unifi/messaggioDecifrato.txt"	# file di messaggio decifrato

msg:		.space	73728					# alloco memoria che conterra' il messaggio in input
cache_msg:	.space	137					# alloco memoria che conterra' lettere che saranno in messaggio solamente 1 volta
key:		.space	4					# alloco memoria contenente la parola chiave
jump_tbl:	.word	5					# alloco memoria per realizare `switch-case`
################# Code segment #####################
.text
#Funzioni di algoritmi richiesti A,B,C,D,E per la criptazione/decriptazione del messaggio
########### Algoritmo A, B, C (unito) ##############
alg_a_b_c:
	lbu	$t1, msg + 0($a3)				# unica procedura per gli algoritmi A, B, C
	add	$t1, $t1, $a1
	sb	$t1, msg + 0($a3)				# effettuando lo sb otteniamo il modulo del valore ascii a cui abbiamo sommato 4
	add	$a3, $a3, $a2
	blt	$a3, $a0, alg_a_b_c				# finche' il contatore $a3 e' < stretto della dimensione dell'msg continuiamo ad iterare
	jr	$ra
################## Algoritmo D #####################
alg_d:
	addi	$a0, $a0, -1					# in $a0 e' presente il valore che indica la posizione dell'n-1 esimo elemento di msg
	lbu	$t1, msg + 0($a0)				# msg viene scandito dalla posizione n-1 fino alla posizione 0
	addi	$sp, $sp, -1
	sb	$t1, 0($sp)					# gli elementi di volta in volta vengono memorizzati nello stack di appoggio
	beqz	$a0, revertData					# salto se $a0 == 0, cioe letto e scritto primo carattero
	j	alg_d
revertData:
	lbu	$t1, 0($sp)					# lbu dallo stack, l'elemento prelevato viene memorizzato in msg a partire dal fondo
	addi	$sp, $sp, 1
	addi	$a1, $a1, -1
	sb	$t1, msg + 0($a1)
	bnez	$a1, revertData
	addi	$sp, $sp, 1
	jr	$ra
################## Algoritmo E #####################
alg_e:
	lbu	$t0, msg + 0($a1)			# $t0 = msg[indice]
	addi	$t6, $zero, 0				# $t6 = 0
	if_char_in_cache_msg:
		lbu	$t1, cache_msg + 0($t6)		# $t1 = cache_msg[counter]
		beq	$t0, $t1, add_counter_for_if	# Controlliamo se carattere in $t0 uguale a carattere in $t1 e in tal caso saltiamo
		beqz	$t1, ind_minore_di_len_continue	# E controlliamo se stringa gia finita, e in tal caso saltiamo
		addi	$t6, $t6, 1			# incrementiamo counter
		j if_char_in_cache_msg			
	add_counter_for_if:
		addi	$a1, $a1, 1			# indice++
		bne	$a1, $a0, alg_e			# se indice == lunghezza di messaggio usciamo da if
		addi	$a1, $zero, 0			# $a1 = 0
		addi	$sp, $sp, 1			# tolgiamo un spazzio che abbiamo aggiunto in fine stinga
		j	scrivi_in_msg
ind_minore_di_len_continue:
	addi	$sp, $sp, -1
	sb	$t0, 0($sp)				# aggiungo in stack carattere
	add	$t2, $zero, $a1				# e associo a $t2 posizione di quel carattere
	i_con_min_len:
		lbu	$t1, msg + 0($t2)		# $t1 = msg[indice di controllo]
		bne	$t0, $t1, i_con_min_len_conti	# if msg[indice] == msg[indice di controllo]:
		addi	$sp, $sp, -1
		addi	$t1, $zero, 45			# $t1 = "-"
		sb	$t1, ($sp)			# aggiungiamo trattino nello stack
		add	$t5, $zero, $t2			# spostiamo posizione attuale in $t5 per poter modificare
		addi	$t4, $zero, 0			# $t4 = 0 per utilizare come contatore in int_to_str
		addi	$t1, $zero, 10			# $t1 = 10 e divisore per int_to_str
		j	int_to_str			# saltiamo int_to_str(secCount)###non e una procedura, e praticamente un ciclo
	i_con_min_len_conti:
		addi	$t2, $t2, 1			# indice di controllo++
		bne	$t2, $a0, i_con_min_len		# controlliamo se indice di controllo arivato in fine stringa
	addi	$sp, $sp, -1
	addi	$t1, $zero, 32				# $t1 = " "
	sb	$t1, 0($sp)				# aggiungiamo uno spazio nello stack
	sb	$t0, cache_msg + 0($t6)			# aggiugo in cache_msg carattere che abbiamo aggiunto nello stack
	addi	$a1, $a1, 1				# Incrementiamo indice
	bne	$a1, $a0, alg_e				# Controlliamo se indice != a lunghezza di messaggio, e saltiamo in inizio di algoritmo
	addi	$a1, $zero, 0				# $a1 = 0
	addi	$sp, $sp, 1				# togliamo spazio che dovra essere tolto 
scrivi_in_msg:
	addi	$a2, $a2, -1				# Decrimento $a2 che contiene valore di $sp iniziale
	lbu	$t0, 0($a2)				# carico in $t2 carattere in posizione $a2
	sb	$t0, msg + 0($a1)			# e lo inserisco in posizione $a1 in msg
	addi	$a1, $a1, 1
	bge	$a2, $sp, scrivi_in_msg			# Controllo se $a2 uguale $sp, che significa che stringa finita
	add	$sp, $sp, $a1				# torno stack pointer a posto
	addi	$sp, $sp, -1
	add	$v0, $a1, 0				# sposto parametro per pulire cleaner_cache_msg
	addi	$t1, $zero, 0				# $t1 = 0
	addi	$t2, $zero, 137				# $t2 = 137 
cleaner_cache_msg:
	sb	$zero, cache_msg + 0($t1)		# scriviamo byte tutto a 0 in posizione $t1 di buffer cache_msg
	addi	$t1, $t1, 1
	bne	$t1, $t2, cleaner_cache_msg		# finche $t1 != 137 appliciamo quel algoritmo
	jr	$ra					# ritorniamo da procedura in main
######## Traduzione da intero a una stringa ########
int_to_str:						# Inizio
	div	$t5, $t1				# divido numero che voglio trasformare a 10
	mflo	$t3					# sposto in $t3 quoziente
	bnez	$t3, int_to_str_continue		# controllo se quoziente != 0 se vero salto
	mfhi	$t3					# sposto in $t3 resto
	addi	$t3, $t3, 48				# trasformo un intero in un charattere ascii
	addi	$sp, $sp, -1
	sb	$t3, ($sp)				# metto in stack carettere
replace:						# Da cache_msg in stack
	beqz	$t4, i_con_min_len_conti		# controllo se ho inseriti tutti caratteri in stack
	addi	$t4, $t4, -1
	lb	$t3, cache_msg + 132($t4)		# carico carattere
	addi	$sp, $sp, -1
	sb	$t3, ($sp)				# aggiungo carattere in stack
	j	replace
int_to_str_continue:
	add	$t5, $zero, $t3				# metto in posto di numero che vuolevo convertire quoziente
	mfhi	$t3					# sposto in $t3 resto
	addi	$t3, $t3, 48				# converto resto intero in un charattere ascii
	sb	$t3, cache_msg + 132($t4)		# e lo mettiamo in posto cache_msg + 132 + $t4
	addi	$t4, $t4, 1
	j	int_to_str
########### Algoritmo E decriptazione ##############
alg_e_r:
	addi	$t0, $zero, 0				# t0 = indice_di_carratere
	addi	$t4, $zero, 10				# $t4 = 10, serve per tradurrere da stringa a intero
	while_ind_minore_len:
		bge	$t0, $a0, fine_di_alg		# controlliamo se indice_di_carattere >= lunghezza - 1
		lb	$t1, msg + 0($t0)		# t1 = carratere
		addiu	$t0, $t0, 2			# aggiungo 2 a indice_di_carattere
	while_char_non_spazio:
		bgt	$t0, $a0, while_ind_minore_len	# controlliamo se indice_di_carattere >= lunghezza, allora salto 
		lb	$t3, msg - 1($t0)		# cariciamo elemento in posizione indice_di_carattere - 1
		addi	$t5, $zero, 32
		beq	$t3, $t5, while_ind_minore_len	# e confrontiamo quel carattere con spazio, se " " allora salto
		lb	$t2, msg + 0($t0)		# cariciamo carattere in $t2 (num)
		addi	$t2, $t2, -48			# convertiamo da stringa a intero
	while_non_trattino_non_spazio:
		bge	$t0, $a0, continue_while	# controlliamo se indice_di_carattere >= lunghezza - 1, se si saltiamo
		lb	$t3, msg + 1($t0)		# carichiamo un charattere in posizione $t0 + 1 in buffer msg
		addi	$t5, $zero, 45
		beq	$t3, $t5, continue_while	# e confrontiamolo con trattino, se trattino saltiamo in continue_while
		addi	$t5, $zero, 32
		beq	$t3, $t5, continue_while	# e confrontiamo un'altra volta con un spazio
		addi	$t0, $t0, 1			# poi incrementiamo indice_di_carattere
		addi	$t3, $t3, -48			# convertiamo da stringa a un intero
		mul	$t2, $t2, $t4			# e multipliciamo $t2 (num) per 10
		add	$t2, $t2, $t3			# aggiungiamo a num $t3
		j	while_non_trattino_non_spazio
	continue_while:
		sub	$sp, $sp, $t2			# saltiamo al posto in stack dove dovra essre carattere
		sb	$t1, -1($sp)			# e lo mettiamo carattere
		add	$sp, $sp, $t2			# torniamo stack pointer a posto
		addi	$t0, $t0, 2			# e aggiungiamo a indice_di_carattere, 2
		bge	$a1, $t2, while_char_non_spazio	# controlliamo se new_length >= num se vero saltiamo
		add	$a1, $zero, $t2			# senno aggiorniamo new_length con nuovo valore di $t2(num)
		j	while_char_non_spazio
fine_di_alg:
	addi	$v0, $a1, 2				# passiamo nuovo valore di lunghezza di stringa
	sub	$sp, $sp, $a1				# e mettiamo stack pointer a posto dove inizia stringa
	addi	$sp, $sp, -1
scrivi_in_msg_r:
	lb	$t1, ($sp)				# cariciamo valore dallo stack
	addi	$sp, $sp, 1
	sb	$t1, msg + 0($a1)			# e rimettiamo a suo posto in msg
	addi	$a1, $a1, -1
	bgez	$a1, scrivi_in_msg_r			# controlliamo se $a1 >= 0, e ripeto finche quel condizione vera
	jr	$ra					# e ritorniamo nel main

.globl main
###################### Main ########################
main:
	addi	$sp, $sp, -4	
	sw	$ra, 0($sp)			# salviamo in stack indirizo di fine programma

	la	$a0, message			
	li	$a1, 0
	li	$a2, 0
	li	$v0, 13				
	syscall					# apertura file che contiene il messaggio da cifrare
	move	$a0, $v0					
	la	$a1, msg	
	li	$a2, 129			# lettura di esattamente 128 caratteri (+ 1 per fine di stringa, senno poi perde 128esimo carattero)
	li	$v0, 14		
	syscall					# lettura dello contenuto del file messaggio
	move 	$t1, $v0			# salviamo nel registro $t1 il numero di caratteri letti da msg, in modo da usarlo come contatore
	li	$v0, 16				
	syscall					# e subito chudiamo file perche non ci serve aperto
 
	la	$a0, keyword			
	li 	$a1, 0
	li	$a2, 0
	li	$v0, 13				
	syscall					# apertura file contenente la chiave per criptare il messaggio
	move 	$a0, $v0			
	la	$a1, key
	li	$a2, 5				# lettura di esattamente 4 caratteri (+ 1 per fine di stringa, senno poi perde quarto carattero)
	li	$v0, 14		
	syscall					# lettura della chiave e la memorizzazione in un buffer a partire dall'indirizzo indicato da key
	move 	$a3, $v0			# salviamo nel registro $a3 il numero di caratteri letti da key, in modo da usarlo come contatore
	li	$v0, 16				
	syscall					# e subito chudiamo file perhce non ci serve aperto

# LEGGO LA CHIAVE
	addi	$t2, $zero, -1
	addi	$a3, $a3, -2			# tolgo 2 perche $a3 contiene n + byte di fine stringa + byte per conto da 1 invece di 0
	j	crea_jump_table			# creazione di jump table per rializare `switch-case`
read_key:
	beq	$t2, $a3, exit_crpt		# controllo se $t2 == lungheza di chiave, se si esci da criptazione
	addi	$t2, $t2, 1
	lbu	$a0, key + 0($t2)		# leggo carattero contenente in chiave
	addi	$a0, $a0, -65			# tolgo 65 per poter saltare a gusta posizione
	sll	$a0, $a0, 2			# multiplicazione per 4
	lw	$a0, jump_tbl + 0($a0)		# leggo posizione dove dovro saltare
	jr	$a0				# salto per posizione
exit_crpt:
	la	$a0, msgCifrato			
     	li	$a1, 1            
    	li	$a2, 0
	li	$v0, 13				
	syscall					# apertura file che contienera messaggio criptato
	move	$a0, $v0
	la	$a1, msg 				
	addi	$a2, $t1, -1			# scrivo esattamente n caratteri (se gia conteneva messaggio piu lungo, alcuni caratteri rimangono)
	li	$v0, 15		
	syscall					# genero in output il file che contiene il messaggio criptato
	li	$v0, 16
	syscall					# e subito chudiamo file perhce non ci serve aperto
	j	crea_jump_table_r
#LEGGO LA CHIAVE AL CONTRARIO PER DECRIFRARE IL MESSAGGIO; indirizzo di base di key è in $t2
read_key_reverse:
	bltz	$t2, exit_dcrp			# controllo se $t2 < 0 se vero usciamo da decriptazione
	lbu	$a0, key + 0($t2)		# leggo carattero contenente in chiave in ordine inverso
	addi	$t2, $t2, -1
	addi	$a0, $a0, -65			# tolgo 65 per poter saltare a gusta posizione
	sll	$a0, $a0, 2			# multiplicazione per 4
	lw	$a0, jump_tbl + 0($a0)		# leggo posizione dove dovro saltare
	jr	$a0				# salto per posizione
exit_dcrp:
	la	$a0, msgDecifrato		# genero in output il file che contiene il messaggio decrifrato
     	li	$a1, 1            
    	li	$a2, 0
	li	$v0, 13				
	syscall					# apertura file che contienera messaggio decifrato
	move	$a0, $v0
	la	$a1, msg 				
	addi	$a2, $t1, -1			# scrivo esattamente n caratteri (se gia conteneva messaggio piu lungo, alcuni caratteri rimangono)
	li	$v0, 15		
	syscall					# genero in output il file che contiene il messaggio decifrato
	li	$v0, 16
	syscall					# e subito chudiamo file perhce non ci serve aperto
	lw	$ra, 0($sp)			# ritorno puntatore per uscire da programma
	addi	$sp, $sp, 4			# torno puntatore di stack a posto
	jr	$ra				# uscita da programma

#incremento la posizione sul vettore, mi sposto di byte in byte

j_a:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo A di criptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, 4			# incrimentatore per carattero
        addi    $a2, $zero, 1			# incrimentatore per cambiare posizione
        addi    $a3, $zero, 0			# inizio di stringa
	
	jal	alg_a_b_c			# questo algoritmo cambia ogni carattero in modo `carattero = intToChar(asciiCode(carattero) + 4))`
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key			# ritorno a `switch-case`

j_b:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo B di criptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, 4			# incrimentatore per carattero
        addi    $a2, $zero, 2			# incrimentatore per cambiare posizione, 2 per spostare solo a caratteri in posizione pari
        addi    $a3, $zero, 0			# inizio di stringa
	
	jal	alg_a_b_c			# questo algoritmo cambia caratteri in posizioni pari
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key 			# ritorno a `switch-case`
 
j_c:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo C di criptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, 4			# incrimentatore per carattero
        addi    $a2, $zero, 2			# incrimentatore per cambiare posizione, 2 per spostare solo sul numeri dispari
        addi    $a3, $zero, 1			# inizio di stringa, 1 perche dobbiamo procedere solo sul numeri dispari
	
	jal	alg_a_b_c			# questo algoritmo cambia caratteri in posizioni pari
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key			# ritorno a `switch-case`

j_d:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo D di criptazione
	add	$a0, $zero, $t1			# passo lunghezza di stringa
	addi	$a1, $t1, -1			# tolgo 1 perche contiamo da 0, fino a n-1
	
	jal	alg_d				# questo algoritmo inverta messaggio
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key 			# ritorno a `switch-case`

j_e:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
	
	addi	$a0, $t1, -1			# passo lunghezza di messaggio - 1
	addi    $a1, $zero, 0                   # passo numero di posizione iniziale
	add	$a2, $zero, $sp			# salvo stack pointer per poi poter contare quante caratteri prodotto quel algoritmo
	
	jal	alg_e				# qusto algoritmo scrive carattero e sua posizione in messaggio
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	add	$t1, $zero, $v0			# sicche in questo algoritmo cambia lungheza di stringa, allora dovro passarla in $t1
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key			# ritorno a `switch-case`

j_a_r:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo A di decriptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, -4			# incrimentatore per carattero, -4 perche questo algoritmo inverso
	addi    $a2, $zero, 1			# incrimentatore per cambiare posizione
        addi    $a3, $zero, 0			# inizio di stringa
	
	jal	alg_a_b_c			# questo algoritmo cambia ogni carattero in modo `carattero = intToChar(asciiCode(carattero) - 4))`
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key_reverse		# ritorno a `switch-case`

j_b_r:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo B di decriptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, -4			# incrimentatore per carattero, -4 perche questo algoritmo inverso
        addi    $a2, $zero, 2			# incrimentatore per cambiare posizione, 2 per spostare solo a caratteri in posizione pari
        addi    $a3, $zero, 0			# inizio di stringa
	
	jal	alg_a_b_c			# questo algoritmo cambia caratteri in posizioni pari
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key_reverse		# ritorno a `switch-case`

j_c_r:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo C di criptazione
	add	$a0, $zero, $t1			# lungheza di stinga, quando dobbiamo fermare
	addi    $a1, $zero, -4			# incrimentatore per carattero, -4 perche questo algoritmo inverso
        addi    $a2, $zero, 2			# incrimentatore per cambiare posizione, 2 per spostare solo sul numeri dispari
        addi    $a3, $zero, 1			# inizio di stringa, 1 perche dobbiamo procedere solo sul numeri dispari
	
	jal	alg_a_b_c			# questo algoritmo cambia caratteri in posizioni dispari
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key_reverse		# ritorno a `switch-case`

j_d_r:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)
						# passaggio dei parametri per l'algoritmo D di criptazione
	add	$a0, $zero, $t1			# passo lunghezza di stringa
	addi	$a1, $t1, -1			# tolgo 1 perche contiamo da 0, fino a n-1
	
	jal	alg_d				# questo algoritmo inverta messaggio
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$t1, 16($sp)
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key_reverse		# ritorno a `switch-case`

j_e_r:	addi	$sp, $sp, -28			# salviamo tutti registri, che intendiamo usare in futuro, in stack prima di saltare in procedura
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$t1, 16($sp)
	sw	$t2, 20($sp)
	sw	$v0, 24($sp)

	addi	$a0, $t1, -2
	addi    $a1, $zero, 0                   
	
	jal	alg_e_r
	lw	$a0, 0($sp)			# riprendiamo tutti registri, che abbiamo salvato in stack prima di saltare in procedura
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	add	$t1, $v0, $zero			# sicche in questo algoritmo cambia lungheza di stringa, allora dovro passarla in $t1
	lw	$t2, 20($sp)
	lw	$v0, 24($sp)
	addi	$sp, $sp, 28
	j	read_key_reverse		# ritorno a `switch-case`
	
#Creazione di jump_table
crea_jump_table:				# creazione di jump table per criptazione
	la	$a0, j_a
	sw	$a0, jump_tbl + 0
 	la	$a0, j_b
	sw	$a0, jump_tbl + 4
	la	$a0, j_c
	sw	$a0, jump_tbl + 8
	la	$a0, j_d
	sw	$a0, jump_tbl + 12
	la	$a0, j_e
	sw	$a0, jump_tbl + 16
	j	read_key
crea_jump_table_r:				# creazione di jump table per decriptazione
	la	$a0, j_a_r
	sw	$a0, jump_tbl + 0
 	la	$a0, j_b_r
	sw	$a0, jump_tbl + 4
	la	$a0, j_c_r
	sw	$a0, jump_tbl + 8
	la	$a0, j_d_r
	sw	$a0, jump_tbl + 12
	la	$a0, j_e_r
	sw	$a0, jump_tbl + 16
	j	read_key_reverse
