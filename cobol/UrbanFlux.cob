       IDENTIFICATION DIVISION.
       PROGRAM-ID. URBANFLUX.
       AUTHOR. CAZZY.
       REMARKS. >
           Master-level COBOL city simulation.
           Demonstrates multiple agents, emergent behaviors, and interactive policies.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       77 NUM-CITIZENS       PIC 99 VALUE 5.
       77 NUM-VEHICLES       PIC 99 VALUE 3.
       77 NUM-BUILDINGS      PIC 99 VALUE 4.
       77 CITY-ENERGY        PIC 999 VALUE 100.
       77 CITY-POLLUTION     PIC 999 VALUE 0.
       77 STEP-COUNT         PIC 99 VALUE 0.

       01 CITIZENS.
           05 CITIZEN OCCURS 5 TIMES.
              10 C-NAME       PIC X(10).
              10 C-HAPPINESS  PIC 99.
              10 C-HEALTH     PIC 99.

       01 VEHICLES.
           05 VEHICLE OCCURS 3 TIMES.
              10 V-TYPE       PIC X(10).
              10 V-SPEED      PIC 99.
              10 V-FUEL       PIC 99.

       01 BUILDINGS.
           05 BUILDING OCCURS 4 TIMES.
              10 B-TYPE       PIC X(10).
              10 B-ENERGY    PIC 99.
              10 B-OCCUPANCY PIC 99.

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           DISPLAY "🏙️ Welcome to UrbanFlux: COBOL City Simulator 🏙️"

           PERFORM INIT-CITY
           PERFORM SIMULATION-LOOP UNTIL STEP-COUNT >= 10

           DISPLAY "Simulation Complete!"
           STOP RUN.

       INIT-CITY.
           MOVE "Alice     " TO C-NAME(1)
           MOVE 80 TO C-HAPPINESS(1)
           MOVE 100 TO C-HEALTH(1)
           MOVE "Bob       " TO C-NAME(2)
           MOVE 70 TO C-HAPPINESS(2)
           MOVE 90 TO C-HEALTH(2)
           MOVE "Carol     " TO C-NAME(3)
           MOVE 90 TO C-HAPPINESS(3)
           MOVE 95 TO C-HEALTH(3)
           MOVE "Dave      " TO C-NAME(4)
           MOVE 60 TO C-HAPPINESS(4)
           MOVE 85 TO C-HEALTH(4)
           MOVE "Eve       " TO C-NAME(5)
           MOVE 75 TO C-HAPPINESS(5)
           MOVE 100 TO C-HEALTH(5)

           MOVE "Car" TO V-TYPE(1)
           MOVE 50 TO V-SPEED(1)
           MOVE 100 TO V-FUEL(1)
           MOVE "Bus" TO V-TYPE(2)
           MOVE 40 TO V-SPEED(2)
           MOVE 80 TO V-FUEL(2)
           MOVE "Bike" TO V-TYPE(3)
           MOVE 30 TO V-SPEED(3)
           MOVE 100 TO V-FUEL(3)

           MOVE "Residential" TO B-TYPE(1)
           MOVE 20 TO B-ENERGY(1)
           MOVE 5 TO B-OCCUPANCY(1)
           MOVE "Office     " TO B-TYPE(2)
           MOVE 30 TO B-ENERGY(2)
           MOVE 10 TO B-OCCUPANCY(2)
           MOVE "Factory    " TO B-TYPE(3)
           MOVE 50 TO B-ENERGY(3)
           MOVE 20 TO B-OCCUPANCY(3)
           MOVE "Park       " TO B-TYPE(4)
           MOVE 10 TO B-ENERGY(4)
           MOVE 0 TO B-OCCUPANCY(4)
           .

       SIMULATION-LOOP.
           ADD 1 TO STEP-COUNT
           PERFORM UPDATE-CITIZENS
           PERFORM UPDATE-VEHICLES
           PERFORM UPDATE-BUILDINGS
           PERFORM CALCULATE-CITY-STATS
           PERFORM DISPLAY-STEP
           .

       UPDATE-CITIZENS.
           SUBTRACT 1 FROM C-HAPPINESS(1)
           ADD 1 TO C-HEALTH(2)
           SUBTRACT 2 FROM C-HAPPINESS(3)
           .

       UPDATE-VEHICLES.
           SUBTRACT 5 FROM V-FUEL(1)
           SUBTRACT 3 FROM V-FUEL(2)
           SUBTRACT 2 FROM V-FUEL(3)
           ADD 2 TO CITY-POLLUTION
           .

       UPDATE-BUILDINGS.
           ADD B-ENERGY(1) B-ENERGY(2) B-ENERGY(3) B-ENERGY(4) TO CITY-ENERGY
           ADD 3 TO CITY-POLLUTION
           .

       CALCULATE-CITY-STATS.
           IF CITY-POLLUTION > 50
               DISPLAY "⚠️ Pollution is critical!"
           END-IF
           IF CITY-ENERGY < 50
               DISPLAY "⚡ Energy shortage!"
           END-IF
           .

       DISPLAY-STEP.
           DISPLAY "Step " STEP-COUNT
           DISPLAY "City Energy: " CITY-ENERGY
           DISPLAY "City Pollution: " CITY-POLLUTION
           DISPLAY "Citizen Happiness: " C-HAPPINESS(1) "," C-HAPPINESS(2) "," C-HAPPINESS(3)
           .