*------------------------------------------------------------------------------
* This is a skeleton to help write all the _SUP files
*
* basically here's how they all work:
*
* IN_CURRENT_A contains the address of the current op-code we're looking at
* and re-constructing into the command
*
* right after it are any immediate values and/or addresses in the command
*
* --------------------------------------------------------------------
* YOU ARE RESPONSIBLE FOR MOVING IN_CURRENT_A OVER TO THE NEXT COMMAND
* --------------------------------------------------------------------
*
* to output the text, push the characters onto the output stack with
*
*   MOVE.B  $__,(A3)+
* 
* also, replace ADD with the name of the command, all variables and labels are
* global in assembly, so each one has to be 100% unique
*
* things like
*
*     void func()
*     {
*       int NAME = 5;
*     }
*
*     int NAME = 2;
*     func();
*
* don't work here
*------------------------------------------------------------------------------

SUB_SUB
        MOVEM.L   D0-D7/A0-A6,-(SP) ; move the old registers onto the stack

        * sets up the data registers
        *
        * A1 - the current opcode's address
        * A3 - the current position of the output
        * A4 - the location of the text for printing
        *
        * D1 - the actual opcode
        *
        MOVEA.L   #0,A1             ; load the current opcode into a register
        MOVEA.L   IN_CURR_A,A1
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       SUB_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at SUB_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in SUB_STR

SUB_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       SUB_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       SUB_COPY      ; do it again
        
SUB_DONE
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2
        LSR.W     #6,D2
        ANDI.W    #7,D2

        CMP.W     #0,D2
        BEQ       SUB_BYTE_DN
        CMP.W     #1,D2
        BEQ       SUB_WORD_DN
        CMP.W     #2,D2
        BEQ       SUB_LONG_DN

        CMP.W     #4,D2
        BEQ       SUB_BYTE_EA
        CMP.W     #5,D2
        BEQ       SUB_WORD_EA
        CMP.W     #6,D2
        BEQ       SUB_LONG_EA
        
        * if nothing is found just jump to the end
        BRA       SUB_PARAM_DONE

SUB_BYTE_DN
        MOVE.B    #0,D4
        MOVE.B    #0,D5
        BRA       SUB_PARAM_DONE

SUB_WORD_DN
        MOVE.B    #1,D4
        MOVE.B    #0,D5
        BRA       SUB_PARAM_DONE

SUB_LONG_DN
        MOVE.B    #2,D4
        MOVE.B    #0,D5
        BRA       SUB_PARAM_DONE

SUB_BYTE_EA
        MOVE.B    #0,D4
        MOVE.B    #1,D5
        BRA       SUB_PARAM_DONE
        
SUB_WORD_EA
        MOVE.B    #1,D4
        MOVE.B    #1,D5
        BRA       SUB_PARAM_DONE

SUB_LONG_EA
        MOVE.B    #2,D4
        MOVE.B    #1,D5
        BRA       SUB_PARAM_DONE

SUB_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        MOVE.B    #'.',(A3)+
        CMP.B     #0,D4
        BEQ       SUB_PRINT_SIZE_BYTE
        CMP.B     #1,D4
        BEQ       SUB_PRINT_SIZE_WORD
        CMP.B     #2,D4
        BEQ       SUB_PRINT_SIZE_LONG

        BRA       SUB_PRINT_SIZE_DONE

SUB_PRINT_SIZE_BYTE
        MOVE.B    #'B',(A3)+
        BRA       SUB_PRINT_SIZE_DONE
SUB_PRINT_SIZE_WORD
        MOVE.B    #'W',(A3)+
        BRA       SUB_PRINT_SIZE_DONE
SUB_PRINT_SIZE_LONG
        MOVE.B    #'L',(A3)+
        BRA       SUB_PRINT_SIZE_DONE

SUB_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+

        * -------------------
        * check the direction
        * -------------------

        TST.B     D5
        BEQ       SUB_EA_DN
        JSR       SUB_DN_TO_EA
        BRA       SUB_END

SUB_EA_DN
        JSR       SUB_EA_TO_DN

SUB_END

        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
SUB_EA_TO_DN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+
        MOVE.B    #'D',(A3)+
        MOVE.W    D1,D2
        LSR.W     #8,D2
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #$30,D2
        MOVE.B    D2,(A3)+

        RTS
*------------------------------------------------------------------------------
SUB_DN_TO_EA

        MOVE.B    #'D',(A3)+
        MOVE.W    D1,D2
        LSR.W     #8,D2
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #$30,D2
        MOVE.B    D2,(A3)+
        MOVE.B    #',',(A3)+
        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here

        RTS


