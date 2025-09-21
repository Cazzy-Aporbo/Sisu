       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADVANCED-MATH-COBOL.
       AUTHOR. Cazzy.
       DATE-WRITTEN. 2025-09-21.
       REMARKS. >
           "Advanced Math Lessons in COBOL"
           "5 lessons, 3 variations each"
           "Designed for abstract thinking & teaching purposes"

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       *-----------------------------------------*
       * LESSON 1: MODULAR ARITHMETIC & PATTERNS *
       *-----------------------------------------*
       01 WS-NUMBER        PIC 9(3) VALUE 1.
       01 WS-MOD           PIC 9(3).
       01 WS-INDEX         PIC 9(3).

       *-----------------------------------------*
       * LESSON 2: FIBONACCI SEQUENCE           *
       *-----------------------------------------*
       01 WS-FIB-N         PIC 9(3) VALUE 10.
       01 WS-FIB-PREV      PIC 9(5) VALUE 0.
       01 WS-FIB-CURR      PIC 9(5) VALUE 1.
       01 WS-FIB-NEXT      PIC 9(5).

       01 WS-FIB-ARRAY.
          05 WS-FIB-TBL OCCURS 0 TO 50 TIMES
             INDEXED BY FIB-IDX
             PIC 9(5).

       *-----------------------------------------*
       * LESSON 3: PRIME NUMBERS & FACTORS      *
       *-----------------------------------------*
       01 WS-PRIME-N       PIC 9(3) VALUE 50.
       01 WS-PRIME-COUNT   PIC 9(3) VALUE 0.
       01 WS-DIVISOR       PIC 9(3).
       01 WS-IS-PRIME      PIC X VALUE 'Y'.

       *-----------------------------------------*
       * LESSON 4: MATRIX OPERATIONS            *
       *-----------------------------------------*
       01 MATRIX-A.
          05 MA-ROW OCCURS 2 TIMES.
             10 MA-COL OCCURS 2 TIMES PIC 9(3).
       01 MATRIX-B.
          05 MB-ROW OCCURS 2 TIMES.
             10 MB-COL OCCURS 2 TIMES PIC 9(3).
       01 MATRIX-C.
          05 MC-ROW OCCURS 2 TIMES.
             10 MC-COL OCCURS 2 TIMES PIC 9(5).

       *-----------------------------------------*
       * LESSON 5: FLOATING-POINT COMPUTATION   *
       *-----------------------------------------*
       01 WS-A             PIC S9(3)V99 VALUE 1.50.
       01 WS-B             PIC S9(3)V99 VALUE 2.50.
       01 WS-C             PIC S9(3)V99.
       01 WS-D             PIC S9(3)V99.
       01 WS-X             PIC S9(5)V99.
       01 WS-Y             PIC S9(5)V99.
       01 WS-INTEREST      PIC S9(5)V99 VALUE 1000.00.
       01 WS-RATE          PIC S9(3)V99 VALUE 5.0.
       01 WS-YEARS         PIC 9(2) VALUE 10.
       01 WS-FUTURE        PIC S9(7)V99.

       PROCEDURE DIVISION.
       MAIN-PROGRAM.

       DISPLAY "===============================".
       DISPLAY " ADVANCED MATH LESSONS IN COBOL ".
       DISPLAY "===============================".

       *-----------------------------*
       * LESSON 1: Modular Arithmetic
       *-----------------------------*
       DISPLAY "Lesson 1: Modular Arithmetic and Patterns".

       PERFORM VARYING WS-NUMBER FROM 1 BY 1 UNTIL WS-NUMBER > 20
           COMPUTE WS-MOD = WS-NUMBER MOD 7
           DISPLAY "Number: " WS-NUMBER " Mod 7 = " WS-MOD
       END-PERFORM.

       DISPLAY "Variation 2: Multiples visual pattern".
       PERFORM VARYING WS-NUMBER FROM 1 BY 1 UNTIL WS-NUMBER > 20
           IF WS-NUMBER MOD 3 = 0
               DISPLAY "*" WITH NO ADVANCING
           ELSE
               DISPLAY " " WITH NO ADVANCING
           END-IF
       END-PERFORM
       DISPLAY "".

       DISPLAY "Variation 3: Modular sequence pseudo-random".
       PERFORM VARYING WS-NUMBER FROM 1 BY 1 UNTIL WS-NUMBER > 15
           COMPUTE WS-MOD = (WS-NUMBER * 5) MOD 7
           DISPLAY "Step " WS-NUMBER ": " WS-MOD
       END-PERFORM.

       *-----------------------------*
       * LESSON 2: Fibonacci Sequence
       *-----------------------------*
       DISPLAY "Lesson 2: Fibonacci Sequence".

       DISPLAY "Variation 1: Iterative array".
       MOVE WS-FIB-PREV TO WS-FIB-TBL(1)
       MOVE WS-FIB-CURR TO WS-FIB-TBL(2)
       PERFORM VARYING WS-INDEX FROM 3 BY 1 UNTIL WS-INDEX > WS-FIB-N
           ADD WS-FIB-TBL(WS-INDEX -1) TO WS-FIB-TBL(WS-INDEX -2) GIVING WS-FIB-TBL(WS-INDEX)
       END-PERFORM
       PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > WS-FIB-N
           DISPLAY "Fibonacci(" WS-INDEX ") = " WS-FIB-TBL(WS-INDEX)
       END-PERFORM.

       DISPLAY "Variation 2: Iterative variables only".
       MOVE WS-FIB-PREV TO WS-FIB-PREV
       MOVE WS-FIB-CURR TO WS-FIB-CURR
       PERFORM VARYING WS-INDEX FROM 3 BY 1 UNTIL WS-INDEX > WS-FIB-N
           ADD WS-FIB-PREV TO WS-FIB-CURR GIVING WS-FIB-NEXT
           MOVE WS-FIB-CURR TO WS-FIB-PREV
           MOVE WS-FIB-NEXT TO WS-FIB-CURR
           DISPLAY "Fibonacci(" WS-INDEX ") = " WS-FIB-CURR
       END-PERFORM.

       DISPLAY "Variation 3: Approximate Golden Ratio".
       COMPUTE WS-FIB-NEXT = WS-FIB-PREV + WS-FIB-CURR
       PERFORM VARYING WS-INDEX FROM 3 BY 1 UNTIL WS-INDEX > WS-FIB-N
           ADD WS-FIB-PREV TO WS-FIB-CURR GIVING WS-FIB-NEXT
           DISPLAY "Ratio F(" WS-INDEX ")/F(" WS-INDEX-1 ") = " WS-FIB-NEXT / WS-FIB-CURR
           MOVE WS-FIB-CURR TO WS-FIB-PREV
           MOVE WS-FIB-NEXT TO WS-FIB-CURR
       END-PERFORM.

       *-----------------------------*
       * LESSON 3: Prime Numbers
       *-----------------------------*
       DISPLAY "Lesson 3: Prime Numbers".

       PERFORM VARYING WS-NUMBER FROM 2 BY 1 UNTIL WS-NUMBER > WS-PRIME-N
           MOVE 'Y' TO WS-IS-PRIME
           PERFORM VARYING WS-DIVISOR FROM 2 BY 1 UNTIL WS-DIVISOR >= WS-NUMBER
               IF WS-NUMBER MOD WS-DIVISOR = 0 AND WS-DIVISOR NOT = WS-NUMBER
                   MOVE 'N' TO WS-IS-PRIME
               END-IF
           END-PERFORM
           IF WS-IS-PRIME = 'Y'
               DISPLAY "Prime: " WS-NUMBER
           END-IF
       END-PERFORM.

       DISPLAY "Variation 2: Factorization".
       PERFORM VARYING WS-NUMBER FROM 10 BY 1 UNTIL WS-NUMBER > 20
           DISPLAY "Factors of " WS-NUMBER ": "
           PERFORM VARYING WS-DIVISOR FROM 1 BY 1 UNTIL WS-DIVISOR > WS-NUMBER
               IF WS-NUMBER MOD WS-DIVISOR = 0
                   DISPLAY WS-DIVISOR WITH NO ADVANCING
                   DISPLAY " " WITH NO ADVANCING
               END-IF
           END-PERFORM
           DISPLAY ""
       END-PERFORM.

       DISPLAY "Variation 3: Sum of primes below N".
       MOVE 0 TO WS-PRIME-COUNT
       PERFORM VARYING WS-NUMBER FROM 2 BY 1 UNTIL WS-NUMBER > 30
           MOVE 'Y' TO WS-IS-PRIME
           PERFORM VARYING WS-DIVISOR FROM 2 BY 1 UNTIL WS-DIVISOR >= WS-NUMBER
               IF WS-NUMBER MOD WS-DIVISOR = 0 AND WS-DIVISOR NOT = WS-NUMBER
                   MOVE 'N' TO WS-IS-PRIME
               END-IF
           END-PERFORM
           IF WS-IS-PRIME = 'Y'
               ADD WS-NUMBER TO WS-PRIME-COUNT
           END-IF
       END-PERFORM
       DISPLAY "Sum of primes < 30 = " WS-PRIME-COUNT.

       *-----------------------------*
       * LESSON 4: Matrix Operations
       *-----------------------------*
       DISPLAY "Lesson 4: Matrix Operations".

       * Initialize matrices
       MOVE 1 TO MA-COL(1,1) MOVE 2 TO MA-COL(1,2)
       MOVE 3 TO MA-COL(2,1) MOVE 4 TO MA-COL(2,2)
       MOVE 5 TO MB-COL(1,1) MOVE 6 TO MB-COL(1,2)
       MOVE 7 TO MB-COL(2,1) MOVE 8 TO MB-COL(2,2)

       DISPLAY "Variation 1: Matrix Addition".
       PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 2
           PERFORM VARYING WS-NUMBER FROM 1 BY 1 UNTIL WS-NUMBER > 2
               ADD MA-COL(WS-INDEX,WS-NUMBER) TO MB-COL(WS-INDEX,WS-NUMBER)
                   GIVING MC-COL(WS-INDEX,WS-NUMBER)
               DISPLAY MC-COL(WS-INDEX,WS-NUMBER) WITH NO ADVANCING
               DISPLAY " " WITH NO ADVANCING
           END-PERFORM
           DISPLAY ""
       END-PERFORM.

       DISPLAY "Variation 2: Matrix Multiplication".
       PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 2
           PERFORM VARYING WS-NUMBER FROM 1 BY 1 UNTIL WS-NUMBER > 2
               COMPUTE MC-COL(WS-INDEX,WS-NUMBER) =
                   (MA-COL(WS-INDEX,1) * MB-COL(1,WS-NUMBER)) +
                   (MA-COL(WS-INDEX,2) * MB-COL(2,WS-NUMBER))
               DISPLAY MC-COL(WS-INDEX,WS-NUMBER) WITH NO ADVANCING
               DISPLAY " " WITH NO ADVANCING
           END-PERFORM
           DISPLAY ""
       END-PERFORM.

       DISPLAY "Variation 3: Determinant of Matrix A".
       COMPUTE WS-FUTURE = (MA-COL(1,1)*MA-COL(2,2)) - (MA-COL(1,2)*MA-COL(2,1))
       DISPLAY "Determinant = " WS-FUTURE

       *-----------------------------*
       * LESSON 5: Floating Point Computation
       *-----------------------------*
       DISPLAY "Lesson 5: Floating Point & Equations".

       DISPLAY "Variation 1: Quadratic Roots".
       COMPUTE WS-C = 2.00
       COMPUTE WS-D = -4.00
       COMPUTE WS-X = (-WS-D + FUNCTION SQRT(WS-D**2 - 4*WS-A*WS-C))/(2*WS-A)
       COMPUTE WS-Y = (-WS-D - FUNCTION SQRT(WS-D**2 - 4*WS-A*WS-C))/(2*WS-A)
       DISPLAY "Roots: " WS-X " , " WS-Y

       DISPLAY "Variation 2: Compound Interest".
       COMPUTE WS-FUTURE = WS-INTEREST * (1 + WS-RATE/100)**WS-YEARS
       DISPLAY "Future Value = " WS-FUTURE

       DISPLAY "Variation 3: Solve 2x2 Linear Equation".
       * Solve:
       *   1.5x + 2.5y = 10
       *   2.0x + 1.5y = 8
       COMPUTE WS-X = (10*1.5 - 2.5*8)/(1.5*1.5 - 2.5*2.0)
       COMPUTE WS-Y = (10 - 1.5*WS-X)/2.5
       DISPLAY "Solution x=" WS-X " y=" WS-Y

       DISPLAY "===============================".
       DISPLAY " END OF LESSONS ".
       DISPLAY "===============================".

       STOP RUN.