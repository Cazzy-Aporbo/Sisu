       *> Compile (GNUCobol): cobc -x LEDGER.cob && ./LEDGER
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LEDGER.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 TOTAL        PIC S9(7)V99 VALUE 0.
       01 AMT          PIC S9(5)V99.
       PROCEDURE DIVISION.
           DISPLAY "Enter amounts, 'END' to finish.".
           PERFORM UNTIL 1 = 2
              ACCEPT AMT
              IF AMT = ZERO
                 EXIT PERFORM
              END-IF
              ADD AMT TO TOTAL
           END-PERFORM
           DISPLAY "Ledger total: " TOTAL
           STOP RUN.
