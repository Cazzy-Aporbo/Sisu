       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-TUTORIAL.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       77 WS-NUMBER1        PIC 9(4) VALUE ZERO.
       77 WS-NUMBER2        PIC 9(4) VALUE ZERO.
       77 WS-RESULT         PIC 9(6) VALUE ZERO.
       77 WS-CHOICE         PIC 9 VALUE ZERO.
       77 WS-NAME           PIC A(20) VALUE SPACES.
       77 WS-INDEX          PIC 9 VALUE 0.
       77 WS-LIST           PIC 9(3) OCCURS 5 TIMES VALUE ZERO.
       77 WS-DESC           PIC X(50) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.

*--------------------------------------------------------
* Chapter 1: Input and Output
*--------------------------------------------------------
           DISPLAY "==============================="
           DISPLAY "CHAPTER 1: INPUT AND OUTPUT"
           DISPLAY "==============================="
           DISPLAY "Enter your name: "
           ACCEPT WS-NAME
           DISPLAY "Hello, " WS-NAME "!"
           DISPLAY "Let's do some calculations..."

*--------------------------------------------------------
* Chapter 2: Arithmetic
*--------------------------------------------------------
           DISPLAY "Enter first number: "
           ACCEPT WS-NUMBER1
           DISPLAY "Enter second number: "
           ACCEPT WS-NUMBER2

           ADD WS-NUMBER1 TO WS-NUMBER2 GIVING WS-RESULT
           DISPLAY "Sum = " WS-RESULT

           SUBTRACT WS-NUMBER2 FROM WS-NUMBER1 GIVING WS-RESULT
           DISPLAY "Difference = " WS-RESULT

           MULTIPLY WS-NUMBER1 BY WS-NUMBER2 GIVING WS-RESULT
           DISPLAY "Product = " WS-RESULT

           DIVIDE WS-NUMBER1 BY WS-NUMBER2 GIVING WS-RESULT
           DISPLAY "Quotient = " WS-RESULT

*--------------------------------------------------------
* Chapter 3: Conditional Logic
*--------------------------------------------------------
           DISPLAY "Choose 1 for Addition, 2 for Subtraction: "
           ACCEPT WS-CHOICE
           EVALUATE WS-CHOICE
               WHEN 1
                   DISPLAY "You chose addition"
               WHEN 2
                   DISPLAY "You chose subtraction"
               WHEN OTHER
                   DISPLAY "Invalid choice"
           END-EVALUATE

*--------------------------------------------------------
* Chapter 4: Arrays (OCCURS)
*--------------------------------------------------------
           DISPLAY "Populating an array..."
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 5
               MOVE WS-INDEX TO WS-LIST(WS-INDEX)
               DISPLAY "Index " WS-INDEX " value " WS-LIST(WS-INDEX)
           END-PERFORM

*--------------------------------------------------------
* Chapter 5: Looping and Iteration
*--------------------------------------------------------
           DISPLAY "Looping example: Counting down..."
           PERFORM VARYING WS-INDEX FROM 5 BY -1 UNTIL WS-INDEX < 1
               DISPLAY "Countdown: " WS-INDEX
           END-PERFORM

*--------------------------------------------------------
* Chapter 6: String Manipulation
*--------------------------------------------------------
           MOVE "COBOL TEACHING EXAMPLE" TO WS-DESC
           DISPLAY "Original string: " WS-DESC
           DISPLAY "First 5 characters: " WS-DESC(1:5)
           DISPLAY "Last 5 characters: " WS-DESC(21:5)

*--------------------------------------------------------
* Chapter 7: Nested Conditionals
*--------------------------------------------------------
           DISPLAY "Nested condition example: "
           IF WS-NUMBER1 > 10
               IF WS-NUMBER2 > 10
                   DISPLAY "Both numbers > 10"
               ELSE
                   DISPLAY "Only first number > 10"
               END-IF
           ELSE
               DISPLAY "First number <= 10"
           END-IF

*--------------------------------------------------------
* Chapter 8: Arithmetic with Loops
*--------------------------------------------------------
           DISPLAY "Summing array with loop..."
           MOVE 0 TO WS-RESULT
           PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 5
               ADD WS-LIST(WS-INDEX) TO WS-RESULT
           END-PERFORM
           DISPLAY "Array sum = " WS-RESULT

*--------------------------------------------------------
* Chapter 9: Simple Functionality Example
*--------------------------------------------------------
           DISPLAY "Check if number is even or odd: "
           IF WS-NUMBER1 MOD 2 = 0
               DISPLAY WS-NUMBER1 " is even"
           ELSE
               DISPLAY WS-NUMBER1 " is odd"
           END-IF

*--------------------------------------------------------
* Chapter 10: Putting it all together
*--------------------------------------------------------
           DISPLAY "Interactive menu example:"
           DISPLAY "1. Add numbers"
           DISPLAY "2. Multiply numbers"
           DISPLAY "Enter choice: "
           ACCEPT WS-CHOICE

           EVALUATE WS-CHOICE
               WHEN 1
                   ADD WS-NUMBER1 TO WS-NUMBER2 GIVING WS-RESULT
               WHEN 2
                   MULTIPLY WS-NUMBER1 BY WS-NUMBER2 GIVING WS-RESULT
               WHEN OTHER
                   DISPLAY "Invalid choice, using addition by default"
                   ADD WS-NUMBER1 TO WS-NUMBER2 GIVING WS-RESULT
           END-EVALUATE
           DISPLAY "Result: " WS-RESULT

           DISPLAY "✅ All chapters completed. COBOL lesson end."
           STOP RUN.