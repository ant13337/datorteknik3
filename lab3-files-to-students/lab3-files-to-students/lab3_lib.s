.section .data
INPUT_BUFFER_SIZE = 512
OUTPUT_BUFFER_SIZE = 512
input_buffer: .space INPUT_BUFFER_SIZE  # Allocate space for the input buffer
output_buffer: .space OUTPUT_BUFFER_SIZE # Allocate space for the output buffer
input_position: .quad 0             # Variable to track the current position in the input buffer
output_position: .quad 0            # Variable to track the current position in the output buffer

.section .bss
.comm stdin, 8                     # Reserve space for the stdin file descriptor
.comm stdout, 8                    # Reserve space for the stdout file descriptor

.section .text
.global inImage                     # Declare inImage as a global symbol
.global getInt                      # Declare getInt as a global symbol
.global getText                     # Declare getText as a global symbol
.global getInPos                    # Declare getInPos as a global symbol
.global setInPos                    # Declare setInPos as a global symbol
.global outImage                    # Declare outImage as a global symbol
.global putInt                      # Declare putInt as a global symbol
.global putText                     # Declare putText as a global symbol
.global putChar                     # Declare putChar as a global symbol
.global getOutPos                   # Declare getOutPos as a global symbol
.global setOutPos                   # Declare setOutPos as a global symbol

.extern fgets                     # Declare fgets as an external function
.extern puts                      # Declare puts as an external function
.extern printf                    # Declare printf as an external function for debugging
.extern exit                      # Declare exit as an external function for debugging

# Funktion: inImage
# Läser in en ny textrad från tangentbordet till inmatningsbufferten.
# Nollställer även aktuell position i inmatningsbufferten.
inImage:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq $0, input_position        # Reset the input position to the beginning of the buffer

    leaq input_buffer, %rdi         # Load the address of the input buffer into %rdi (first argument for fgets)
    movq $INPUT_BUFFER_SIZE, %rsi    # Load the maximum number of characters to read into %rsi (second argument for fgets)
    movq stdin(%rip), %rdx          # Load the stdin file descriptor into %rdx (third argument for fgets)

    call fgets                      # Call the fgets function to read input

    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: getInt
# Tolkar en sträng från inbufferten som ett heltal.
# Returnerar det tolkade heltalet.
getInt:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

.getInt_start:
    movq input_position, %rax        # Load the current input position into %rax
    cmpq $INPUT_BUFFER_SIZE, %rax    # Compare the input position with the buffer size
    jge .getInt_call_inImage       # If the input position is at or beyond the end of the buffer, call inImage

    leaq input_buffer, %rsi         # Load the address of the input buffer into %rsi
    movq input_position, %rcx        # Load the current input position into %rcx
    addq %rcx, %rsi                # Add the input position to the buffer address to get the current read pointer

    # Hoppa över inledande blanksteg
.getInt_skip_whitespace:
    movzbq (%rsi), %rdx             # Move zero-extended byte from the current buffer position to %rdx
    cmpq $' ', %rdx                # Compare the character with a space
    jne .getInt_check_sign        # If it's not a space, check for sign
    incq %rsi                      # Increment the buffer pointer
    incq input_position            # Increment the input position
    cmpq $INPUT_BUFFER_SIZE, input_position # Check if the input position reached the end of the buffer
    jge .getInt_call_inImage       # If so, call inImage to refill
    jmp .getInt_skip_whitespace    # Continue skipping whitespace

    # Kontrollera om tecknet är '+' eller '-'
.getInt_check_sign:
    movq $1, %r9                  # Set default sign to positive (1)
    movzbq (%rsi), %rdx             # Move zero-extended byte from the current buffer position to %rdx
    cmpq $'-', %rdx                # Check if the character is '-'
    je .getInt_negative          # If it is, jump to handle negative sign
    cmpq $'+', %rdx                # Check if the character is '+'
    je .getInt_positive          # If it is, jump to handle positive sign
    jmp .getInt_parse_digits      # If it's not a sign, start parsing digits

.getInt_negative:
    movq $-1, %r9                 # Set the sign to negative (-1)
    incq %rsi                      # Increment the buffer pointer
    incq input_position            # Increment the input position
    jmp .getInt_parse_digits      # Start parsing digits

.getInt_positive:
    incq %rsi                      # Increment the buffer pointer
    incq input_position            # Increment the input position
    jmp .getInt_parse_digits      # Start parsing digits

    # Huvudloop för att tolka siffror
