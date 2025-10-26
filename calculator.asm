.intel_syntax noprefix
.global _start

.text

print_message: 
    mov rax, 1
    mov rdi, 1
    syscall
    ret

read_buffer:
    mov rax, 0
    mov rdi, 0
    syscall
    ret

convert_operand:
    xor rbx, rbx         
    mov rcx, 1           
    mov al, [rdx + rdi]
    
    cmp al, '-'          
    jne check_plus
    mov rcx, -1          
    inc rdi
    jmp parse_digits

check_plus:
    cmp al, '+'         
    jne parse_digits
    inc rdi

parse_digits:
    mov al, [rdx + rdi]
    cmp al, 10          
    je convert_return
    sub al, '0'
    cmp al, 9          
    ja convert_return    
    imul rbx, rbx, 10
    add rbx, rax
    inc rdi
    cmp rdi, 21
    jge print_error
    jmp parse_digits

convert_return:
    imul rbx, rcx   
    ret

_start:
    lea rsi, hello_str
    lea rdx, hello_str_len 
    call print_message

    lea rsi, request_operand_str
    lea rdx, request_operand_str_len
    call print_message

    lea rsi, first_operand_buffer
    mov rdx, 21
    call read_buffer

    xor rbx, rbx
    xor rdi, rdi
    lea rdx, first_operand_buffer
    call convert_operand
    mov [first_operand], rbx

    lea rsi, request_operator_str
    lea rdx, request_operator_str_len
    call print_message
  
    lea rsi, operator_buffer
    mov rdx, 2
    call read_buffer

    lea rsi, request_operand_str
    lea rdx, request_operand_str_len
    call print_message

    lea rsi, second_operand_buffer
    mov rdx, 21
    call read_buffer

    xor rbx, rbx
    xor rdi, rdi
    lea rdx, second_operand_buffer
    call convert_operand
    mov [second_operand], rbx

    mov al, [operator_buffer]
    cmp al, '+'
    je add_op
    cmp al, '-'
    je sub_op
    cmp al, '*'
    je mul_op
    cmp al, '/'
    je div_op
    jmp print_error

add_op:
    mov rax, [first_operand]
    add rax, [second_operand]
    jmp print_result

sub_op:
    mov rax, [first_operand]
    sub rax, [second_operand]
    jmp print_result

mul_op:
    mov rax, [first_operand]   
    imul rax, [second_operand] 
    jmp print_result

div_op:
    mov rax, [first_operand]
    mov rbx, [second_operand]
    test rbx, rbx
    jz print_error
    cqo
    idiv rbx   
    jmp print_result

print_result:
    lea rsi, [num_str+20]  
    mov byte ptr [rsi], 0x0A
    dec rsi
    
    mov rbx, rax          
    test rax, rax           
    jns convert_loop       
     
    neg rax                
    mov rbx, -1          

convert_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx                 
    add dl, '0'            
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz convert_loop
    
    cmp rbx, -1
    jne print_number
    dec rsi
    mov byte ptr [rsi], '-'

print_number:
    lea rdx, [num_str+20]   
    sub rdx, rsi            
    inc rdx               
    call print_message
    jmp exit

print_error:
    lea rsi, error_str
    lea rdx, error_len
    call print_message

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

.data 
hello_str: .ascii "~ASM Calculator~"
hello_str_len = . - hello_str

request_operand_str: .ascii "\nType the operand (64-bit number): "
request_operand_str_len = . - request_operand_str

request_operator_str: .ascii "\nType the operator (+ - * /): "
request_operator_str_len = . - request_operator_str

error_str: .ascii "\nInvalid input!\n"
error_len = . - error_str

first_operand_buffer: .skip 20, 0x00
second_operand_buffer: .skip 20, 0x00

first_operand: .quad 0x00
second_operand: .quad 0x00
operator_buffer: .skip 2, 0x00

num_str: .skip 21
