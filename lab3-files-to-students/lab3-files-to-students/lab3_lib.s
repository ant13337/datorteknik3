#w

.section .data
    input_buffer: .space 256  # Reserve 256 bytes for the input buffer
    input_position: .quad 0   # Variable to track the current position in the input buffer
    stdin_fd: .quad 0       # File descriptor for stdin (usually 0)

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

inImage:
    pushq %rbp          # Standard function prologue
    movq %rsp, %rbp

    movq $input_buffer, %rdi  # First argument to fgets: buffer address
    movq $255, %rsi       # Second argument to fgets: max characters to read (buffer size - 1 for null terminator)
    movq stdin_fd(%rip), %rdx  # Third argument to fgets: file stream (stdin)
    call fgets

    movq $0, input_position(%rip) # Reset the input buffer position to 0

    popq %rbp          # Standard function epilogue
    ret

#Funktion: getInt
getInt:
    # Returnerar ett värde (exempel: returnerar 42)
    movq $42, %rax
    ret

#Funktion: getText
getText:
    # Skriv din kod för getText här
    # Argument 1: (char ) i %rdi
    # Argument 2: (int) i %esi
    movl $0, %eax  # Exempel: returnerar 0
    ret

#Funktion: getInPos
getInPos:
    # Returnerar ett värde (exempel: 10)
    movl $10, %eax
    ret

#Funktion: setInPos
setInPos:
    # Argument: (int) i %edi
    ret

#Funktion: outImage
outImage:
    # Skriv din kod för att implementera outImage här
    ret

#Funktion: putInt
putInt:
    # Argument: (long long) i %rdi
    ret

#Funktion: putText
putText:
    # Argument: (char) i %rdi
    ret

#Funktion: putChar
putChar:
    # Argument: (char) i %dil
    ret

#Funktion: getOutPos
getOutPos:
    # Returnerar ett värde (exempel: 20)
    movl $20, %eax
    ret

#Funktion: setOutPos
setOutPos:
    # Argument: (int) i %edi
    ret
