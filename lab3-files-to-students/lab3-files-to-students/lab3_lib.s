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


#Buffert och variabler
.section .data
    input_buffer:
.space 256          # Reservplats för bufferten (256 bytes)
    buffer_pos:
.quad 0             # Variabel för att hålla aktuell position
prompt_msg:
    .asciz "Ange indata: "  # Sträng för promptmeddelande

    .section .bss
bytes_read:
    .quad 0             # Reservplats för lästa tecken

    .section .text
    .globl inImage, getChar

#------------------------------------
inImage:
Läser en ny rad från tangentbordet till bufferten
------------------------------------
inImage:
    pushq %rbp
    movq %rsp, %rbp

    # Skriv ut prompten
    leaq prompt_msg(%rip), %rdi  # Ladda adress till prompten i %rdi
    xorl %eax, %eax              # Ingen flyttal används
    call printf                  # Anropa printf

    # Läs in en ny rad
    leaq input_buffer(%rip), %rdi  # Adress till bufferten
    movl $256, %esi                # Max antal tecken
    call fgets                     # Anropa fgets för att läsa in rad

    # Nollställ positionen
    movq $0, buffer_pos(%rip)

    popq %rbp
    ret

------------------------------------
getChar:
Hämtar nästa tecken från bufferten
------------------------------------
getChar:
    pushq %rbp
    movq %rsp, %rbp

    # Läs aktuell position i bufferten
    movq buffer_pos(%rip), %rax
    movzbl input_buffer(%rax, %rip), %rbx  # Hämta tecknet från bufferten

    # Kontrollera om null-terminator nåtts
    cmpb $0, %bl
    je refill_buffer

    # Uppdatera position och returnera tecknet
    incq buffer_pos(%rip)        # Öka positionen
    movq %rbx, %rax              # Sätt returvärdet till tecknet

    popq %rbp
    ret

refill_buffer:
    call inImage                 # Fyll på bufferten
    jmp getChar                  # Försök hämta tecken igen
