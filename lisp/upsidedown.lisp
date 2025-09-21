;;; CazzyLispAbyss.lisp
;;; Author: Cazzy
;;; Purpose: Upside-down, peculiar, exploratory Lisp universe
;;; Features: Inverted recursion, emergent laws, self-modifying nodes, strange patterns

(defstruct abyss-node
  id
  value
  children
  inverted) ;; boolean flag for upside-down behavior

(defparameter *abyss-universe* nil "Global upside-down node universe.")

;;; ------------------------------
;;; Spawn the inverted universe
;;; ------------------------------
(defun spawn-abyss (depth breadth &optional (parent-id 0))
  "Recursively spawn a universe of upside-down nodes."
  (when (> depth 0)
    (let ((node (make-abyss-node
                 :id (+ parent-id (random 1000))
                 :value (random 50)
                 :children nil
                 :inverted (oddp (random 2)))))
      (setf (abyss-node-children node)
            (loop for i from 1 to breadth collect (spawn-abyss (- depth 1) breadth (+ parent-id i))))
      node)))

(defun initialize-abyss ()
  "Initialize the global upside-down universe."
  (setf *abyss-universe* (list (spawn-abyss 4 3))))

;;; ------------------------------
;;; Explore nodes with peculiar upside-down logic
;;; ------------------------------
(defun invert-value (n)
  "Inverts numeric value in a strange, peculiar way."
  (if (evenp n)
      (- n (* 3 n))
      (+ n (* 2 n 2))))

(defun explore-abyss (node level)
  "Recursively explore and mutate nodes with inverted rules."
  (when node
    (let ((old-value (abyss-node-value node)))
      (setf (abyss-node-value node)
            (if (abyss-node-inverted node)
                (invert-value old-value)
                (+ old-value (random 7)))))
    (dolist (c (abyss-node-children node))
      (explore-abyss c (1+ level)))))

;;; ------------------------------
;;; Emergent peculiar sequences
;;; ------------------------------
(defun abyss-sequence (node)
  "Generate strange mirrored sequences from node values."
  (let ((seq (loop for i from 1 to (+ 1 (abyss-node-value node))
                   collect (if (oddp i) (- i) (* i i)))))
    (format t "~&Node ~D sequence: ~S" (abyss-node-id node) seq)
    seq))

(defun generate-abyss-sequences ()
  "Traverse universe and create emergent sequences."
  (labels ((walk (n)
             (when n
               (abyss-sequence n)
               (dolist (c (abyss-node-children n)) (walk c)))))
    (dolist (n *abyss-universe*) (walk n))))

;;; ------------------------------
;;; Self-modifying emergent rules
;;; ------------------------------
(defun mutate-abyss-node (node)
  "Mutate node value and its inversion flag."
  (setf (abyss-node-value node) (+ (abyss-node-value node) (random 10)))
  (setf (abyss-node-inverted node) (not (abyss-node-inverted node)))
  (dolist (c (abyss-node-children node)) (mutate-abyss-node c)))

(defun evolve-abyss ()
  "Perform multi-step evolution of the inverted universe."
  (dolist (n *abyss-universe*)
    (mutate-abyss-node n)
    (explore-abyss n 0)))

;;; ------------------------------
;;; Interactive exploration
;;; ------------------------------
(defun probe-node (id)
  "Return node by id, explore it in strange ways."
  (labels ((search (node)
             (when node
               (if (= (abyss-node-id node) id) node
                   (loop for c in (abyss-node-children node)
                         thereis (search c))))))
    (let ((n (search (first *abyss-universe*))))
      (if n
          (progn (format t "~&Probing node ~D: value ~D, inverted ~A"
                         (abyss-node-id n) (abyss-node-value n) (abyss-node-inverted n))
                 (explore-abyss n 0)
                 (abyss-sequence n))
          (format t "~&Node ~D not found" id)))))

;;; ------------------------------
;;; Entry Point
;;; ------------------------------
(defun launch-abyss ()
  "Spawn, evolve, and explore the upside-down universe."
  (initialize-abyss)
  (evolve-abyss)
  (generate-abyss-sequences)
  (format t "~&🔹 Abyssal exploration complete. Probe nodes to discover peculiar behaviors!"))

;;; ------------------------------
;;; Run
;;; ------------------------------
(launch-abyss)