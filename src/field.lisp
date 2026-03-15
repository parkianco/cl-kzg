;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Field arithmetic for KZG commitments

(in-package #:cl-kzg)

;;; ============================================================================
;;; Constants
;;; ============================================================================

(defconstant +kzg-default-curve+ :bn254
  "Default elliptic curve for KZG commitments.")

;;; ============================================================================
;;; Curve Parameters
;;; ============================================================================

(defun field-prime (curve)
  "Get the field prime for a curve."
  (case curve
    (:bn254 21888242871839275222246405745257275088696311157297823662689037894645226208583)
    (:bls12-381 52435875175126190479447740508185965837690552500527637822603658699938581184513)
    (otherwise (error 'kzg-error :message "Unknown curve"))))

(defun scalar-order (curve)
  "Get the scalar field order (group order) for a curve."
  (case curve
    (:bn254 21888242871839275222246405745257275088548364400416034343698204186575808495617)
    (:bls12-381 52435875175126190479447740508185965837690552500527637822603658699938581184513)
    (otherwise (error 'kzg-error :message "Unknown curve"))))

;;; ============================================================================
;;; Error Condition
;;; ============================================================================

(define-condition kzg-error (error)
  ((message :initarg :message :reader kzg-error-message))
  (:report (lambda (c s)
             (format s "KZG Error: ~A" (kzg-error-message c)))))

;;; ============================================================================
;;; Field Element Structure
;;; ============================================================================

(defstruct (field-element (:constructor %make-field-element))
  "A field element in the scalar field."
  (value 0 :type integer)
  (curve +kzg-default-curve+ :type keyword))

(defun make-field-element (value &optional (curve +kzg-default-curve+))
  "Create a field element, reducing modulo the field prime."
  (%make-field-element
   :value (mod value (scalar-order curve))
   :curve curve))

(defun ensure-field-element (x curve)
  "Ensure x is a field element."
  (if (field-element-p x)
      x
      (make-field-element x curve)))

;;; ============================================================================
;;; Field Arithmetic
;;; ============================================================================

(defun field-add (a b)
  "Add two field elements."
  (let ((curve (field-element-curve a)))
    (make-field-element
     (+ (field-element-value a)
        (field-element-value b))
     curve)))

(defun field-sub (a b)
  "Subtract two field elements."
  (let ((curve (field-element-curve a)))
    (make-field-element
     (- (field-element-value a)
        (field-element-value b))
     curve)))

(defun field-mul (a b)
  "Multiply two field elements."
  (let ((curve (field-element-curve a)))
    (make-field-element
     (* (field-element-value a)
        (field-element-value b))
     curve)))

(defun field-neg (a)
  "Negate a field element."
  (let ((curve (field-element-curve a)))
    (make-field-element
     (- (scalar-order curve) (field-element-value a))
     curve)))

(defun field-exp (base exp)
  "Exponentiation using square-and-multiply."
  (let* ((curve (field-element-curve base))
         (p (scalar-order curve))
         (result 1)
         (b (field-element-value base))
         (e (if (field-element-p exp)
                (field-element-value exp)
                exp)))
    (loop while (> e 0) do
      (when (oddp e)
        (setf result (mod (* result b) p)))
      (setf b (mod (* b b) p))
      (setf e (ash e -1)))
    (make-field-element result curve)))

(defun field-inv (a)
  "Compute multiplicative inverse using Fermat's little theorem."
  (let* ((curve (field-element-curve a))
         (p (scalar-order curve)))
    (when (zerop (field-element-value a))
      (error 'kzg-error :message "Cannot invert zero"))
    (field-exp a (- p 2))))

(defun field-div (a b)
  "Divide two field elements."
  (field-mul a (field-inv b)))
