/* input the object file generated by the assembler */
INPUT(main.o)
/* output an executable and linkable format file */
OUTPUT(main.elf)

/* define the memory regions of the device */
MEMORY {
    /* RAM starts at ORIGIN and has length LENGTH */
    RAM : ORIGIN = 0x20000000, LENGTH = 0x2000
}

/* this is where exectution will start */
ENTRY(_start)

/* define what to do with the sections defined in the main.S file */
SECTIONS {
    /* the text section is where the executable code is stored */
    .text : {
        *(.text*)
    /* load it into the RAM region */
    } > RAM

    /* the data section is where the variables are stored */
    .data : {
        *(.data*)
    /* load it into the RAM region */
    } > RAM
}
