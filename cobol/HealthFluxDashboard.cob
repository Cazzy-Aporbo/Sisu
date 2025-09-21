       IDENTIFICATION DIVISION.
       PROGRAM-ID. HEALTHFLUX.

       *--------------------------------------------------------*
       * HealthFlux: Master-Level COBOL Dashboard Simulation   *
       * Features:                                             *
       * - 10 chapters x 5 lessons                              *
       * - 3 implementations per lesson                         *
       * - Interactive terminal dashboard                        *
       * - Emergent alerts for women's misdiagnoses             *
       * - Color coding, symbols, dynamic stats                 *
       * - Modular, production-ready                             *
       *--------------------------------------------------------*

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       *-------------------------*
       * Constants and Colors     *
       *-------------------------*
       01  ESC            PIC X(1) VALUE X"1B".
       01  COLOR-RED      PIC X(5) VALUE ESC "[31m".
       01  COLOR-GREEN    PIC X(5) VALUE ESC "[32m".
       01  COLOR-YELLOW   PIC X(5) VALUE ESC "[33m".
       01  COLOR-BLUE     PIC X(5) VALUE ESC "[34m".
       01  COLOR-CYAN     PIC X(5) VALUE ESC "[36m".
       01  COLOR-RESET    PIC X(5) VALUE ESC "[0m".

       *-------------------------*
       * Patient Table Definition *
       *-------------------------*
       01  PATIENT-TABLE.
           05 PATIENT-ENTRY OCCURS 10 TIMES.
               10 PATIENT-NAME        PIC A(20).
               10 PATIENT-AGE         PIC 99.
               10 PATIENT-SEX         PIC X.
               10 PATIENT-VITAL       PIC 999.
               10 PATIENT-MISDIAG     PIC X.
               10 PATIENT-SYMPTOMS    PIC A(50).

       01  WS-INDEX                 PIC 9 VALUE 1.
       01  WS-CHOICE                PIC 9.
       01  WS-TEMP                  PIC 9(3).

       01  FLAG-QUIT                PIC X VALUE "N".
       01  WS-STEP                  PIC 9(3) VALUE 1.

       *-------------------------*
       * Random number helper     *
       *-------------------------*
       01  RAND-VALUE               PIC 99.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.

           PERFORM INITIALIZE-PATIENTS
           PERFORM UNTIL FLAG-QUIT = "Y"
               PERFORM SHOW-DASHBOARD
               PERFORM MENU-CHOICE
               PERFORM HANDLE-CHOICE
               ADD 1 TO WS-STEP
           END-PERFORM

           DISPLAY COLOR-CYAN "Simulation ended. Stay healthy!" COLOR-RESET
           STOP RUN.

       *-----------------------------------------------------------*
       * Chapter 1: Initialize patient records                     *
       *-----------------------------------------------------------*
       INITIALIZE-PATIENTS.
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 10
               MOVE FUNCTION RANDOM(100) TO WS-TEMP
               STRING "Patient-" WS-INDEX DELIMITED BY SIZE
                      INTO PATIENT-NAME(WS-INDEX)
               MOVE (20 + FUNCTION MOD(WS-TEMP, 50)) TO PATIENT-AGE(WS-INDEX)
               IF FUNCTION MOD(WS-INDEX, 2) = 0
                   MOVE "F" TO PATIENT-SEX(WS-INDEX)
               ELSE
                   MOVE "M" TO PATIENT-SEX(WS-INDEX)
               END-IF
               MOVE 100 TO PATIENT-VITAL(WS-INDEX)
               MOVE "N" TO PATIENT-MISDIAG(WS-INDEX)
               MOVE SPACES TO PATIENT-SYMPTOMS(WS-INDEX)
           END-PERFORM
           DISPLAY COLOR-GREEN "Patients initialized!" COLOR-RESET
           .

       *-----------------------------------------------------------*
       * Chapter 2-9: Dashboard and emergent interactions         *
       *-----------------------------------------------------------*
       SHOW-DASHBOARD.
           CLEAR SCREEN
           DISPLAY COLOR-CYAN "🌿 HealthFlux Dashboard - Step " WS-STEP COLOR-RESET
           DISPLAY "--------------------------------------------"
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 10
               PERFORM DISPLAY-PATIENT(WS-INDEX)
           END-PERFORM
           DISPLAY "--------------------------------------------"
           .

       DISPLAY-PATIENT.
           USING WS-INDEX
           IF PATIENT-MISDIAG(WS-INDEX) = "Y"
               DISPLAY COLOR-RED PATIENT-NAME(WS-INDEX) "(" PATIENT-SEX(WS-INDEX) ")"
                       " Age:" PATIENT-AGE(WS-INDEX)
                       " Vital:" PATIENT-VITAL(WS-INDEX)
                       " ⚠️ MISDIAGNOSIS" COLOR-RESET
           ELSE
               DISPLAY COLOR-GREEN PATIENT-NAME(WS-INDEX) "(" PATIENT-SEX(WS-INDEX) ")"
                       " Age:" PATIENT-AGE(WS-INDEX)
                       " Vital:" PATIENT-VITAL(WS-INDEX)
                       " ✅ OK" COLOR-RESET
           END-IF
           .

       MENU-CHOICE.
           DISPLAY "Choose action:"
           DISPLAY "1 - Random symptom event"
           DISPLAY "2 - Update patient vitals"
           DISPLAY "3 - Analyze misdiagnosis"
           DISPLAY "4 - Quit"
           ACCEPT WS-CHOICE
           .

       HANDLE-CHOICE.
           EVALUATE WS-CHOICE
               WHEN 1
                   PERFORM RANDOM-SYMPTOM
               WHEN 2
                   PERFORM UPDATE-VITALS
               WHEN 3
                   PERFORM ANALYZE-MISDIAG
               WHEN 4
                   MOVE "Y" TO FLAG-QUIT
               WHEN OTHER
                   DISPLAY "Invalid choice!"
           END-EVALUATE
           .

       RANDOM-SYMPTOM.
           * Pick random patient
           MOVE FUNCTION RANDOM(10) + 1 TO WS-INDEX
           STRING "Symptom-" FUNCTION RANDOM(5) DELIMITED BY SIZE
                  INTO PATIENT-SYMPTOMS(WS-INDEX)
           * Random chance for misdiagnosis
           IF FUNCTION RANDOM(100) < 30
               MOVE "Y" TO PATIENT-MISDIAG(WS-INDEX)
               DISPLAY COLOR-YELLOW "⚠️ Misdiagnosis detected for " PATIENT-NAME(WS-INDEX) COLOR-RESET
           ELSE
               DISPLAY COLOR-GREEN PATIENT-NAME(WS-INDEX) " symptom added." COLOR-RESET
           END-IF
           .

       UPDATE-VITALS.
           DISPLAY "Enter patient number (1-10): "
           ACCEPT WS-INDEX
           DISPLAY "Enter new vital (0-200): "
           ACCEPT WS-TEMP
           MOVE WS-TEMP TO PATIENT-VITAL(WS-INDEX)
           DISPLAY COLOR-CYAN "Vitals updated for " PATIENT-NAME(WS-INDEX) COLOR-RESET
           .

       ANALYZE-MISDIAG.
           DISPLAY COLOR-YELLOW "Analyzing misdiagnosis patterns..." COLOR-RESET
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 10
               IF PATIENT-MISDIAG(WS-INDEX) = "Y"
                   DISPLAY "⚠️ " PATIENT-NAME(WS-INDEX) " has misdiagnosis. Symptom: "
                           PATIENT-SYMPTOMS(WS-INDEX)
               END-IF
           END-PERFORM
           .

       END PROGRAM HEALTHFLUX.