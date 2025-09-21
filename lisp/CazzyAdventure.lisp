;;; CazzyLispUniverse.lisp
;;; Author: Cazzy
;;; Purpose: Ultimate interactive Lisp playground
;;; Features: Math, patterns, symbolic computation, interactive quizzes, procedural generation, emergent exploration

;;; ------------------------------
;;; Utilities
;;; ------------------------------
(defun speak (text)
  "Print text in a fun, playful way like speech synthesis."
  (format t "~&💫 ~A 💫" text))

(defun random-color ()
  "Return a random pastel color name."
  (nth (random 10) '("pink" "mint" "lavender" "peach" "skyblue" "lemon" "apricot" "periwinkle" "rose" "aqua")))

;;; ------------------------------
;;; Recursive Math Explorers
;;; ------------------------------
(defun factorial (n)
  "Recursive factorial with playful explanations."
  (if (<= n 1)
      (progn (speak "Reached base case! Factorial(1)=1") 1)
      (let ((res (* n (factorial (- n 1)))))
        (speak (format nil "factorial(~D) = ~D" n res))
        res)))

(defun fibonacci (n)
  "Compute nth Fibonacci recursively."
  (if (<= n 1) n (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

;;; ------------------------------
;;; Symbolic Adventure
;;; ------------------------------
(defun differentiate (expr var)
  "Differentiate simple polynomials symbolically."
  (cond
    ((numberp expr) 0)
    ((symbolp expr) (if (eq expr var) 1 0))
    ((listp expr)
     (case (car expr)
       (+ (mapcar (lambda (x) (differentiate x var)) (cdr expr)))
       (- (mapcar (lambda (x) (differentiate x var)) (cdr expr)))
       (* (let ((u (cadr expr)) (v (caddr expr)))
            `(+ (* ,(differentiate u var) ,v) (* ,u ,(differentiate v var))))))
       (t (error "Unsupported expression")))
     )
    (t (error "Invalid expression"))))

;;; ------------------------------
;;; Procedural Pattern Magic
;;; ------------------------------
(defun procedural-pattern (n)
  "Recursive numeric pattern generator."
  (when (> n 0)
    (format t "~D " n)
    (procedural-pattern (- n 1))
    (format t "~D " n)))

(defun draw-tree (height)
  "ASCII fractal tree generator."
  (labels ((draw (h indent)
             (when (> h 0)
               (format t "~v@T*~%" indent)
               (draw (- h 1) (- indent 2))
               (draw (- h 1) (+ indent 2)))))
    (draw height 40)))

;;; ------------------------------
;;; Interactive Math & Word Quiz
;;; ------------------------------
(defun math-quiz ()
  "5 random math questions with playful feedback."
  (dotimes (i 5)
    (let* ((a (+ 1 (random 10)))
           (b (+ 1 (random 10)))
           (ans (* a b)))
      (format t "~&Question ~D: What is ~D * ~D? " (1+ i) a b)
      (let ((input (read)))
        (if (= input ans)
            (speak "✅ Correct! 🎉")
            (speak (format nil "❌ Wrong! Answer is ~D" ans)))))))

(defun word-quiz ()
  "Interactive word matching."
  (let ((words '("cat" "dog" "sun" "tree" "flower" "magic" "adventure")))
    (format t "~&Pick a word starting with 'm': ")
    (let ((input (read)))
      (if (string= input "magic")
          (speak "✅ Perfect! You found the magical word!")
          (speak "❌ Not quite, try again next time.")))))

;;; ------------------------------
;;; Emergent Procedural World
;;; ------------------------------
(defun spawn-entity ()
  "Spawn a whimsical entity in the universe."
  (let ((entity (list :name (nth (random 10) '("Pixie" "Sprite" "Blob" "Starling" "Nimbus" "Echo" "Glimmer" "Fizzle" "Aurora" "Luna"))
                      :color (random-color)
                      :energy (random 100))))
    (format t "~&Spawned entity: ~S" entity)
    entity))

(defun explore-universe (n)
  "Spawn multiple entities and interact."
  (dotimes (i n)
    (let ((e (spawn-entity)))
      (speak (format nil "You encountered ~A with energy ~D!" (getf e :name) (getf e :energy))))))

;;; ------------------------------
;;; Macros for Playful Logging
;;; ------------------------------
(defmacro log-eval (expr)
  `(let ((result ,expr))
     (speak (format nil "💡 Evaluating: ~S => ~S" ',expr result))
     result))

;;; ------------------------------
;;; Welcome Message & Instructions
;;; ------------------------------
(speak "🌟 Welcome to CazzyLispUniverse! 🌟")
(speak "Try evaluating factorial, fibonacci, differentiate, procedural-pattern, draw-tree, math-quiz, word-quiz, spawn-entity, explore-universe!")
(speak "Use (log-eval ...) to see your expressions evaluated with playful commentary!")