.section .data
INPUT_BUFFER_SIZE = 128
OUTPUT_BUFFER_SIZE = 128
input_buffer: .space INPUT_BUFFER_SIZE
output_buffer: .space OUTPUT_BUFFER_SIZE
input_position: .quad 0
output_position: .quad 0

.section .bss
.comm stdin, 8
.comm stdout, 8

.section .text
.global inImage
.global getInt
.global getText
.global getInPos
.global setInPos
.global outImage
.global putInt
.global putText
.global putChar
.global getOutPos
.global setOutPos

.extern fgets
.extern puts
.extern printf  # For debugging purposes, can be removed later
.extern exit    # For debugging purposes, can be removed later

# Funktion: inImage
inImage:
    pushq %rbp
    movq %rsp, %rbp

    # Reset input position
    movq $0, input_position

    # Load arguments for fgets
    leaq input_buffer, %rdi
    movq $INPUT_BUFFER_SIZE, %rsi
    movq stdin(%rip), %rdx  # Assuming stdin is initialized elsewhere

    call fgets

    popq %rbp
    ret

# Funktion: getInt
getInt:
    pushq %rbp
    movq %rsp, %rbp

.getInt_start:
    # Check if input buffer is empty or at the end
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getInt_call_inImage
    cmpq $0, %rax
    je .getInt_call_inImage
    leaq input_buffer, %rdi
    addq %rax, %rdi
    cmpb $0, (%rdi)
    je .getInt_call_inImage

.getInt_parse:
    movq input_position, %rax
    leaq input_buffer, %rsi
    addq %rax, %rsi
    movq $0, %rcx  # Result
    movq $1, %r8   # Sign multiplier (default positive)

.getInt_skip_whitespace:
    movzbq (%rsi), %rdx
    cmpq $' ', %rdx
    jne .getInt_check_sign
    incq %rsi
    incq input_position
    cmpq $INPUT_BUFFER_SIZE, input_position
    jge .getInt_end  # End of buffer
    jmp .getInt_skip_whitespace

.getInt_check_sign:
    movzbq (%rsi), %rdx
    cmpq $'-', %rdx
    je .getInt_negative
    cmpq $'+', %rdx
    je .getInt_positive
    jmp .getInt_parse_digits

.getInt_negative:
    movq $-1, %r8
    incq %rsi
    incq input_position
    jmp .getInt_parse_digits

.getInt_positive:
    incq %rsi
    incq input_position
    jmp .getInt_parse_digits

.getInt_parse_digits:
    movzbq (%rsi), %rdx
    cmpq $'0', %rdx
    jl .getInt_end  # Not a digit
    cmpq $'9', %rdx
    jg .getInt_end  # Not a digit

    subq $'0', %rdx
    imulq $10, %rcx
    addq %rdx, %rcx
    incq %rsi
    incq input_position
    jmp .getInt_parse_digits

.getInt_call_inImage:
    call inImage
    jmp .getInt_start

.getInt_end:
    imulq %r8, %rcx  # Apply sign
    movq %rcx, %rax
    popq %rbp
    ret

# Funktion: getText
getText:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r12  # buf
    movq %rsi, %r13  # n
    movq $0, %r14    # count of copied characters

.getText_start:
    # Check if input buffer is empty or at the end
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getText_call_inImage
    leaq input_buffer, %rdi
    addq %rax, %rdi
    cmpb $0, (%rdi)
    je .getText_call_inImage

.getText_copy_loop:
    cmpq $0, %r13      # Check if n is 0
    je .getText_end

    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getText_end  # Reached end of input buffer

    leaq input_buffer, %rsi
    addq %rax, %rsi
    movzbq (%rsi), %rcx
    movb %cl, (%r12)

    incq %r12
    incq input_position
    incq %r14
    decq %r13
    jmp .getText_copy_loop

.getText_call_inImage:
    call inImage
    jmp .getText_start

.getText_end:
    movb $0, (%r12)  # Null-terminate the string
    movq %r14, %rax  # Return number of copied characters
    popq %rbp
    ret

# Funktion: getChar
getChar:
    pushq %rbp
    movq %rsp, %rbp

