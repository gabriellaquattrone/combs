#Creator: Gabriella Quattrone
#Date: July 23, 7:37 AM
.global get_combs
.equ ws, 4
helper:
    push %ebp
    movl %esp, %ebp
    
    push %ebx
    push %esi
    push %edi
    #save regs
    
    .equ num,      (2*ws)
    .equ select,   (3*ws)
    .equ len,      (4*ws)
    .equ maxSelect,(5*ws)
    .equ counter,  (6*ws)
    .equ share,    (7*ws)
    .equ result,   (8*ws)
    .equ items2,   (9*ws)

    
    if:
    movl counter(%ebp), %ecx
    movl (%ecx), %ecx #could be ws #####check here
    movl select(%ebp), %eax
    cmpl maxSelect(%ebp), %eax
    jnz else
   
    movl $0, %edx #int i = 0
    for:
    cmpl maxSelect(%ebp), %edx
    jge outside_for
    movl result(%ebp), %ebx#result
    movl (%ebx, %ecx, ws), %ebx#result[*counter]
    movl share(%ebp), %esi
    movl (%esi, %edx, ws), %esi #share[i]
    movl %esi, (%ebx, %edx, ws) #result[*counter][i] = share[i]
    ##movl %ebx, result(%ebp)
    incl %edx
    jmp for
    outside_for:
    incl %ecx ###check here also check i
    movl counter(%ebp), %eax
    movl %ecx, (%eax)
    jmp end 
    
    else:
    movl num(%ebp), %ebx #edx = i
    else_for:
    cmpl len(%ebp), %ebx
    jge end
    movl share(%ebp), %esi #esi = share
    movl select(%ebp), %edi #edi = select
    movl items2(%ebp), %edx
    movl (%edx, %ebx, ws), %edx #items2[i]
    movl %edx, (%esi, %edi, ws) #share[select]
    
    push items2(%ebp)
    push result(%ebp)
    push share(%ebp)
    push counter(%ebp)
    push maxSelect(%ebp)
    push len(%ebp)
    
    incl %edi
    push %edi
    incl %ebx
    push %ebx
    call helper
    addl $(ws*8), %esp
    jmp else_for
end:
    #movl result(%ebp), %eax
    pop %edi
    pop %esi
    pop %ebx
    movl %ebp, %esp
    pop %ebp
    ret 
get_combs:
    #prologue
        push %ebp
	movl %esp, %ebp
	subl $(4*ws), %esp # four local variables
	
	push %esi
	push %ebx
	push %edi	

	.equ items,    (2*ws) #(%ebp) int*
	.equ k,        (3*ws) #(%ebp) int 
	.equ len,      (4*ws) #(%ebp) int
	.equ counter,  (-1*ws)#(%ebp) int
	.equ numCombs, (-2*ws)#(%ebp) int
	.equ temp,     (-3*ws)#(%ebp) int
	.equ result,   (-4*ws)#(%ebp) int**

	movl $0, counter(%ebp) #int counter = 0;
	push k(%ebp)	
	push len(%ebp)
	call num_combs
	movl %eax, numCombs(%ebp) #int numCombs = num_combs(len, k);
        addl $(2*ws), %esp
	
	movl k(%ebp), %ebx
	shll $2, %ebx
	push %ebx
        call malloc
        addl $(1*ws), %esp
        movl %eax, temp(%ebp)
	
	#int** result = (int**)malloc(sizeof(int*) * numCombs); 
	movl numCombs(%ebp), %ecx
	shll $2, %ecx
	push %ecx
	call malloc
	addl $(1*ws), %esp #clear argument
	movl %eax, result(%ebp)
	
	#FOR LOOP#
	#for (int i = 0; i < numCombs; i++)#
	movl $0, %ebx #int i = 0
	
	start_for:
	cmpl numCombs(%ebp), %ebx #i - numCombs < 0
	jge end_loop
	
	#result[i] = (int*)malloc(sizeof(int)*k);
	movl k(%ebp), %edi
	shll $2, %edi
	push %edi
	call malloc
	addl $(1*ws), %esp
	movl result(%ebp), %ecx
	movl %eax, (%ecx, %ebx, ws) #result[i] = eax

	incl %ebx
	jmp start_for
	end_loop:
	#helper(0, 0, len, k, &counter, temp, result, items);
	push items(%ebp)
	push result(%ebp)
	push temp(%ebp)

	leal counter(%ebp), %eax
        push %eax


	push k(%ebp)
	push len(%ebp)
	push $0
	push $0
	call helper
	#movl %eax, result(%ebp)
        addl $(8*ws), %esp
        #movl result(%ebp), %eax
end_combs:
    pop %edi
    pop %ebx
    pop %esi
    movl result(%ebp), %eax
epilogue:
    movl %ebp, %esp
    pop %ebp
    ret
