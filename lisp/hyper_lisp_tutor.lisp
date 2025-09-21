;;; =====================================================
;;; File: hyper_lisp_tutor.lisp
;;; Author: Cazzy
;;; Purpose: Production-level Lisp tutor and simulator
;;; Features:
;;; - Interactive step-by-step explanation
;;; - Advanced Lisp concepts: macros, closures, dynamic scope
;;; - Visualized computation
;;; - Mini simulation project
;;; =====================================================

;;; -------------------------
;;; Utilities: Colors & Logging
;;; -------------------------
(defparameter *green* "\033[32m")
(defparameter *blue* "\033[34m")
(defparameter *red* "\033[31m")
(defparameter *reset* "\033[0m")

(defun log-info (msg) (format t "~a[INFO]~a ~a~%" *blue* *reset* msg))
(defun log-success (msg) (format t "~a[SUCCESS]~a ~a~%" *green* *reset* msg))
(defun log-error (msg) (format t "~a[ERROR]~a ~a~%" *red* *reset* msg))

;;; -------------------------
;;; 1. Dynamic & Lexical Scope
;;; -------------------------
(defparameter *dynamic-var* "I am dynamic!")

(defun demo-scope ()
  (let ((lexical "I am lexical"))
    (flet ((inner () (format t "Inner sees lexical: ~a~%" lexical)
                    (format t "Inner sees dynamic: ~a~%" *dynamic-var*)))
      (log-info "Demonstrating scope:")
      (inner)
      (let ((*dynamic-var* "I am shadowed dynamically!"))
        (inner)))))

;;; -------------------------
;;; 2. Closures & Higher-Order Functions
;;; -------------------------
(defun make-counter (start)
  "Returns a closure that counts up from start"
  (let ((count start))
    (lambda ()
      (incf count)
      count)))

(defun demo-closures ()
  (log-info "Demonstrating closures with counters:")
  (let ((c1 (make-counter 10))
        (c2 (make-counter 100)))
    (format t "Counter 1: ~a~%" (funcall c1))
    (format t "Counter 1: ~a~%" (funcall c1))
    (format t "Counter 2: ~a~%" (funcall c2))
    (format t "Counter 1: ~a~%" (funcall c1))))

;;; -------------------------
;;; 3. Macros: Build Your Own Language
;;; -------------------------
(defmacro unless (condition &body body)
  `(if (not ,condition)
       (progn ,@body)))

(defun demo-macros ()
  (log-info "Demonstrating macros:")
  (let ((x 5))
    (unless (> x 10)
      (log-success "x is not greater than 10!"))))

;;; -------------------------
;;; 4. Destructuring & Pattern Matching
;;; -------------------------
(defun demo-destructuring ()
  (log-info "Demonstrating list destructuring:")
  (let ((lst '(1 2 3)))
    (destructuring-bind (a b c) lst
      (format t "a=~a, b=~a, c=~a~%" a b c))))

;;; -------------------------
;;; 5. Mini Simulation: Forest Creatures
;;; -------------------------
(defstruct creature
  name
  (energy 10)
  (x 0)
  (y 0))

(defparameter *forest* (list (make-creature :name "Rabbit")
                              (make-creature :name "Fox")
                              (make-creature :name "Wolf")))

(defun move-creature (c max-x max-y)
  (setf (creature-x c) (random max-x))
  (setf (creature-y c) (random max-y))
  c)

(defun interact-creatures (c1 c2)
  (when (and (= (creature-x c1) (creature-x c2))
             (= (creature-y c1) (creature-y c2)))
    (log-info (format nil "~a meets ~a!" (creature-name c1) (creature-name c2)))
    (when (string= (creature-name c1) "Fox")
      (setf (creature-energy c1) (+ 5 (creature-energy c1)))
      (setf (creature-energy c2) 0)
      (log-success "Fox hunted the prey!"))))

(defun run-simulation (steps width height)
  (loop for s from 1 to steps do
       (format t "~%~a=== Step ~a ===~%" *blue* s)
       ;; Move all creatures
       (dolist (c *forest*)
         (move-creature c width height)
         (format t "~a is at (~a,~a) with energy ~a~%"
                 (creature-name c) (creature-x c) (creature-y c) (creature-energy c)))
       ;; Interactions
       (loop for i from 0 below (length *forest*) do
            (loop for j from (1+ i) below (length *forest*) do
                 (interact-creatures (nth i *forest*) (nth j *forest*))))))

;;; -------------------------
;;; 6. Interactive Tutor
;;; -------------------------
(defun interactive-tutor ()
  (log-info "Welcome to Hyper-Lisp Tutor!")
  (demo-scope)
  (demo-closures)
  (demo-macros)
  (demo-destructuring)
  (log-info "Running Forest Simulation (5 steps)...")
  (run-simulation 5 5 5)
  (log-success "Tutorial Complete! You’ve seen advanced Lisp in action."))

;;; -------------------------
;;; Main Entry
;;; -------------------------
(defun main ()
  (interactive-tutor))

(main)