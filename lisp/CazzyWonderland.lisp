;;; CazzyLispWonderland.lisp
;;; Author: Cazzy
;;; Purpose: Alice-in-Wonderland-esque exploratory Lisp universe
;;; Features: Paradoxical logic, emergent patterns, interactive exploration, upside-down rules

(defstruct wonder-node
  id
  name
  value
  children
  absurdity ;; a number from 1-100 controlling how bizarre transformations are
  reversed) ;; controls logic inversion

(defparameter *wonderland* nil "Global Wonderland node universe.")

;;; ------------------------------
;;; Spawn the Wonderland
;;; ------------------------------
(defun spawn-wonderland (depth breadth &optional (parent-id 0))
  "Recursively spawn nodes with absurd but coherent properties."
  (when (> depth 0)
    (let* ((node-name (format nil "Node-~D-~D" parent-id (random 1000)))
           (node-value (random 50))
           (absurd (1+ (random 100)))
           (rev (evenp (random 2)))
           (node (make-wonder-node :id (+ parent-id (random 1000))
                                   :name node-name
                                   :value node-value
                                   :children nil
                                   :absurdity absurd
                                   :reversed rev)))
      (setf (wonder-node-children node)
            (loop for i from 1 to breadth collect (spawn-wonderland (- depth 1) breadth (+ parent-id i))))
      node)))

(defun initialize-wonderland ()
  "Initialize the Wonderland universe."
  (setf *wonderland* (list (spawn-wonderland 4 3))))

;;; ------------------------------
;;; Absurd but coherent exploration
;;; ------------------------------
(defun transform-node (node)
  "Apply paradoxical rules to node values and absurdity."
  (when node
    (let ((old-value (wonder-node-value node)))
      (setf (wonder-node-value node)
            (if (wonder-node-reversed node)
                ;; reversed logic: smaller becomes bigger, bigger becomes smaller
                (- (* old-value 2) (random (1+ old-value)))
                ;; absurd twist: value plus or minus absurdity
                (+ old-value (random (- (wonder-node-absurdity node) 25 )))
                )))
    (dolist (c (wonder-node-children node))
      (transform-node c))))

;;; ------------------------------
;;; Emergent sequences
;;; ------------------------------
(defun node-sequence (node)
  "Generate a Wonderland-esque numeric sequence."
  (let ((seq (loop for i from 1 to (+ 1 (wonder-node-value node))
                   collect (if (evenp i)
                               (* i i (1+ (random 3)))
                               (- i (random 3))))))
    (format t "~&~A sequence: ~S" (wonder-node-name node) seq)
    seq))

(defun generate-wonderland-sequences ()
  "Traverse nodes and create emergent sequences."
  (labels ((walk (n)
             (when n
               (node-sequence n)
               (dolist (c (wonder-node-children n)) (walk c)))))
    (dolist (n *wonderland*) (walk n))))

;;; ------------------------------
;;; Self-evolving paradoxical rules
;;; ------------------------------
(defun mutate-wonder-node (node)
  "Mutate node values, absurdity, and reversed flag."
  (setf (wonder-node-value node) (+ (wonder-node-value node) (random 7)))
  (setf (wonder-node-absurdity node) (+ (wonder-node-absurdity node) (random 10)))
  (setf (wonder-node-reversed node) (not (wonder-node-reversed node)))
  (dolist (c (wonder-node-children node)) (mutate-wonder-node c)))

(defun evolve-wonderland ()
  "Recursively mutate and transform all nodes to create evolving Wonderland."
  (dolist (n *wonderland*)
    (mutate-wonder-node n)
    (transform-node n)))

;;; ------------------------------
;;; Interactive exploration
;;; ------------------------------
(defun probe-wonder-node (id)
  "Interactively explore a node, revealing its absurd but coherent patterns."
  (labels ((search (node)
             (when node
               (if (= (wonder-node-id node) id) node
                   (loop for c in (wonder-node-children node)
                         thereis (search c))))))
    (let ((n (search (first *wonderland*))))
      (if n
          (progn
            (format t "~&Probing node: ~A (~D), reversed: ~A, absurdity: ~D"
                    (wonder-node-name n) (wonder-node-value n)
                    (wonder-node-reversed n) (wonder-node-absurdity n))
            (transform-node n)
            (node-sequence n))
          (format t "~&Node ~D not found" id)))))

;;; ------------------------------
;;; Launch Wonderland
;;; ------------------------------
(defun launch-wonderland ()
  "Spawn, evolve, and explore Wonderland interactively."
  (initialize-wonderland)
  (evolve-wonderland)
  (generate-wonderland-sequences)
  (format t "~&Welcome to Cazzy's Wonderland! Explore nodes with (probe-wonder-node <id>). Rules are strange, yet somehow make sense."))

;;; ------------------------------
;;; Run
;;; ------------------------------
(launch-wonderland)