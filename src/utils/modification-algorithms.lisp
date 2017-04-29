(in-package :cl-ds.utils)


(-> lastpop ((and vector (not simple-array))) t)
(defun lastpop (vector)
  (unless (zerop (fill-pointer vector))
    (prog1
        (aref vector (1- (fill-pointer vector)))
      (decf (fill-pointer vector)))))


(-> erase-from-vector (vector list) vector)
(defun erase-from-vector (vector indexes)
  (iterate (for el in indexes)
    (for i from 0)
    (for index = (- el i))
    (replace vector vector
             :start1 index
             :start2 (1+ index))
    (finally (progn (decf (fill-pointer vector) (1+ i))
                    (return vector)))))


(-> swapop ((AND VECTOR (NOT SIMPLE-ARRAY)) index) vector)
(defun swapop (vector index)
  "Swaps element under index with last element. Pops last element and returns vector.
   :values and parameters"
  (unless (zerop (fill-pointer vector))
    (rotatef (aref vector (1- (fill-pointer vector)))
             (aref vector index))
    (decf (fill-pointer vector)))
  vector)