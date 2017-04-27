OUTPUT_ARCH(mips)
ENTRY(_start)

MEMORY
{
        rom (rx)  : ORIGIN = 0x, /* x_INST_BASE_ADDR */
                    LENGTH = 0x, /* x_INST_MEM_SZ */
        ram (!rx) : ORIGIN = 0x, /* x_DATA_BASE_ADDR */
                    LENGTH = 0x, /* x_DATA_MEM_SZ */
        io (!rx)  : ORIGIN = 0x0f000000, /* not used, do not remove       */
                    LENGTH = 0x00020000  /* edMemory.sh needs thess lines */
}

SECTIONS
{
       .text :
       {
          *(.text .text.*)
          _etext = . ;         /* end of text constant (from Xinu) */
       }                                   > rom

       .data : 
       {
          _bdata = . ;         /* begin of data constant */
          *(.data .data.*) 
          _edata = . ;         /* end of data constant  (from Xinu) */
       }                                   > ram
       .data1   : { *(.data1) }            > ram
       .rodata  : { *(.rodata .rodata.*) } > ram
       .rodata1 : { *(.rodata1) }          > ram
       .lit8    : { *(.lit8) }             > ram
       .lit4    : { *(.lit4) }             > ram
       .sdata   : { *(.sdata .sdata.*) }   > ram
       .sbss    : { *(.sbss .sbss.*) *(.scommon .scommon.*) }  > ram
       .bss :
       {
          *(.bss .bss.*) *(COMMON) 
          _end = . ;           /* end of image constant  (from Xinu) */
       }                                   > ram

       end_RAM = 0x; /* x_DATA_MEM_SZ */
       half_RAM = (end_RAM / 2);
       base_TP = ( _bdata + half_RAM );
       .TP base_TP : { *(.TP) }                  > ram
}
