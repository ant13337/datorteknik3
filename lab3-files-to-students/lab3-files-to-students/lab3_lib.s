.section .data
INPUT_BUFFER_SIZE = 128
OUTPUT_BUFFER_SIZE = 128
input_buffer: .space INPUT_BUFFER_SIZE
output_buffer: .space OUTPUT_BUFFER_SIZE
input_position: .quad 0
output_position: .quad 0

format_inImage_entry: .asciz "inImage: Entering\n"
format_inImage_exit: .asciz "inImage: Exiting, input_buffer='%s', input_position=%ld\n"
format_getInt_entry: .asciz "getInt: Entering, input_position=%ld\n"
format_getInt_skip_space: .asciz "getInt: Skipping whitespace, input_position=%ld, char='%c'\n"
format_getInt_checksign: .asciz "getInt: Checking sign, input_position=%ld, char='%c'\n"
format_getInt_parsedigit: .asciz "getInt: Parsing digit, input_position=%ld, char='%c', accumulator=%ld\n"
format_getInt_exit: .asciz "getInt: Exiting, value=%ld, input_position=%ld\n"
format_getInt_call_inImage: .asciz "getInt: Calling inImage from getInt, input_position=%ld\n"
format_getint_endparse: .asciz "getInt: End parse, accumulator=%ld\n"

format_putInt_entry: .asciz "putInt: Entering, n=%ld\n"
format_putInt_handle_zero: .asciz "putInt: Handling zero\n"
format_putInt_flush_zero: .asciz "putInt: Flushing buffer for zero\n"
format_putInt_convert_loop: .asciz "putInt: Convert loop, remainder=%ld, quotient=%ld\n"
format_putInt_output_loop: .asciz "putInt: Output loop, char='%c', output_position=%ld\n"
format_putInt_flush_continue: .asciz "putInt: Flushing buffer and continuing\n"
format_putInt_exit: .asciz "putInt: Exiting\n"

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
.extern printf  # For debugging purposes
.extern exit    # For debugging purposes

# Funktion: inImage
inImage:
    pushq %rbp
    movq %rsp, %rbp

    leaq format_inImage_entry, %rdi
    call printf

    # Reset input position
    movq $0, input_position

    # Load arguments for fgets
    leaq input_buffer, %rdi
    movq $INPUT_BUFFER_SIZE, %rsi
    movq stdin(%rip), %rdx

    call fgets

    leaq format_inImage_exit, %rdi
    leaq input_buffer, %rsi
    movq input_position, %rdx
    call printf

    popq %rbp
    ret

# Funktion: getInt
getInt:
    pushq %rbp
    movq %rsp, %rbp

    # Logga start av getInt
    leaq format_getInt_entry, %rdi
    movq input_position, %rsi
    call printf

    # Start av getInt-rutinen
.getInt_start:
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getInt_call_inImage  # Bufferten är slut, fyll på med inImage

    leaq input_buffer, %rsi
    movq input_position, %rcx
    addq %rcx, %rsi           # %rsi pekar på aktuell position i bufferten

    # Hoppa över inledande blanksteg
.getInt_skip_whitespace:
    movzbq (%rsi), %rdx
    cmpq $' ', %rdx
    jne .getInt_check_sign    # Hitta första tecknet som inte är ett blanksteg
    incq %rsi
    incq input_position
    cmpq $INPUT_BUFFER_SIZE, input_position
    jge .getInt_call_inImage
    jmp .getInt_skip_whitespace

    # Kontrollera om tecknet är '+' eller '-'
.getInt_check_sign:
    movq $1, %r9             # Standardtecken (positivt)
    movzbq (%rsi), %rdx
    cmpq $'-', %rdx
    je .getInt_negative
    cmpq $'+', %rdx
    je .getInt_positive
    jmp .getInt_parse_digits

.getInt_negative:
    movq $-1, %r9            # Negativt tecken
    incq %rsi
    incq input_position
    jmp .getInt_parse_digits

.getInt_positive:
    incq %rsi
    incq input_position
    jmp .getInt_parse_digits

    # Huvudloop för att tolka siffror
.getInt_parse_digits:
    movq $0, %rax            # Initiera resultatet till 0
.getInt_digit_loop:
    movzbq (%rsi), %rdx
    cmpq $'0', %rdx
    jl .getInt_end_parse     # Slut på talet om tecknet är för litet
    cmpq $'9', %rdx
    jg .getInt_end_parse     # Slut på talet om tecknet är för stort

    subq $'0', %rdx          # Omvandla ASCII-tecknet till en siffra
    imulq $10, %rax          # Multiplicera ackumulatorn med 10
    addq %rdx, %rax          # Lägg till siffran
    incq %rsi                # Gå till nästa tecken
    incq input_position
    cmpq $INPUT_BUFFER_SIZE, input_position
    jge .getInt_end_parse    # Slut om bufferten tar slut
    jmp .getInt_digit_loop

    # Slutför tolkning och applicera tecken
.getInt_end_parse:
    imulq %r9, %rax          # Applicera tecknet på resultatet

    # Logga avslutning
    leaq format_getInt_exit, %rdi
    movq %rax, %rsi
    movq input_position, %rdx
    call printf

    popq %rbp
    ret

    # Anropa inImage för att fylla på bufferten om den tar slut
.getInt_call_inImage:
    call inImage
    jmp .getInt_start

.getInt_return:
    leaq format_getInt_exit, %rdi
    movq %rax, %rsi
    movq input_position, %rdx
    call printf
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
    # Check if input buffer needs to be refreshed
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getText_call_inImage

.getText_copy_loop:
    cmpq $0, %r13      # Check if n is 0
    je .getText_end

    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getText_end  # Reached end of input buffer

    leaq input_buffer, %rsi
    addq %rax, %rsi
    movzbq (%rsi), %rcx
    cmpb $0, %cl      # Check for null terminator
    je .getText_end

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
    # Check if input buffer needs to be refreshed
    movq input_position, %rax
    cmpq $INPUT_BUFFER_SIZE, %rax
    jge .getChar_call_inImage

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

    # Om n är negativt, hantera tecknet separat
    movq %rax, %r10          # Kopiera n
    cmpq $0, %r10
    jge .putInt_positive
    movb $'-', %al           # Lägg '-' i ett register
    movb %al, (%rdi,%rsi,1)  # Flytta värdet från %al till minnesadressen
    incq %rsi
    negq %r10                # Gör talet positivt
.putInt_positive:
    movq %r10, %rax          # Börja omvandla n (positivt tal)

.putInt_convert_loop:
    movq $0, %rdx
    movq $10, %rcx
    idivq %rcx
    addq $48, %rdx  # Convert remainder to ASCII
    pushq %rdx

    testq %rax, %rax         # Kolla om kvoten är 0
    jnz .putInt_convert_loop

.putInt_output_loop:
    cmpq $OUTPUT_BUFFER_SIZE, %rsi
    jge .putInt_flush_and_continue

    popq %rax
    movb %al, (%rdi,%rsi,1)
    incq %rsi
    movq %rsi, output_position # Update output_position

    cmpq %rsp, %rbp  # Korrekt syntax
    jne .putInt_output_loop   # Fortsätt tills stacken är tömd
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