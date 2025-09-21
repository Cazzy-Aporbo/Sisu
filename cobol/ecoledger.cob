       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECOLEDGER.
       AUTHOR. CAZZY.
       REMARKS. >
           Master-level COBOL project.
           Tracks ecosystems, environmental impacts, and generates reports.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       77 NUM-FACTORIES      PIC 99 VALUE 3.
       77 NUM-TREES          PIC 99 VALUE 5.
       77 NUM-ANIMALS        PIC 99 VALUE 4.
       77 POLLUTION-TOTAL    PIC 999 VALUE 0.
       77 OXYGEN-LEVEL       PIC 999 VALUE 100.
       77 I                  PIC 99.

       01 FACTORIES.
           05 FACTORY OCCURS 3 TIMES.
              10 F-NAME      PIC X(10).
              10 F-POLLUTION PIC 99.

       01 TREES.
           05 TREE OCCURS 5 TIMES.
              10 T-NAME      PIC X(10).
              10 T-OXYGEN    PIC 99.

       01 ANIMALS.
           05 ANIMAL OCCURS 4 TIMES.
              10 A-NAME      PIC X(10).
              10 A-HEALTH    PIC 99.

       01 REPORT-LINE PIC X(80).

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           DISPLAY "🌱 Welcome to EcoLedger: COBOL Environmental Simulation 🌱"

           PERFORM INIT-FACTORIES
           PERFORM INIT-TREES
           PERFORM INIT-ANIMALS

           PERFORM SIMULATION-STEP UNTIL POLLUTION-TOTAL >= 50 OR OXYGEN-LEVEL <= 20

           PERFORM DISPLAY-REPORT

           DISPLAY "Simulation Complete."
           STOP RUN.

       INIT-FACTORIES.
           MOVE "F-Alpha   " TO F-NAME(1)
           MOVE "F-Beta    " TO F-NAME(2)
           MOVE "F-Gamma   " TO F-NAME(3)
           MOVE 0 TO F-POLLUTION(1) F-POLLUTION(2) F-POLLUTION(3)
           .

       INIT-TREES.
           MOVE "Oak       " TO T-NAME(1)
           MOVE "Pine      " TO T-NAME(2)
           MOVE "Maple     " TO T-NAME(3)
           MOVE "Birch     " TO T-NAME(4)
           MOVE "Cedar     " TO T-NAME(5)
           MOVE 10 TO T-OXYGEN(1) T-OXYGEN(2) T-OXYGEN(3) T-OXYGEN(4) T-OXYGEN(5)
           .

       INIT-ANIMALS.
           MOVE "Deer      " TO A-NAME(1)
           MOVE "Wolf      " TO A-NAME(2)
           MOVE "Rabbit    " TO A-NAME(3)
           MOVE "Fox       " TO A-NAME(4)
           MOVE 100 TO A-HEALTH(1) A-HEALTH(2) A-HEALTH(3) A-HEALTH(4)
           .

       SIMULATION-STEP.
           PERFORM VARY-FACTORY-POLLUTION
           PERFORM VARY-TREE-OXYGEN
           PERFORM VARY-ANIMAL-HEALTH
           ADD F-POLLUTION(1) F-POLLUTION(2) F-POLLUTION(3) TO POLLUTION-TOTAL
           ADD T-OXYGEN(1) T-OXYGEN(2) T-OXYGEN(3) T-OXYGEN(4) T-OXYGEN(5) TO OXYGEN-LEVEL
           DISPLAY "Step Update: Pollution=" POLLUTION-TOTAL " Oxygen=" OXYGEN-LEVEL
           .

       VARY-FACTORY-POLLUTION.
           ADD 5 TO F-POLLUTION(1)
           ADD 3 TO F-POLLUTION(2)
           ADD 4 TO F-POLLUTION(3)
           .

       VARY-TREE-OXYGEN.
           SUBTRACT 1 FROM T-OXYGEN(1)
           SUBTRACT 1 FROM T-OXYGEN(2)
           SUBTRACT 2 FROM T-OXYGEN(3)
           SUBTRACT 1 FROM T-OXYGEN(4)
           SUBTRACT 2 FROM T-OXYGEN(5)
           .

       VARY-ANIMAL-HEALTH.
           SUBTRACT 2 FROM A-HEALTH(1)
           SUBTRACT 1 FROM A-HEALTH(2)
           SUBTRACT 3 FROM A-HEALTH(3)
           SUBTRACT 1 FROM A-HEALTH(4)
           .

       DISPLAY-REPORT.
           MOVE 1 TO I
           PERFORM UNTIL I > NUM-FACTORIES
               STRING "Factory: " F-NAME(I)
                      " Pollution: " F-POLLUTION(I)
                      INTO REPORT-LINE
               DISPLAY REPORT-LINE
               ADD 1 TO I
           END-PERFORM

           MOVE 1 TO I
           PERFORM UNTIL I > NUM-TREES
               STRING "Tree: " T-NAME(I)
                      " Oxygen: " T-OXYGEN(I)
                      INTO REPORT-LINE
               DISPLAY REPORT-LINE
               ADD 1 TO I
           END-PERFORM

           MOVE 1 TO I
           PERFORM UNTIL I > NUM-ANIMALS
               STRING "Animal: " A-NAME(I)
                      " Health: " A-HEALTH(I)
                      INTO REPORT-LINE
               DISPLAY REPORT-LINE
               ADD 1 TO I
           END-PERFORM

           DISPLAY "Final Pollution: " POLLUTION-TOTAL
           DISPLAY "Final Oxygen: " OXYGEN-LEVEL
           .