
ASEM-51 V1.3                                         Copyright (c) 2002 by W.W. Heinz                                         PAGE 1





       MCS-51 Family Macro Assembler   A S E M - 5 1   V 1.3
       =====================================================



	Source File:	D:\pk\halfstep.asm
	Object File:	D:\pk\halfstep.hex
	List File:	D:\pk\halfstep.lst



 Line  I  Addr  Code            Source

    1:
    2:		N      0000	org 0000h			;assembler directive	
    3:	  0000	78 08		start:mov r0,#08h		;move 08h to r0
    4:	  0002	90 01 00	mov dptr,#0100h		        ;mov 0100h to dptr
    5:	  0005	E4		rpt:clr a			;clear accumulator
    6:	  0006	93		movc a,@a+dptr		        ;reach to the lookup table of given data
    7:	  0007	F5 90		mov p1,a			;get data in port 1
    8:	  0009	31 08		acall delay			;acall delay
    9:	  000B	A3		inc dptr			;point next memory location
   10:	  000C	D8 F7		djnz r0,rpt			;decrement counter	
   11:	  000E	80 F0		sjmp start			
   12:		N      0100	org 0100h			;assembler directive
   13:	  0100	09 08 0C 04	DB 09,08,0ch,04,06,02,03,01	;look up table
	  0104	06 02 03 01
   14:
   15:	  0108			delay:				;delay routine
   16:	  0108	7A FF		mov r2,#255			;mov 255 to r2
   17:	  010A	7B FF		h1:mov r3,#255			;mov 255 to r3
   18:	  010C	DB FE		h2:djnz r3,h2			;decrement counter and stay in loop till it is 0
   19:	  010E	DA FA		djnz r2,h1	     		;decrement counter and stay in loop till it is 0
   20:	  0110	22		ret				;return
   21:				end				;assembler direcive





                     register banks used:  ---

                     no errors
