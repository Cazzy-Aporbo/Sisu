;;; CazzyLispMagic.lisp
;;; Author: Cazzy
;;; Purpose: Showcase advanced Lisp concepts, recursion, macros, and interactive learning
;;; Features: Recursive math puzzles, symbolic computation, interactive patterns

;;; ------------------------------
;;; 1. Recursive factorial with interactive explanation
;;; ------------------------------
(defun factorial (n)
  "Compute factorial recursively. Explains each step."
  (if (<= n 1)
      (progn (format t "~&Reached base case: factorial(1) = 1") 1)
      (let ((result (* n (factorial (- n 1)))))
        (format t "~&factorial(~d) = ~d" n result)
        result)))

;;; Example usage:
;;; (factorial 5)

;;; ------------------------------
;;; 2. Symbolic differentiation (simple polynomials)
;;; ------------------------------
(defun differentiate (expr var)
  "Differentiate a simple polynomial expression wrt var."
  (cond
    ((numberp expr) 0)
    ((symbolp expr) (if (eq expr var) 1 0))
    ((listp expr)
     (case (car expr)
       (+ (mapcar (lambda (x) (differentiate x var)) (cdr expr)))
       (- (mapcar (lambda (x) (differentiate x var)) (cdr expr)))
       (* (let ((u (cadr expr)) (v (caddr expr)))
            `(+ (* ,(differentiate u var) ,v) (* ,u ,(differentiate v var))))))
       (t (error "Unsupported expression"))))
    (t (error "Invalid expression"))))

;;; Example usage:
;;; (differentiate '(* x x) 'x)  ; Should return (+ (* 1 x) (* x 1))

;;; ------------------------------
;;; 3. ASCII fractal tree generator (recursive)
;;; ------------------------------
(defun draw-tree (height)
  "Draw an ASCII tree recursively."
  (labels ((draw (h indent)
             (when (> h 0)
               (format t "~v@T~%" indent)
               (format t "~v@T*~%" indent)
               (draw (- h 1) (- indent 2))
               (draw (- h 1) (+ indent 2)))))
    (draw height 40)))

;;; Example usage:
;;; (draw-tree 5)

;;; ------------------------------
;;; 4. Interactive Math Quiz
;;; ------------------------------
(defun math-quiz ()
  "Ask 5 random math questions interactively."
  (dotimes (i 5)
    (let* ((a (+ 1 (random 10)))
           (b (+ 1 (random 10)))
           (answer (* a b)))
      (format t "~&Question ~d: What is ~d * ~d? " (1+ i) a b)
      (let ((input (read)))
        (if (= input answer)
            (format t " ✅ Correct!")
            (format t " ❌ Wrong, correct answer is ~d" answer))))))

;;; Run quiz with:
;;; (math-quiz)

;;; ------------------------------
;;; 5. Macro for code logging
;;; ------------------------------
(defmacro log-eval (expr)
  "Evaluates expr and prints both the expression and result."
  `(let ((result ,expr))
     (format t "~&Evaluating: ~S => ~S" ',expr result)
     result))

;;; Example usage:
;;; (log-eval (+ 2 3))
;;; (log-eval (factorial 4))

;;; ------------------------------
;;; 6. Fun procedural pattern generator
;;; ------------------------------
(defun procedural-pattern (n)
  "Generates a simple numeric pattern recursively."
  (when (> n 0)
    (format t "~d " n)
    (procedural-pattern (- n 1))
    (format t "~d " n)))

;;; Example usage:
;;; (procedural-pattern 5)  ; Output: 5 4 3 2 1 1 2 3 4 5

;;; ------------------------------
;;; Ready for the user to explore
;;; ------------------------------
(format t "~&Welcome to CazzyLispMagic! Try evaluating functions interactively.")
(format t "~&Examples: (factorial 5), (differentiate '(* x x) 'x), (draw-tree 5), (math-quiz), (procedural-pattern 5)")