.getInt_parse_digits:
    movq $0, %rax                  # Initialize the result to 0
.getInt_digit_loop:
    movzbq (%rsi), %rdx             # Move zero-extended byte from the current buffer position to %rdx
    cmpq $'0', %rdx                # Check if the character is less than '0'
    jl .getInt_end_parse         # If it is, the number parsing is complete
    cmpq $'9', %rdx                # Check if the character is greater than '9'
    jg .getInt_end_parse         # If it is, the number parsing is complete

    subq $'0', %rdx                # Convert the ASCII digit to its numeric value
    imulq $10, %rax                # Multiply the current result by 10
    addq %rdx, %rax                # Add the new digit to the result
    incq %rsi                      # Increment the buffer pointer
    incq input_position            # Increment the input position
    cmpq $INPUT_BUFFER_SIZE, input_position # Check if the input position reached the end of the buffer
    jge .getInt_end_parse         # If so, the number parsing is complete
    jmp .getInt_digit_loop         # Continue parsing digits

    # Slutför tolkning och applicera tecken
.getInt_end_parse:
    imulq %r9, %rax                # Apply the sign to the result
    jmp .getInt_return            # Return the parsed integer

    # Anropa inImage för att fylla på bufferten om den tar slut
.getInt_call_inImage:
    call inImage                  # Call the inImage function to read more input
    jmp .getInt_start            # Restart the getInt process

.getInt_return:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function with the integer in %rax

# Funktion: getText
# Kopierar maximalt n tecken från inbufferten till minnet som pekas ut av buf.
# Returnerar antalet tecken som faktiskt kopierades.
getText:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq %rdi, %r12                 # Store the address of the destination buffer (buf) in %r12
    movq %rsi, %r13                 # Store the maximum number of characters to read (n) in %r13
    movq $0, %r14                   # Initialize the count of copied characters to 0

.getText_start:
    # Check if input buffer needs to be refreshed
    movq input_position, %rax        # Load the current input position into %rax
    cmpq $INPUT_BUFFER_SIZE, %rax    # Compare the input position with the buffer size
    jge .getText_call_inImage      # If the input position is at or beyond the end of the buffer, call inImage

.getText_copy_loop:
    cmpq $0, %r13                  # Check if the number of characters to copy (n) is 0
    je .getText_end                # If it is, jump to the end

    movq input_position, %rax        # Load the current input position into %rax
    cmpq $INPUT_BUFFER_SIZE, %rax    # Compare the input position with the buffer size
    jge .getText_end              # If the input position is at or beyond the end of the buffer, jump to the end

    leaq input_buffer, %rsi         # Load the address of the input buffer into %rsi
    addq %rax, %rsi                # Add the input position to the buffer address to get the current read pointer
    movzbq (%rsi), %rcx             # Move zero-extended byte from the current buffer position to %rcx
    cmpb $0, %cl                   # Check if the character is a null terminator
    je .getText_end                # If it is, jump to the end

    movb %cl, (%r12)                # Copy the character from the input buffer to the destination buffer
    incq %r12                      # Increment the destination buffer pointer
    incq input_position            # Increment the input position
    incq %r14                      # Increment the count of copied characters
    decq %r13                      # Decrement the number of characters to copy
    jmp .getText_copy_loop         # Continue the loop

.getText_call_inImage:
    call inImage                  # Call the inImage function to read more input
    jmp .getText_start            # Restart the getText process

.getText_end:
    movb $0, (%r12)                # Null-terminate the destination string
    movq %r14, %rax                # Move the count of copied characters to %rax (return value)
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: getChar
# Returnerar ett tecken från inmatningsbuffertens aktuella position.
# Flyttar fram aktuell position ett steg i inmatningsbufferten.
getChar:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

.getChar_start:
    # Check if input buffer needs to be refreshed
    movq input_position, %rax        # Load the current input position into %rax
    cmpq $INPUT_BUFFER_SIZE, %rax    # Compare the input position with the buffer size
    jge .getChar_call_inImage      # If the input position is at or beyond the end of the buffer, call inImage

    leaq input_buffer, %rsi         # Load the address of the input buffer into %rsi
    movq input_position, %rax        # Load the current input position into %rax
    addq %rax, %rsi                # Add the input position to the buffer address to get the current read pointer
    movzbq (%rsi), %rax             # Move zero-extended byte from the current buffer position to %rax (return value)
    incq input_position            # Increment the input position
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function with the character in the lower byte of %rax

