// JOB INDIAN
// ASSGN SYS001,X'132'
// ASSGN SYS002,X'132'
// ASSGN SYS003,X'132'
// ASSGN SYSLNK,X'132'
// ASSGN SYSPCH,X'00D'
// OPTION LINK,DECK,NOXREF,LIST
// EXEC ASSEMBLY
         TITLE 'TEST PROGRAM'
         PRINT NOGEN
         START 0
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         USING *,0
INITPSW  DC    X'80',X'00',X'0000',X'00',AL3(INDIAN)
CCW1     DS    D
CCW2     DS    D
EXTOPSW  DS    D
SVCOPSW  DS    D
PRGOPSW  DS    D
MCOPSW   DS    D
IOOPSW   DS    D
CSW      DS    D
CAW      DS    D
TIMER    DS    D
EXTPSW   DC    X'0002000000000004'
SVCPSW   DC    X'0002000000000008'
PRGPSW   DC    X'000200000000000C'
MCPSW    DC    X'0002000000000010'
IOPSW    DC    X'00',X'00',X'0000',X'00',AL3(IOINT)
         DS    128C
* Start
INDIAN   BALR  11,0
         USING *,11
* R11 = 102
AGAIN    LA    R1,PROMPT
         ST    R1,CAW
         SIO   X'01F'
WAIT     LPSW  WAITPSW
CALC     MVZ   YEARZ,INTZ
         PACK  PRINCP,PRINCZ
         PACK  INTP,INTZ
         PACK  YEARSP,YEARZ
         CVB   4,YEARSP
LOOP     MP    PRINCP,INTP
         AP    PRINCP,ROUND
         MVN   PRINCP+5(1),PRINCP+6
         MVC   TEMP,PRINCP
         ZAP   PRINCP,TEMP
         BCT   4,LOOP
         MVC   BALANCE,TEMPLATE
         LA    1,BALANCE+10
         EDMK  BALANCE,PRINCP
         BCTR  1,0
         MVC   0(1,1),=C'$'
         LA    1,WRITE
         ST    1,CAW
         SIO   X'01F'
STOP     LPSW  STOPPSW
*
* Interrupt handler
IOINT    L     R2,CSW+4
* Check for Channel end
         N     R2,=X'08000000'
         BC    4,CONT
* Keep waiting
         LPSW  WAITPSW
* Return and continue
CONT     LPSW  CALCPSW
PRINCZ   DC    ZL4'24.00'
INTZ     DC    ZL3'1.03'
YEARZ    DC    ZL3'005'
PRINCP   DS    PL7
INTP     DS    PL2
YEARSP   DS    D
ROUND    DC    PL2'50'
TEMP     DS    PL6
BALANCE  DS    ZL15
INTRO    DC    C'The answer is '
TEMPLATE DC    C' ',10X'20',X'21',C'.',X'21',X'21'
PRMPT    DC    C'Enter number of years (3 digits): '
* PROMPT writes out a message (no CR) with SIL and chains to READCCW
PROMPT   CCW   X'01',PRMPT,X'60',L'PRMPT
* READCCW reads 3 bytes and interrupts
READCCW  CCW   X'0A',YEARZ,X'08',L'YEARZ
* The following NOP does an interrupt
*         CCW   X'03',X'000000',X'08',X'000001'
WRITE    CCW   X'09',INTRO,X'80',L'INTRO
         CCW   X'09',BALANCE,X'00',L'BALANCE
CALCPSW  DC    X'00000000',X'00',AL3(CALC)
WAITPSW  DC    X'80020000',X'00',AL3(WAIT)
STOPPSW  DC    X'00020000',X'00',AL3(STOP)
*
         END   INDIAN
/*
// EXEC LNKEDT
/&
