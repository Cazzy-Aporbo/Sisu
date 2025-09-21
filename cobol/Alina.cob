       IDENTIFICATION DIVISION.
       PROGRAM-ID. ALINA-PROJECT.
       AUTHOR. CAZZY.
       REMARKS. >
           A demonstration project to show mastery of COBOL:
           - Data handling
           - Procedures and modularity
           - Arrays (tables)
           - Loops and conditions
           - Input/output
           - Computation and reporting

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       77 NUM-STUDENTS      PIC 99 VALUE 5.
       77 I                 PIC 99.
       77 TOTAL-SCORE       PIC 999 VALUE 0.

       01 STUDENTS.
           05 STUDENT OCCURS 5 TIMES.
              10 NAME       PIC X(15).
              10 SCORE      PIC 99.

       01 REPORT-LINE       PIC X(80).

       PROCEDURE DIVISION.
       MAIN-LOGIC.

           DISPLAY "📚 Welcome to the ALINA Project COBOL Demo!".

           PERFORM INITIALIZE-STUDENTS
           PERFORM INPUT-SCORES
           PERFORM CALCULATE-TOTAL
           PERFORM DISPLAY-REPORT

           DISPLAY "✅ ALINA Project Completed Successfully."
           STOP RUN.

       INITIALIZE-STUDENTS.
           MOVE "Alice          " TO NAME(1)
           MOVE "Bob            " TO NAME(2)
           MOVE "Charlie        " TO NAME(3)
           MOVE "Diana          " TO NAME(4)
           MOVE "Ethan          " TO NAME(5)
           PERFORM VARY-SCORES
           .

       VARY-SCORES.
           MOVE 0 TO SCORE(1) SCORE(2) SCORE(3) SCORE(4) SCORE(5)
           .

       INPUT-SCORES.
           MOVE 1 TO I
           PERFORM UNTIL I > NUM-STUDENTS
               DISPLAY "Enter score for " NAME(I) ": "
               ACCEPT SCORE(I)
               ADD SCORE(I) TO TOTAL-SCORE
               ADD 1 TO I
           END-PERFORM
           .

       CALCULATE-TOTAL.
           DISPLAY "Calculating average score..."
           .

       DISPLAY-REPORT.
           MOVE 1 TO I
           PERFORM UNTIL I > NUM-STUDENTS
               STRING "Student: " NAME(I)
                      " | Score: " SCORE(I)
                      INTO REPORT-LINE
               DISPLAY REPORT-LINE
               ADD 1 TO I
           END-PERFORM
           DISPLAY "Total Score: " TOTAL-SCORE
           DISPLAY "Average Score: " FUNCTION INTEGER-OF-DATE(TOTAL-SCORE / NUM-STUDENTS)
           .