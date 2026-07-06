.intel_syntax noprefix
.global _start
.global atoi_digit
.global atoi
.global itoa_digit
.global itoa

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

    mov rax , [rsp]
    mov rdi , [rsp+16]
    mov r10 , 8
   
    sub rsp , 1024
    xor rcx , rcx

    loopwrite:
       mov al , byte ptr [rdi]
       
       cmp al , 0
       je final
       
       cmp al , 0x5c
       je check_special

       cmp al , 0x25
       jne write1

       check_format:
       mov al , byte ptr [rdi+1]
       cmp al , 0x25
       je format
       cmp al , 0x73
       je string
       cmp al , 0x64
       jne write1
       
       decimal:
       mov r8, rdi
       mov r9 , rcx
       mov rdx , [rsp+1024+r10+16]
       mov rdi , rdx 
       call atoi
       mov rdi , rax
       lea rsi , [rsp+r9]
       call itoa
       mov rcx , r9
       mov rdi , r8
       add rdi , 2
       add rcx , rax
       add r10, 8
       jmp loopwrite

       string:
       mov rdx , [rsp+1024+r10+16]
       loops:
       mov al , byte ptr [rdx]
       cmp  al , 0
       je next
       mov byte ptr [rsp+rcx] , al
       inc rcx
       inc rdx
       jmp loops
       next:
       add r10, 8
       add rdi , 2
       jmp loopwrite

       format:
       add rdi , 2
       jmp write0
       
       check_special:
       mov al , byte ptr [rdi+1]
       cmp al , 0x5c
       je backslash
       cmp al , 0x78
       je hex
       cmp al , 0x6e
       jne write1
      
       newline:
       mov al , 0x0a
       add rdi , 2
       jmp write0

       hex:
       
       mov r8b , byte ptr [rdi+2]
       mov r9b , byte ptr [rdi+3]
       cmp r8b , 0x60
       jg alpha8
       jle digit8


       digit8:
       
       sub r8b , 0x30
       
       shl r8b , 4
       
       and r8b , 0xf0
       
       xor al , al
       mov al , r8b
       jmp cmp2
       
       alpha8:
       
       sub r8b , 0x61
       add r8b , 10
       
       shr r8b , 4
       and r8b , 0xf0
       
       xor al , al
       mov al , r8b 
       
       jmp cmp2
       

       cmp2:
       
       cmp r9b , 0x60
       jg alpha9
       jle digit9

       digit9:
       
       sub r9b , 0x30
       
       and r9b , 0x0f
       
       xor dl , dl
       mov dl , r9b
       jmp fff

       alpha9:
       
       sub r9b , 0x61
       add r9b , 10
       and r9b , 0x0f
       xor dl , dl
       mov dl , r9b 
       jmp fff

       fff:
       
       or al , dl
       add rdi , 4
       jmp write0

      

       backslash:
       add rdi , 2
       jmp write0

      write1:
       mov byte ptr [rsp+rcx] , al
       inc rdi
       inc rcx 
       jmp loopwrite
       
       write0:
       mov byte ptr [rsp+rcx] , al
       back:
       inc rcx 
       jmp loopwrite
       

    final:
    mov rsi , rsp
    mov rdi , 1
    mov rdx , rcx
    mov rax , 1
    syscall
    mov rdi , 0
    mov rax , 60
    syscall  