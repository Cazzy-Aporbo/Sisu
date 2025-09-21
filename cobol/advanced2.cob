       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOCIAL-NETWORK-SIM.
       AUTHOR. CAZZY.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       77 NUM-AGENTS        PIC 9(02) VALUE 10.
       77 NUM-STEPS         PIC 9(03) VALUE 15.
       77 STEP              PIC 9(03) VALUE 0.
       77 I                 PIC 9(02).
       77 J                 PIC 9(02).
       77 CHOICE            PIC 9 VALUE 0.

       01 AGENTS.
          05 AGENT OCCURS 10 TIMES.
             10 NAME       PIC X(10).
             10 OPINION    PIC 9 VALUE 0.   *> 0=Neutral, 1=Positive, 2=Negative
             10 INFLUENCE  PIC 9 VALUE 1.   *> Influence score

       01 LOG-LINE PIC X(80).

       PROCEDURE DIVISION.
       MAIN-LOOP.

           DISPLAY "🌐 Welcome to Social Dynamics Simulation!".
           PERFORM INIT-AGENTS
           PERFORM VARY-STEPS

           DISPLAY "Simulation Complete.".
           STOP RUN.

       INIT-AGENTS.
           MOVE 1 TO I
           PERFORM VARY-NAME
           DISPLAY "Agents initialized with random opinions."
           .

       VARY-NAME.
           MOVE "Agent-1" TO NAME (I)
           MOVE FUNCTION RANDOM (3) TO OPINION(I)
           ADD 1 TO I
           IF I <= NUM-AGENTS
               PERFORM VARY-NAME
           END-IF
           .

       VARY-STEPS.
           ADD 1 TO STEP
           PERFORM INTERACTIONS
           DISPLAY "Step " STEP ":"
           PERFORM SHOW-OPINIONS
           IF STEP < NUM-STEPS
               PERFORM VARY-STEPS
           END-IF
           .

       INTERACTIONS.
           MOVE 1 TO I
           PERFORM INTERACT-AGENT
           .

       INTERACT-AGENT.
           MOVE 1 TO J
           IF I NOT = J
               *> Each agent influences others probabilistically
               IF FUNCTION RANDOM(10) < INFLUENCE(I)
                   IF OPINION(I) NOT = OPINION(J)
                       MOVE OPINION(I) TO OPINION(J)
                       STRING "Agent " NAME(I) " influenced " NAME(J)
                              INTO LOG-LINE
                       DISPLAY LOG-LINE
                   END-IF
               END-IF
           END-IF
           ADD 1 TO J
           IF J <= NUM-AGENTS
               PERFORM INTERACT-AGENT
           END-IF
           ADD 1 TO I
           IF I <= NUM-AGENTS
               PERFORM INTERACT-AGENT
           END-IF
           .

       SHOW-OPINIONS.
           MOVE 1 TO I
           DISPLAY NAME(I) " Opinion: " OPINION(I)
           ADD 1 TO I
           IF I <= NUM-AGENTS
               PERFORM SHOW-OPINIONS
           END-IF
           .