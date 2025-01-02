;void inImage();
;long long getInt();
;int getText(char *, int);
;int getInPos();
;void setInPos(int);

;void outImage();
;void putInt(long long);
;void putText(char *);
;void putChar(char);
;int getOutPos();
;void setOutPos(int);

# ------------------------------------------------------------------------------
# Assembly Skeleton for Input/Output Library (Intel x64, AT&T Syntax)
# Blekinge Tekniska Högskola - Computer Technology Course
# ------------------------------------------------------------------------------

# Define global symbols so they can be called from C
.global inImage
.global getInt
.global getText
.global getChar
.global getInPos
.global setInPos
.global outImage
.global putInt
.global putText
.global putChar
.global getOutPos
.global setOutPos

# ------------------------------------------------------------------------------
# .bss section for uninitialized data (buffers)
# ------------------------------------------------------------------------------
.bss
    input_buffer:         .space 256  # Example input buffer size
    output_buffer:        .space 256  # Example output buffer size
    input_position:       .quad 0     # Current position in input buffer
    output_position:      .quad 0     # Current position in output buffer

# ------------------------------------------------------------------------------
# .text section for code
# ------------------------------------------------------------------------------
.text

# ------------------------------------------------------------------------------
# Input Functions
# ------------------------------------------------------------------------------


# inImage: Read a new text line from keyboard
inImage:
    # Function implementation goes here
    # Parameters: None (implicitly operates on input_buffer)
    # Return value: None

    pushq   %rbp          # Standard function prologue
    movq    %rsp, %rbp

    # System call to read from stdin (syscall number 0 on Linux x64)
    movq    $0, %rax       # Syscall number for read
    movq    $0, %rdi       # File descriptor for stdin
    leaq    input_buffer, %rsi  # Address of the input buffer
    movq    $255, %rdx     # Maximum number of bytes to read (buffer size - 1 for null terminator)
    syscall

    # Check for errors (optional, but good practice)
    cmpq    $0, %rax
    jl      .error_inImage  # Handle error if read failed

    # Ensure null termination of the input buffer
    movq    %rax, %rcx      # Number of bytes read
    cmpq    $0, %rcx
    jle     .reset_position # If nothing was read, just reset position

    leaq    input_buffer(%rip), %rbx # Load address of input_buffer
    addq    %rcx, %rbx      # Point to the byte after the last read character
    movb    $0, (%rbx)      # Add null terminator

.reset_position:
    # Reset the input position to 0
    movq    $0, input_position

.exit_inImage:
    movq    %rbp, %rsp    # Standard function epilogue
    popq    %rbp
    ret

.error_inImage:
    # Handle read error (e.g., set an error flag, print an error message)
    # For now, we'll just reset the position and return
    movq    $0, input_position
    jmp     .exit_inImage

# getInt: Parse and convert an integer from input buffer
getInt:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# getText: Transfer text from input buffer to memory
getText:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# getChar: Return a single character from input buffer
getChar:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# getInPos: Return current input buffer position
getInPos:
    pushq   %rbp
    movq    %rsp, %rbp
    # Load the current input position into %rax (return register)
    movq    input_position, %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret

# setInPos: Set input buffer position
setInPos:
    pushq   %rbp
    movq    %rsp, %rbp
    # Get the new position (typically passed in a register like %rdi)
    movq    %rdi, input_position
    movq    %rbp, %rsp
    popq    %rbp
    ret

# ------------------------------------------------------------------------------
# Output Functions
# ------------------------------------------------------------------------------

# outImage: Write string from output buffer to terminal
outImage:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# putInt: Place integer as string in output buffer
putInt:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# putText: Place text string in output buffer
putText:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    ret

# putChar: Place single character in output buffer
putChar:
    pushq   %rbp
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp
    popq    %rbp
    re ## hej hej

# getOutPos: Return current output buffer position
getOutPos:
    pushq   %rbp
    movq    %rsp, %rbp
    # Load the current output position into %rax
    movq    output_position, %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret

# setOutPos: Set output buffer position
setOutPos:
    pushq   %rbp
    movq    %rsp, %rbp
    # Get the new position (typically passed in a register like %rdi)
    movq    %rdi, output_position
    movq    %rbp, %rsp
    popq    %rbp
    ret