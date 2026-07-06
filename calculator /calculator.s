.intel_syntax noprefix
.global atoi_digit
.global atoi
.global itoa_digit
.global itoa
.global _start
atoi_digit:
   movzx rax , byte ptr [rdi]
   sub rax , 0x30
   ret

itoa_digit:
   xor rax , rax 
   mov al , dil
   add al , 0x30
   ret

itoa:
   push rbx
   push rbp
   push r14
   xor rdx , rdx 
   xor r14 , r14
   mov rax , rdi
   mov rbp , 0
   mov rbx , 0
   mov rcx , 10
   
   cmp  rdi , 0
   jge make 
   is_negative :
   mov byte ptr [rsi], 0x2d
   add rsi , 1
   neg rax 
   mov r14 , 1

   jmp make
   make :
   cmp rax , 0 
   jne loop2
   mov byte ptr [rsi], 0x30
   mov rdx , 1
   jmp owa1
  
   xor rdi , rdi
   loop2:
   cmp  rax  , 0 
   je fin
   xor rdx , rdx
   div rcx
   mov rbx , rax
   mov rdi , rdx
   
   call itoa_digit
   
   push rax
   inc rbp
   mov rax , rbx
   jmp loop2
   
   fin:
   mov rax , rbp
   xor rdx , rdx 
   
   loopbuff:
    cmp rdx, rax
    je owa
    pop rdi
    mov byte ptr [rsi+rdx], dil
    inc rdx 
    jmp loopbuff

   owa:
   cmp r14 , 1
   jne owa1
   inc rdx 
   sub rsi , 1
   owa1:
   mov rax , rdx 
   mov byte ptr [rsi+rax], 0
    pop r14
    pop rbp
    pop rbx 
    ret
  

  

atoi :
   mov rcx ,0
   mov rsi, 0
   cmp  byte ptr [rdi], 0x2d
   jne loop
   mov rsi , 1
   inc rdi

   loop:
   call atoi_digit
   cmp rax , 9
   ja finish
   imul rcx , 10
   add rcx , rax 
   inc rdi
   jmp loop
   
   finish:
   mov rax , rcx 
   cmp  rsi , 1
   jne owata
   neg rax
   owata:
   ret

_start:
   init:
   mov rax , [rsp]
   mov rcx , [rsp+16]
   mov rdi , [rsp+24]
   cmp rax , 3
   je unary
   mov rdx, [rsp+32]
   sub rsp , 0x80
   
   movzx rax , byte ptr [rdi]
   cmp al , 0x2b
   je operate
   cmp al , 0x2d
   je operate
   cmp  al , 0x2a
   je operate
   cmp al , 0x26
   je operate
   cmp al , 0x7c
   je operate
   cmp  al , 0x5e
   jne out_with_error
   operate:
   push rax
   mov rdi , rcx
   push rdx 
   call atoi
   pop rdx
   mov rcx , rax
   mov rdi , rdx
   push rcx
   call atoi
   pop rcx
   pop rdx
   cmp dl , 0x2d
   je neg
   cmp dl , 0x2a
   je multip
   cmp dl , 0x26
   je bitwiseAND
   cmp dl , 0x7c
   je bitwiseOR
   cmp dl , 0x5e
   je bitwiseXOR
   
   addition:
   add rcx , rax
   jmp after
   
   bitwiseAND:
   and rcx , rax 
   jmp after
   
   bitwiseOR:
   or rcx , rax 
   jmp after
  
   bitwiseXOR:
   xor rcx , rax
   jmp after
   
   multip:
   imul rcx , rax 
   jmp after
   
   neg:
   sub rcx , rax
   jmp after

   unary:
   movzx rdx , byte ptr [rcx]
   push rdx 
   call atoi
   pop rdx
   mov rcx , rax
   cmp dl , 0x7e
   je bitwiseNOT
   cmp  dl , 0x2d
   je negate
   

   negate:
   neg rcx 
   jmp after

   bitwiseNOT:
   not rcx
   jmp after

   after:
   mov rdi , rcx
   mov rsi , rsp
   call itoa
   mov rdi, 1
   mov rsi , rsp
   mov rdx , rax
   mov rax , 1
   syscall
   kayri:
   add rsp, 0x80
   mov rdi , 0
   mov rax , 60
   syscall
   out_with_error:
    add rsp, 0x80
    mov rdi , 1
    mov rax , 60
    syscall