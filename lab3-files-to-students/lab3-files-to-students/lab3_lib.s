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
    # Parameters (typically passed in registers like %rdi, %rsi, etc.)
    # Return value (typically in %rax)
    pushq   %rbp          # Standard function prologue
    movq    %rsp, %rbp
    # ... your implementation ...
    movq    %rbp, %rsp    # Standard function epilogue
    popq    %rbp
    ret

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
    ret

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