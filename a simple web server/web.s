.intel_syntax noprefix
.global _start

parse_path:
      push rbx 
      mov rbx , 0 
   
   loop:
      mov al , byte ptr [rdi+rbx]
      cmp al , 0x20
      je finla
      inc rbx
      jmp loop

   finla:
      mov byte ptr [rdi+rbx] , 0
      pop rbx 
      ret

header_len:

    xor rcx , rcx 
    xor rdx , rdx
    
    loop_parser:
    mov ecx , dword ptr [rdi+rdx]
    cmp  ecx   , 0x0a0d0a0d
    je parse
    cmp rdx , r12
    je qu
    inc rdx
    jmp loop_parser

    parse:
    add rdx, 4
    lea rdi , [rdi+rdx]
    mov r11 , rdi 
    sub r12 , rdx
    mov rax , r12
    qu: 
    ret

    


_start:
   create_socket:
   mov rdi , 2
   mov rsi , 1
   mov rdx , 0
   mov rax , 41
   syscall
   mov r8 , rax
  
   bind:
   mov rdi, rax
   lea rsi , [rip+server_adress]
   mov rdx , 16
   mov rax , 49
   syscall
   
   listen:
   mov rdi , r8
   mov rsi , 0
   mov rax , 50
   syscall 

   accept_loop:  
   accept:
   mov rdi, r8
   mov rsi , 0
   mov rdx , 0
   mov rax , 43
   syscall
   mov r9 , rax
   
   fork:
   mov rax , 57
   syscall
   cmp rax , 0
   jz handel_client
   jl exit
   
   parent_process:
   close2:
   mov rdi , r9
   mov rax , 3
   syscall
   jmp accept_loop

   handel_client:  
   close_sockfd:
   mov rdi , r8
   mov rax , 3
   syscall
   
   read:
   sub rsp , 1024
   mov rdi , r9
   mov rsi , rsp
   mov rdx , 1024
   mov rax , 0
   syscall
  
   save_request_len:
   mov r12 , rax 
   
   cmp byte ptr [rsp] , 0x50
   je POST

   GET:
   parsing:
   lea rdi, [rsp+4]
   call parse_path
   open:
   lea rdi , [rsp+4]
   mov rsi , 0
   mov rax , 2
   syscall
   mov r8 , rax

   read1:
   mov rdi , r8
   mov rsi , rsp
   mov rdx , 1024
   mov rax , 0
   syscall
   mov r10 , rax 
   
   close:
   mov rdi , r8
   mov rax , 3
   syscall
   
   write:
   mov rdi , r9
   lea rsi , [rip+buffer]
   mov rdx , 19
   mov rax , 1
   syscall

   write1:
   mov rdi , r9
   mov rsi , rsp
   mov rdx , r10
   mov rax , 1
   syscall
   jmp exit

   POST:
   parsing1:
   lea rdi, [rsp+5]
   call parse_path
 
   open_path:
   lea rdi, [rsp+5]
   mov rsi , 65
   mov rdx , 0777
   mov rax , 2
   syscall
   mov r8 , rax

   lea rdi , [rsp]
   call  header_len
   
   write_data:
   mov rsi , r11
   mov rdi , r8
   mov rdx , rax
   mov rax , 1
   syscall

   close3:
   mov rdi , r8
   mov rax , 3
   syscall
  
   write_ok:
   mov rdi , r9
   lea rsi , [rip+buffer]
   mov rdx , 19
   mov rax , 1
   syscall
  
   exit:
   mov rdi, 0
   mov rax , 60
   syscall
   
   server_adress:
     .word 2
     .word 0x5000
     .long 0
     .quad 0
   buffer:
  .asciz "HTTP/1.0 200 OK\r\n\r\n"