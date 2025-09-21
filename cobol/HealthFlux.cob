       IDENTIFICATION DIVISION.
       PROGRAM-ID. HEALTHFLUX.
       AUTHOR. CAZZY.
       REMARKS. >
           Master-level COBOL project for health data analytics.
           Demonstrates multi-patient tracking, alerts, and emergent behavior.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       77 NUM-PATIENTS       PIC 99 VALUE 5.
       77 STEP-COUNT         PIC 99 VALUE 0.

       01 PATIENTS.
           05 PATIENT OCCURS 5 TIMES.
              10 P-NAME         PIC X(10).
              10 P-AGE          PIC 99.
              10 P-HEART        PIC 99.
              10 P-BP           PIC 99.
              10 P-OXYGEN       PIC 99.
              10 P-ALERT        PIC X(20).

       01 MEDICATIONS.
           05 MED OCCURS 3 TIMES.
              10 M-TYPE        PIC X(10).
              10 M-DOSAGE      PIC 99.
              10 M-ADHERENCE   PIC 99.

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           DISPLAY "🏥 Welcome to HealthFlux: COBOL Patient Analytics 🏥"

           PERFORM INIT-PATIENTS
           PERFORM SIMULATION-LOOP UNTIL STEP-COUNT >= 10

           DISPLAY "Analytics Complete!"
           STOP RUN.

       INIT-PATIENTS.
           MOVE "Alice     " TO P-NAME(1)
           MOVE 30 TO P-AGE(1)
           MOVE 72 TO P-HEART(1)
           MOVE 120 TO P-BP(1)
           MOVE 98 TO P-OXYGEN(1)
           MOVE SPACES TO P-ALERT(1)

           MOVE "Bob       " TO P-NAME(2)
           MOVE 55 TO P-AGE(2)
           MOVE 80 TO P-HEART(2)
           MOVE 135 TO P-BP(2)
           MOVE 95 TO P-OXYGEN(2)
           MOVE SPACES TO P-ALERT(2)

           MOVE "Carol     " TO P-NAME(3)
           MOVE 40 TO P-AGE(3)
           MOVE 76 TO P-HEART(3)
           MOVE 125 TO P-BP(3)
           MOVE 97 TO P-OXYGEN(3)
           MOVE SPACES TO P-ALERT(3)

           MOVE "Dave      " TO P-NAME(4)
           MOVE 65 TO P-AGE(4)
           MOVE 88 TO P-HEART(4)
           MOVE 145 TO P-BP(4)
           MOVE 92 TO P-OXYGEN(4)
           MOVE SPACES TO P-ALERT(4)

           MOVE "Eve       " TO P-NAME(5)
           MOVE 50 TO P-AGE(5)
           MOVE 70 TO P-HEART(5)
           MOVE 130 TO P-BP(5)
           MOVE 96 TO P-OXYGEN(5)
           MOVE SPACES TO P-ALERT(5)
           .

       SIMULATION-LOOP.
           ADD 1 TO STEP-COUNT
           PERFORM UPDATE-VITALS
           PERFORM CHECK-ALERTS
           PERFORM DISPLAY-STEP
           .

       UPDATE-VITALS.
           ADD 1 TO P-HEART(1)
           SUBTRACT 2 FROM P-OXYGEN(2)
           ADD 3 TO P-BP(3)
           .

       CHECK-ALERTS.
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > NUM-PATIENTS
               IF P-OXYGEN(IDX) < 95
                   MOVE "Low Oxygen ⚠️" TO P-ALERT(IDX)
               ELSE
                   MOVE SPACES TO P-ALERT(IDX)
               END-IF
               IF P-BP(IDX) > 140
                   MOVE "High BP ⚠️" TO P-ALERT(IDX)
               END-IF
           END-PERFORM
           .

       DISPLAY-STEP.
           DISPLAY "Step " STEP-COUNT
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > NUM-PATIENTS
               DISPLAY "Patient: " P-NAME(IDX) " HR:" P-HEART(IDX)
                       " BP:" P-BP(IDX) " O2:" P-OXYGEN(IDX)
                       " Alert:" P-ALERT(IDX)
           END-PERFORM
           .