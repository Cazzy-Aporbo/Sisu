;;; ============================================
;;; File: lisp_demo.lisp
;;; Author: Cazzy
;;; Purpose: Demonstrate core Lisp concepts clearly
;;; ============================================

;;; ------------------------
;;; 1. Symbols, Numbers, Strings
;;; ------------------------
(defparameter *my-number* 42)        ; a number
(defparameter *my-string* "Hello!")  ; a string
(defparameter *my-symbol* 'world)    ; a symbol

(format t "Number: ~a~%" *my-number*)
(format t "String: ~a~%" *my-string*)
(format t "Symbol: ~a~%" *my-symbol*)

;;; ------------------------
;;; 2. Lists and Basic Operations
;;; ------------------------
(defparameter *my-list* '(1 2 3 4 5))
(format t "Original list: ~a~%" *my-list*)
(format t "First element: ~a~%" (first *my-list*))
(format t "Rest of list: ~a~%" (rest *my-list*))
(format t "Append example: ~a~%" (append *my-list* '(6 7 8)))

;;; ------------------------
;;; 3. Functions
;;; ------------------------
(defun square (x)
  "Return the square of x."
  (* x x))

(format t "Square of 5: ~a~%" (square 5))

(defun factorial (n)
  "Compute factorial recursively."
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(format t "Factorial of 6: ~a~%" (factorial 6))

;;; ------------------------
;;; 4. Higher-Order Functions
;;; ------------------------
(defun map-square (lst)
  "Return a new list with each element squared."
  (mapcar #'square lst))

(format t "Squares of *my-list*: ~a~%" (map-square *my-list*))

(defun filter-even (lst)
  "Return a list of even numbers from lst."
  (remove-if-not #'evenp lst))

(format t "Even numbers from *my-list*: ~a~%" (filter-even *my-list*))

;;; ------------------------
;;; 5. Recursive Tree Example
;;; ------------------------
(defparameter *nested-list* '(1 (2 (3 4) 5) 6))

(defun sum-tree (tree)
  "Sum all numbers in a nested list (tree)."
  (cond
    ((null tree) 0)
    ((numberp (first tree)) (+ (first tree) (sum-tree (rest tree))))
    ((listp (first tree)) (+ (sum-tree (first tree)) (sum-tree (rest tree))))
    (t (sum-tree (rest tree)))))

(format t "Sum of nested list: ~a~%" (sum-tree *nested-list*))

;;; ------------------------
;;; 6. Mini-Project: Simple Expression Evaluator
;;; ------------------------
(defun eval-simple-expr (expr)
  "Evaluate simple arithmetic expressions like (+ 1 2)"
  (cond
    ((numberp expr) expr)
    ((listp expr)
     (let ((op (first expr))
           (args (rest expr)))
       (case op
         (+ (apply #'+ (mapcar #'eval-simple-expr args)))
         (- (apply #'- (mapcar #'eval-simple-expr args)))
         (* (apply #'* (mapcar #'eval-simple-expr args)))
         (/ (apply #'/ (mapcar #'eval-simple-expr args)))
         (otherwise (error "Unknown operator: ~a" op))))))
    (t (error "Invalid expression: ~a" expr))))

(format t "Evaluating (+ 1 2 3): ~a~%" (eval-simple-expr '(+ 1 2 3)))
(format t "Evaluating (* 2 (+ 1 3)): ~a~%" (eval-simple-expr '(* 2 (+ 1 3))))

;;; ============================================
;;; End of Lisp Demo
;;; ============================================