.getChar_start:
    # Check if input buffer is empty or at the end
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getChar_call_inImage
    leaq input_buffer, %rdi
    addq %rax, %rdi
    cmpb $0, (%rdi)
    je .getChar_call_inImage

    leaq input_buffer, %rsi
    movq input_position, %rax
    addq %rax, %rsi
    movzbq (%rsi), %rax
    incq input_position
    popq %rbp
    ret

.getChar_call_inImage:
    call inImage
    jmp .getChar_start

# Funktion: getInPos
getInPos:
    pushq %rbp
    movq %rsp, %rbp
    movq input_position, %rax
    popq %rbp
    ret

# Funktion: setInPos
setInPos:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax  # n

    cmpq $0, %rax
    jl .setInPos_clamp_low

    cmpq $INPUT_BUFFER_SIZE, %rax
    jg .setInPos_clamp_high

    movq %rax, input_position
    jmp .setInPos_end

.setInPos_clamp_low:
    movq $0, input_position
    jmp .setInPos_end

.setInPos_clamp_high:
    movq $INPUT_BUFFER_SIZE, input_position

.setInPos_end:
    popq %rbp
    ret

# Funktion: outImage
outImage:
    pushq %rbp
    movq %rsp, %rbp

    leaq output_buffer, %rdi
    call puts

    # Reset output position
    movq $0, output_position

    popq %rbp
    ret

# Funktion: putInt
putInt:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax  # n
    movq output_position, %rsi
    leaq output_buffer, %rdi # Base address of output buffer

.putInt_convert_loop:
    movq $0, %rdx
    movq $10, %rcx
    idivq %rcx
    addq $48, %rdx  # Convert remainder to ASCII
    pushq %rdx

    cmpq $0, %rax
    jnz .putInt_convert_loop

.putInt_output_loop:
    cmpq $OUTPUT_BUFFER_SIZE, output_position
    jge .putInt_flush_and_continue

    popq %rax
    movb %al, (%rdi,%rsi,1)
    incq %rsi
    movq %rsi, output_position # Update output_position

    cmpq $0, %rsp
    jnz .putInt_output_loop
    jmp .putInt_end

.putInt_flush_and_continue:
    call outImage
    movq $0, output_position
    jmp .putInt_output_loop

.putInt_end:
    popq %rbp
    ret

# Funktion: putText
putText:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rsi  # buf
    leaq output_buffer, %rdi # Destination buffer

.putText_copy_loop:
    movzbq (%rsi), %rax
    cmpb $0, %al
    je .putText_end

    cmpq $OUTPUT_BUFFER_SIZE, output_position
    jge .putText_flush

    movq output_position, %rcx
    movb %al, (%rdi,%rcx,1)
    incq output_position
    incq %rsi
    jmp .putText_copy_loop

.putText_flush:
    call outImage
    jmp .putText_copy_loop

.putText_end:
    popq %rbp
    ret

# Funktion: putChar
putChar:
    pushq %rbp
    movq %rsp, %rbp

    movb %dil, %al  # c
    leaq output_buffer, %rdi # Output buffer address

    cmpq $OUTPUT_BUFFER_SIZE, output_position
    jge .putChar_flush

    movq output_position, %rcx
    movb %al, (%rdi,%rcx,1)
    incq output_position
    jmp .putChar_end

.putChar_flush:
    call outImage
    movb %al, output_buffer
    movq $1, output_position

.putChar_end:
    popq %rbp
    ret

# Funktion: getOutPos
getOutPos:
    pushq %rbp
    movq %rsp, %rbp
    movq output_position, %rax
    popq %rbp
    ret

# Funktion: setOutPos
setOutPos:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax  # n

    cmpq $0, %rax
    jl .setOutPos_clamp_low

    cmpq $OUTPUT_BUFFER_SIZE, %rax
    jg .setOutPos_clamp_high

    movq %rax, output_position
    jmp .setOutPos_end

.setOutPos_clamp_low:
    movq $0, output_position
    jmp .setOutPos_end

.setOutPos_clamp_high:
    movq $OUTPUT_BUFFER_SIZE, output_position

.setOutPos_end:
    popq %rbp
    ret