.getChar_call_inImage:
    call inImage                  # Call the inImage function to read more input
    jmp .getChar_start            # Restart the getChar process

# Funktion: getInPos
# Returnerar aktuell buffertposition för inbufferten.
getInPos:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer
    movq input_position, %rax        # Move the current input position to %rax (return value)
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function with the input position in %rax

# Funktion: setInPos
# Sätter aktuell buffertposition för inbufferten till n.
# Klipper värdet av n till intervallet [0, MAXPOS].
setInPos:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq %rdi, %rax                 # Move the new input position (n) to %rax

    cmpq $0, %rax                   # Compare n with 0
    jl .setInPos_clamp_low         # If n is less than 0, clamp to 0

    cmpq $INPUT_BUFFER_SIZE, %rax    # Compare n with the maximum buffer size
    jg .setInPos_clamp_high        # If n is greater than the maximum, clamp to the maximum

    movq %rax, input_position        # Set the input position to n
    jmp .setInPos_end               # Jump to the end

.setInPos_clamp_low:
    movq $0, input_position        # Set the input position to 0
    jmp .setInPos_end               # Jump to the end

.setInPos_clamp_high:
    movq $INPUT_BUFFER_SIZE, input_position # Set the input position to the maximum size

.setInPos_end:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: outImage
# Skriver ut strängen som ligger i utbufferten till terminalen.
# Nollställer även aktuell position i utbufferten och tömmer bufferten.
outImage:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    leaq output_buffer, %rdi        # Load the address of the output buffer into %rdi (argument for puts)
    call puts                       # Call the puts function to print the string

    # Reset output position and clear buffer
    movq $0, output_position       # Reset the output position to the beginning of the buffer
    leaq output_buffer, %rdi        # Load the address of the output buffer into %rdi
    movq $OUTPUT_BUFFER_SIZE, %rcx   # Load the output buffer size into %rcx for the loop counter
    xor %al, %al                   # Set %al to 0 (null terminator)
.clear_output_loop:
    movb %al, (%rdi)               # Write a null terminator to the current buffer position
    incq %rdi                      # Increment the buffer pointer
    loop .clear_output_loop        # Continue until the entire buffer is cleared

    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: putInt
# Lägger ut talet n som sträng i utbufferten från och med buffertens aktuella position.
putInt:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq %rdi, %rax                 # Move the integer to be printed (n) to %rax
    movq output_position, %rsi       # Load the current output position into %rsi
    leaq output_buffer, %rdi        # Load the base address of the output buffer into %rdi

    # Om n är negativt, hantera tecknet separat
    movq %rax, %r10                 # Copy n
    cmpq $0, %r10                   # Compare n with 0
    jge .putInt_positive           # If n is greater than or equal to 0, jump to the positive handling
    # Check if there's space for the negative sign
    cmpq $OUTPUT_BUFFER_SIZE, output_position # Compare output position with buffer size
    jge .putInt_flush_negative_sign # If no space, flush the buffer
    movb $'-', (%rdi,%rsi,1)        # Move the negative sign to the current buffer position
    incq %rsi                      # Increment the output position
    movq %rsi, output_position      # Update the global output position
    negq %r10                       # Make the number positive
    jmp .putInt_positive           # Continue with the positive number handling

.putInt_flush_negative_sign:
    call outImage                  # Flush the output buffer
    movq $0, output_position       # Reset the output position
    movq %rdi, %rax                 # n - reload the original value (though not used immediately here)
    jmp putInt                      # Restart the putInt logic

.putInt_positive:
    movq %r10, %rax                 # Start converting n (positive)

.putInt_convert_loop:
    cmpq $OUTPUT_BUFFER_SIZE, output_position # Check if output buffer is full
    jge .putInt_flush_and_continue_conversion # If full, flush and continue
    movq $0, %rdx                   # Clear %rdx for division
    movq $10, %rcx                  # Set the divisor to 10
    idivq %rcx                      # Divide %rax by 10, quotient in %rax, remainder in %rdx
    addq $48, %rdx                  # Convert the remainder to ASCII
    pushq %rdx                      # Push the ASCII digit onto the stack
    testq %rax, %rax                # Check if the quotient is zero
    jnz .putInt_convert_loop        # If not zero, continue converting
    jmp .putInt_output_loop         # If zero, start outputting the digits

