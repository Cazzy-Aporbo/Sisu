       01 PATIENTS.
           05 PATIENT OCCURS 5 TIMES.
              10 P-NAME         PIC X(15).
              10 P-SEX          PIC X(1).
              10 P-AGE          PIC 99.
              10 P-HR           PIC 99.
              10 P-BP           PIC 99.
              10 P-OXYGEN       PIC 99.
              10 P-SYMPTOMS     PIC X(50).
              10 P-MISDIAG-RISK PIC 99.
              10 P-ALERT        PIC X(30).

       PROCEDURE DIVISION.
       CALCULATE-MISDIAG-RISK.
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > NUM-PATIENTS
               IF P-SEX(IDX) = "F" AND P-AGE(IDX) > 35
                  AND P-SYMPTOMS(IDX) CONTAINS "chest pain"
                   ADD 20 TO P-MISDIAG-RISK(IDX)
                   MOVE "High Risk: Heart Attack" TO P-ALERT(IDX)
               END-IF
           END-PERFORM.