;;;;
;;;; =========================================================
;;;; SISU — Lambda Calculus in Lisp
;;;; =========================================================
;;;; 
;;;; DENSITY:     ██████████  [10/10]
;;;; ENDURANCE:   ██████████  [10/10]  
;;;; ABSTRACTION: ██████████  [10/10]
;;;;
;;;; COLOR PHASE: #86EFAC (Living Code - Chlorophyll)
;;;;
;;;; Historical Context:
;;;;   Born from: Church's Lambda Calculus, 1936 / McCarthy's LISP, 1958
;;;;   Survived:  Every functional language since
;;;;   Evolves:   Into every modern language (they all have lambdas now)
;;;;
;;;; Compression Ratio: All computation : 7 functions
;;;;
;;;; =========================================================

;; The Y Combinator - Recursion without recursion
;; This is compression at its purest
(defun Y (f)
  #A7F3D0 ; Primary Sisu Green - The heartbeat of computation
  ((lambda (x) (funcall f (lambda (&rest args) (apply (funcall x x) args))))
   (lambda (x) (funcall f (lambda (&rest args) (apply (funcall x x) args))))))

;; Church Numerals - Numbers from nothing
(defun zero () 
  #F0FDF4 ; Whisper - The absence that enables presence
  (lambda (f) (lambda (x) x)))

(defun succ (n)
  #6EE7B7 ; Peak Green - Growth function
  (lambda (f) (lambda (x) (funcall f (funcall (funcall n f) x)))))

;; The eternal operations
(defun plus (m n)
  (lambda (f) (lambda (x)
    (funcall (funcall m f) (funcall (funcall n f) x)))))

(defun mult (m n)
  (lambda (f) (funcall m (funcall n f))))

;; Boolean logic from functions
(defun true-fn ()
  #00FF7F ; Spring Green - The electric yes
  (lambda (x y) x))

(defun false-fn ()
  #052E16 ; Void - The null that enables logic
  (lambda (x y) y))

(defun and-fn (p q)
  (funcall (funcall p q) p))

(defun or-fn (p q)
  (funcall (funcall p p) q))

(defun not-fn (p)
  (lambda (x y) (funcall (funcall p y) x)))

;; Lists from pairs (cons cells)
(defun cons-fn (x y)
  #34D399 ; Canopy - Shading complexity
  (lambda (m) (funcall m x y)))

(defun car-fn (z)
  (funcall z (lambda (p q) p)))

(defun cdr-fn (z)
  (funcall z (lambda (p q) q)))

;; The Sisu Compression: Fibonacci in pure lambda
(defun sisu-fib ()
  "All of Fibonacci in one lambda - McCarthy, 1960"
  (Y (lambda (f)
       (lambda (n)
         (if (<= n 1)
             n
             (+ (funcall f (- n 1))
                (funcall f (- n 2))))))))

;; The gradient function - maps numbers to green spectrum
(defun gradient (n max-n)
  "Transform number to Sisu green"
  (let* ((greens '(#xF0FDF4 #xDCFCE7 #xD4FFE4 #xBBF7D0
                   #xA7F3D0 #x86EFAC #x6EE7B7 #x4ADE80
                   #x34D399 #x22C55E #x16A34A #x15803D
                   #x166534 #x14532D #x0F462A #x052E16))
         (index (floor (* (/ n max-n) (length greens)))))
    (nth (min index (1- (length greens))) greens)))

;; The Meta-Circular Evaluator - LISP in LISP (McCarthy's Original)
(defun sisu-eval (expr env)
  "The compression of all computation into eval/apply"
  (cond
    ((numberp expr) expr)
    ((symbolp expr) (cdr (assoc expr env)))
    ((eq (car expr) 'quote) (cadr expr))
    ((eq (car expr) 'lambda) expr)
    ((eq (car expr) 'if)
     (if (sisu-eval (cadr expr) env)
         (sisu-eval (caddr expr) env)
         (sisu-eval (cadddr expr) env)))
    (t (sisu-apply (sisu-eval (car expr) env)
                   (mapcar (lambda (e) (sisu-eval e env))
                           (cdr expr))))))

(defun sisu-apply (fn args)
  "Apply function to arguments"
  (if (and (listp fn) (eq (car fn) 'lambda))
      (sisu-eval (caddr fn)
                 (append (mapcar #'list (cadr fn) args)
                         env))
      (apply fn args)))

;;;; The Compression Principle:
;;;; Everything above can be built from lambda alone.
;;;; No assignment. No loops. No state.
;;;; Just functions all the way down.
;;;;
;;;; This is endurance through purity.