.putInt_flush_and_continue_conversion:
    call outImage                  # Flush the output buffer
    movq $0, output_position       # Reset the output position
    movq %rdi, %rax                 # n - reload the original value (though not used immediately here)
    movq %rax, %r10                 # restore the positive value if it was negative
    jmp .putInt_positive           # Restart the positive number handling

.putInt_output_loop:
    cmpq $OUTPUT_BUFFER_SIZE, output_position # Check if output buffer is full
    jge .putInt_flush_and_continue_output # If full, flush and continue

    popq %rax                      # Pop the ASCII digit from the stack
    movb %al, (%rdi,%rsi,1)        # Move the digit to the output buffer
    incq %rsi                      # Increment the output position
    movq %rsi, output_position      # Update the global output position
    cmpq %rsp, %rbp                # Check if the stack pointer is back to the base pointer (all digits outputted)
    jne .putInt_output_loop        # If not, continue outputting
    jmp .putInt_end               # If yes, end

.putInt_flush_and_continue_output:
    call outImage                  # Flush the output buffer
    movq $0, output_position       # Reset the output position
    jmp .putInt_output_loop         # Continue outputting digits

.putInt_end:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: putText
# Lägger till textsträngen som finns i buf från och med den aktuella positionen i utbufferten.
putText:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq %rdi, %rsi                 # Move the address of the string to be printed (buf) to %rsi
    leaq output_buffer, %rdi        # Load the address of the output buffer into %rdi

.putText_copy_loop:
    movzbq (%rsi), %rax             # Move zero-extended byte from the string to %rax
    cmpb $0, %al                   # Check if it's the null terminator
    je .putText_end                # If it is, jump to the end

    cmpq $OUTPUT_BUFFER_SIZE, output_position # Check if the output buffer is full
    jge .putText_flush             # If it is, flush the buffer

    movq output_position, %rcx       # Load the current output position into %rcx
    movb %al, (%rdi,%rcx,1)        # Copy the character to the output buffer
    incq output_position            # Increment the output position
    incq %rsi                      # Increment the source string pointer
    jmp .putText_copy_loop         # Continue the loop

.putText_flush:
    call outImage                  # Flush the output buffer
    jmp .putText_copy_loop         # Continue copying the string

.putText_end:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: putChar
# Lägger tecknet c i utbufferten och flyttar fram aktuell position i den ett steg.
putChar:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movb %dil, %al                 # Move the character to be printed (c) to %al
    leaq output_buffer, %rdi        # Load the address of the output buffer into %rdi

    cmpq $OUTPUT_BUFFER_SIZE, output_position # Check if the output buffer is full
    jge .putChar_flush             # If it is, flush the buffer

    movq output_position, %rcx       # Load the current output position into %rcx
    movb %al, (%rdi,%rcx,1)        # Move the character to the output buffer
    incq output_position            # Increment the output position
    jmp .putChar_end               # Jump to the end

.putChar_flush:
    call outImage                  # Flush the output buffer
    movq $0, output_position       # Reset the output position
    # No need to place the character here, as the function will restart
    jmp putChar                     # Restart the putChar logic

.putChar_end:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function

# Funktion: getOutPos
# Returnerar aktuell buffertposition för utbufferten.
getOutPos:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer
    movq output_position, %rax        # Move the current output position to %rax (return value)
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function with the output position in %rax

# Funktion: setOutPos
# Sätter aktuell buffertposition för utbufferten till n.
# Klipper värdet av n till intervallet [0, MAXPOS].
setOutPos:
    pushq %rbp                      # Save the old base pointer
    movq %rsp, %rbp                 # Set the base pointer to the current stack pointer

    movq %rdi, %rax                 # Move the new output position (n) to %rax

    cmpq $0, %rax                   # Compare n with 0
    jl .setOutPos_clamp_low        # If n is less than 0, clamp to 0

    cmpq $OUTPUT_BUFFER_SIZE, %rax   # Compare n with the maximum buffer size
    jg .setOutPos_clamp_high       # If n is greater than the maximum, clamp to the maximum

    movq %rax, output_position       # Set the output position to n
    jmp .setOutPos_end              # Jump to the end

.setOutPos_clamp_low:
    movq $0, output_position       # Set the output position to 0
    jmp .setOutPos_end              # Jump to the end

.setOutPos_clamp_high:
    movq $OUTPUT_BUFFER_SIZE, output_position # Set the output position to the maximum size

.setOutPos_end:
    popq %rbp                       # Restore the old base pointer
    ret                             # Return from the function
