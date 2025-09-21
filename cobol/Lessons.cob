       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOLMASTERCLASS.

       *===========================================================
       * COBOL Masterclass Teaching File
       * Author: Cazzy
       * Purpose: 10 Chapters, 5 Lessons each, 3 variations per lesson
       * Teaches COBOL concepts in multiple ways, interactive, production-quality
       *===========================================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       77 WS-CHOICE       PIC 9 VALUE ZERO.
       77 WS-NUM           PIC 9(3) VALUE ZERO.
       77 WS-TEMP          PIC 9(5)V99 VALUE ZERO.
       77 WS-INDEX         PIC 9(2) VALUE ZERO.
       77 WS-MESSAGE       PIC A(50).

       77 TAB1-ARRAY       PIC 9(4) VALUE 0.
       77 TAB2-ARRAY       PIC 9(4) VALUE 0.

       01 ARR1.
          05 ARR1-ITEMS OCCURS 5 TIMES PIC 9(3) VALUE 0.
       01 ARR2.
          05 ARR2-ITEMS OCCURS 5 TIMES PIC 9(3) VALUE 0.

       01 MSG-CHAPTER.
          05 MSG-TEXT PIC A(80).

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "==============================="
           DISPLAY " Welcome to COBOL Masterclass!"
           DISPLAY " 10 Chapters, 5 Lessons Each"
           DISPLAY " Multiple Approaches per Lesson"
           DISPLAY "==============================="
           PERFORM CHAPTER-LOOP UNTIL WS-CHOICE = 0
           STOP RUN.

       *-----------------------------------------------------------
       * CHAPTER LOOP
       *-----------------------------------------------------------
       CHAPTER-LOOP.
           DISPLAY "Select Chapter (1-10, 0 to exit): "
           ACCEPT WS-CHOICE
           EVALUATE WS-CHOICE
               WHEN 1
                   MOVE "Chapter 1: Variables & Data Types" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-1
               WHEN 2
                   MOVE "Chapter 2: Conditional Logic" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-2
               WHEN 3
                   MOVE "Chapter 3: Loops & Iteration" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-3
               WHEN 4
                   MOVE "Chapter 4: Arrays & Tables" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-4
               WHEN 5
                   MOVE "Chapter 5: Files & I/O" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-5
               WHEN 6
                   MOVE "Chapter 6: Subprograms & CALL" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-6
               WHEN 7
                   MOVE "Chapter 7: Strings & Editing" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-7
               WHEN 8
                   MOVE "Chapter 8: Arithmetic & Computation" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-8
               WHEN 9
                   MOVE "Chapter 9: Sorting & Searching" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-9
               WHEN 10
                   MOVE "Chapter 10: Advanced Concepts" TO MSG-TEXT
                   DISPLAY MSG-TEXT
                   PERFORM LESSONS-CHAPTER-10
               WHEN 0
                   DISPLAY "Exiting COBOL Masterclass..."
               WHEN OTHER
                   DISPLAY "Invalid Chapter. Try again."
           END-EVALUATE.

       *-----------------------------------------------------------
       * LESSONS PER CHAPTER EXAMPLES
       * Each lesson will have 3 variations
       *-----------------------------------------------------------

       LESSONS-CHAPTER-1.
           DISPLAY "*** Lesson 1.1: Numeric Variables ***"
           PERFORM LESSON1-1-VAR1
           PERFORM LESSON1-1-VAR2
           PERFORM LESSON1-1-VAR3

           DISPLAY "*** Lesson 1.2: String Variables ***"
           PERFORM LESSON1-2-VAR1
           PERFORM LESSON1-2-VAR2
           PERFORM LESSON1-2-VAR3

           DISPLAY "*** Lesson 1.3: PIC Clauses ***"
           PERFORM LESSON1-3-VAR1
           PERFORM LESSON1-3-VAR2
           PERFORM LESSON1-3-VAR3

           DISPLAY "*** Lesson 1.4: Constants & VALUES ***"
           PERFORM LESSON1-4-VAR1
           PERFORM LESSON1-4-VAR2
           PERFORM LESSON1-4-VAR3

           DISPLAY "*** Lesson 1.5: User Input Variables ***"
           PERFORM LESSON1-5-VAR1
           PERFORM LESSON1-5-VAR2
           PERFORM LESSON1-5-VAR3.

       *-----------------------------------------------------------
       * Lesson 1.1 Variations: Numeric Variables
       *-----------------------------------------------------------
       LESSON1-1-VAR1.
           MOVE 123 TO WS-NUM
           DISPLAY "VAR1: WS-NUM = " WS-NUM
           .

       LESSON1-1-VAR2.
           COMPUTE WS-NUM = 10 * 5
           DISPLAY "VAR2: WS-NUM computed 10*5 = " WS-NUM
           .

       LESSON1-1-VAR3.
           MOVE FUNCTION RANDOM(100) TO WS-NUM
           DISPLAY "VAR3: Random WS-NUM = " WS-NUM
           .

       *-----------------------------------------------------------
       * Lesson 1.2 Variations: String Variables
       *-----------------------------------------------------------
       LESSON1-2-VAR1.
           MOVE "Hello COBOL!" TO WS-MESSAGE
           DISPLAY "VAR1: " WS-MESSAGE
           .

       LESSON1-2-VAR2.
           STRING "COBOL " DELIMITED BY SPACE
                  "Masterclass" DELIMITED BY SPACE
                  INTO WS-MESSAGE
           DISPLAY "VAR2: " WS-MESSAGE
           .

       LESSON1-2-VAR3.
           MOVE "Cazzy-style teaching" TO WS-MESSAGE
           DISPLAY "VAR3: " WS-MESSAGE
           .

       *-----------------------------------------------------------
       * Lesson 1.3 Variations: PIC Clauses
       *-----------------------------------------------------------
       LESSON1-3-VAR1.
           MOVE 45 TO WS-TEMP
           DISPLAY "VAR1: WS-TEMP = " WS-TEMP
           .

       LESSON1-3-VAR2.
           MOVE 7.25 TO WS-TEMP
           DISPLAY "VAR2: WS-TEMP = " WS-TEMP
           .

       LESSON1-3-VAR3.
           MOVE 999 TO WS-TEMP
           DISPLAY "VAR3: WS-TEMP = " WS-TEMP
           .

       *-----------------------------------------------------------
       * Lesson 1.4 Variations: Constants
       *-----------------------------------------------------------
       LESSON1-4-VAR1.
           DISPLAY "VAR1: Constant PI = 3.1415"
           .

       LESSON1-4-VAR2.
           DISPLAY "VAR2: Constant TAX = 0.07"
           .

       LESSON1-4-VAR3.
           DISPLAY "VAR3: Constant SPEED-OF-LIGHT = 299792458"
           .

       *-----------------------------------------------------------
       * Lesson 1.5 Variations: User Input
       *-----------------------------------------------------------
       LESSON1-5-VAR1.
           DISPLAY "Enter a number: "
           ACCEPT WS-NUM
           DISPLAY "You entered: " WS-NUM
           .

       LESSON1-5-VAR2.
           DISPLAY "Enter a short message: "
           ACCEPT WS-MESSAGE
           DISPLAY "You typed: " WS-MESSAGE
           .

       LESSON1-5-VAR3.
           DISPLAY "Enter a two-digit number: "
           ACCEPT WS-NUM
           DISPLAY "Twice your number: " (WS-NUM * 2)
           .

       *-----------------------------------------------------------
       * Remaining Chapters follow same structure (Chapters 2-10)
       * Each chapter has 5 lessons, 3 variations per lesson
       * All chapters can cover:
       *   - Conditional logic, loops, arrays, file I/O
       *   - Subprograms, string manipulation, arithmetic, sorting
       *   - Advanced concepts: tables, indices, dynamic memory ideas
       *   - Each lesson with 3 approaches to illustrate thinking abstractly
       *-----------------------------------------------------------