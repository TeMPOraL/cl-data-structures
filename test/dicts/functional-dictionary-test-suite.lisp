(in-package :cl-user)
(defpackage functional-dictionary-test-suite
  (:use :cl :prove :serapeum :cl-ds :iterate :alexandria)
  (:shadowing-import-from :iterate :collecting :summing :in)
  (:export :run-suite))
(in-package :functional-dictionary-test-suite)

(setf prove:*enable-colors* nil)

(let ((path (asdf:system-relative-pathname :cl-data-structures "test/files/words.txt")))
  (defun read-all-words ()
    (let ((result (vect)))
      (with-open-file (str path)
        (iterate
          (for word = (read-line str nil nil))
          (while word)
          (vector-push-extend word result)))
      result)))

(defvar *all-words* (read-all-words))

(defmacro insert-every-word (init-form limit)
  (once-only (limit)
    `(let ((dict ,init-form))
       (is (size dict) 0)
       (iterate
         (for s from 1 below ,limit)
         (for word in-vector *all-words*)
         (ok (not (cl-ds:at dict word)))
         (multiple-value-bind (next replaced old) (cl-ds:insert dict word word)
           (setf dict next)
           (is replaced nil)
           (is old nil))
         (multiple-value-bind (v f) (at dict word)
           (is v word :test #'string=)
           (ok f))
         (is (size dict) s))
       (iterate
         (for word in-vector *all-words*)
         (for s from 1 below ,limit)
         (multiple-value-bind (v f) (at dict word)
           (is v word :test #'string=)
           (ok f)))
       (iterate
         (for word in-vector *all-words*)
         (for s from 1 below ,limit)
         (multiple-value-bind (v u o) (update dict word s)
           (is o word :test #'string=)
           (ok u)
           (setf dict v)))
       (iterate
         (for s from 1 below ,limit)
         (for word in-vector *all-words*)
         (multiple-value-bind (v a) (add dict word s)
           (is a nil)
           (is (size dict) (size v))))
       (iterate
         (for s from ,limit)
         (repeat ,limit)
         (while (< s (fill-pointer *all-words*)))
         (for word = (aref *all-words* s))
         (multiple-value-bind (v a) (add dict word s)
           (is a t)
           (is (1+ (size dict)) (size v))
           (setf dict v))))))


(let ((path (asdf:system-relative-pathname :cl-data-structures "test/dicts/result.txt")))
  (defun run-suite (limit)
    (with-open-file (str path :direction :output :if-exists :supersede)
      (let ((prove:*test-result-output* str))
        (format t "Running functional HAMT tests, output redirected to ~a:~%" path)
        (format str "Running functional HAMT tests:~%")
        (time (insert-every-word (cl-ds.dicts.hamt:make-functional-hamt-dictionary #'sxhash #'string=) limit))))))
