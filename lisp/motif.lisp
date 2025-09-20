;; Run: sbcl --script motif.lisp
(defun windows3 (xs)
  (loop for i from 0 below (- (length xs) 2)
        collect (list (nth i xs) (nth (1+ i) xs) (nth (+ i 2) xs))))

(defun tally (triples)
  (let ((h (make-hash-table :test 'equal)))
    (dolist (t triples) (incf (gethash t h 0)))
    h))

(let* ((seq '(:salary :groceries :utilities :salary :rent :groceries :salary :groceries :rent))
       (motifs (windows3 seq))
       (counts (tally motifs)))
  (maphash (lambda (k v) (format t "~a ~a~%" v k)) counts))
