;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Polynomial operations for KZG

(in-package #:cl-kzg)

;;; ============================================================================
;;; Polynomial Structure
;;; ============================================================================

(defstruct (polynomial (:constructor %make-polynomial))
  "A polynomial represented by its coefficients.
   coeffs[i] is the coefficient of x^i."
  (coeffs #() :type vector))

(defun make-polynomial (coeffs)
  "Create a polynomial from coefficients."
  (%make-polynomial :coeffs (coerce coeffs 'vector)))

(defun poly-degree (p)
  "Return the degree of polynomial p."
  (let ((coeffs (polynomial-coeffs p)))
    (loop for i from (1- (length coeffs)) downto 0
          when (not (zerop (let ((c (aref coeffs i)))
                             (if (field-element-p c)
                                 (field-element-value c)
                                 c))))
            return i
          finally (return 0))))

;;; ============================================================================
;;; Polynomial Arithmetic
;;; ============================================================================

(defun poly-add (a b curve)
  "Add two polynomials."
  (let* ((ca (polynomial-coeffs a))
         (cb (polynomial-coeffs b))
         (len (max (length ca) (length cb)))
         (result (make-array len)))
    (dotimes (i len)
      (let ((ai (if (< i (length ca))
                    (ensure-field-element (aref ca i) curve)
                    (make-field-element 0 curve)))
            (bi (if (< i (length cb))
                    (ensure-field-element (aref cb i) curve)
                    (make-field-element 0 curve))))
        (setf (aref result i) (field-add ai bi))))
    (make-polynomial result)))

(defun poly-sub (a b curve)
  "Subtract polynomial b from a."
  (let* ((ca (polynomial-coeffs a))
         (cb (polynomial-coeffs b))
         (len (max (length ca) (length cb)))
         (result (make-array len)))
    (dotimes (i len)
      (let ((ai (if (< i (length ca))
                    (ensure-field-element (aref ca i) curve)
                    (make-field-element 0 curve)))
            (bi (if (< i (length cb))
                    (ensure-field-element (aref cb i) curve)
                    (make-field-element 0 curve))))
        (setf (aref result i) (field-sub ai bi))))
    (make-polynomial result)))

(defun poly-mul (a b curve)
  "Multiply two polynomials."
  (let* ((ca (polynomial-coeffs a))
         (cb (polynomial-coeffs b))
         (len-a (length ca))
         (len-b (length cb))
         (len-result (+ len-a len-b -1))
         (result (make-array len-result
                             :initial-element (make-field-element 0 curve))))
    (when (or (zerop len-a) (zerop len-b))
      (return-from poly-mul (make-polynomial #())))
    (dotimes (i len-a)
      (dotimes (j len-b)
        (let ((prod (field-mul
                     (ensure-field-element (aref ca i) curve)
                     (ensure-field-element (aref cb j) curve))))
          (setf (aref result (+ i j))
                (field-add (aref result (+ i j)) prod)))))
    (make-polynomial result)))

(defun poly-eval (p x curve)
  "Evaluate polynomial at point x using Horner's method."
  (let* ((coeffs (polynomial-coeffs p))
         (n (length coeffs))
         (x-elem (ensure-field-element x curve))
         (result (make-field-element 0 curve)))
    (when (zerop n)
      (return-from poly-eval result))
    (setf result (ensure-field-element (aref coeffs (1- n)) curve))
    (loop for i from (- n 2) downto 0 do
      (setf result (field-add
                    (field-mul result x-elem)
                    (ensure-field-element (aref coeffs i) curve))))
    result))

(defun poly-divide (dividend divisor curve)
  "Polynomial division. Returns (values quotient remainder)."
  (let* ((a-coeffs (map 'vector
                        (lambda (c) (ensure-field-element c curve))
                        (polynomial-coeffs dividend)))
         (b-coeffs (map 'vector
                        (lambda (c) (ensure-field-element c curve))
                        (polynomial-coeffs divisor)))
         (a-len (length a-coeffs))
         (b-len (length b-coeffs)))
    (when (zerop b-len)
      (error 'kzg-error :message "Division by zero polynomial"))
    (when (< a-len b-len)
      (return-from poly-divide
        (values (make-polynomial #())
                dividend)))
    (let* ((q-len (1+ (- a-len b-len)))
           (q-coeffs (make-array q-len
                                 :initial-element (make-field-element 0 curve)))
           (r-coeffs (copy-seq a-coeffs))
           (lead-b (aref b-coeffs (1- b-len)))
           (lead-b-inv (field-inv lead-b)))
      (loop for i from (1- a-len) downto (1- b-len) do
        (let* ((lead-r (aref r-coeffs i))
               (coef (field-mul lead-r lead-b-inv))
               (q-idx (- i (1- b-len))))
          (setf (aref q-coeffs q-idx) coef)
          (loop for j from 0 below b-len do
            (let ((r-idx (+ q-idx j)))
              (setf (aref r-coeffs r-idx)
                    (field-sub (aref r-coeffs r-idx)
                               (field-mul coef (aref b-coeffs j))))))))
      (values (make-polynomial q-coeffs)
              (make-polynomial (subseq r-coeffs 0 (1- b-len)))))))
