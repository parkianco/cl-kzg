;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Elliptic curve operations for KZG

(in-package #:cl-kzg)

;;; ============================================================================
;;; G1 Point Structure
;;; ============================================================================

(defstruct (g1-point (:constructor %make-g1-point))
  "A point on the G1 curve (affine coordinates)."
  (x 0 :type integer)
  (y 0 :type integer)
  (curve +kzg-default-curve+ :type keyword))

(defun make-g1-point (&key x y (curve +kzg-default-curve+))
  "Create a G1 point."
  (%make-g1-point :x x :y y :curve curve))

(defun g1-generator (curve)
  "Get the generator point for G1."
  (case curve
    (:bn254
     (make-g1-point :x 1 :y 2 :curve curve))
    (:bls12-381
     (make-g1-point
      :x 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507
      :y 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569
      :curve curve))
    (otherwise (error 'kzg-error :message "Unknown curve"))))

;;; ============================================================================
;;; G1 Point Arithmetic
;;; ============================================================================

(defun g1-double (p)
  "Double a G1 point."
  (let* ((curve (g1-point-curve p))
         (prime (field-prime curve))
         (x (g1-point-x p))
         (y (g1-point-y p)))
    (when (zerop y)
      (return-from g1-double (make-g1-point :x 0 :y 0 :curve curve)))
    (let* ((s-num (mod (* 3 x x) prime))
           (s-den (mod-inv (mod (* 2 y) prime) prime))
           (s (mod (* s-num s-den) prime))
           (x3 (mod (- (* s s) (* 2 x)) prime))
           (y3 (mod (- (* s (- x x3)) y) prime)))
      (make-g1-point :x x3 :y y3 :curve curve))))

(defun g1-add (p1 p2)
  "Add two G1 points."
  (let ((curve (g1-point-curve p1)))
    (cond
      ((and (zerop (g1-point-x p1)) (zerop (g1-point-y p1))) p2)
      ((and (zerop (g1-point-x p2)) (zerop (g1-point-y p2))) p1)
      ((and (= (g1-point-x p1) (g1-point-x p2))
            (= (g1-point-y p1) (g1-point-y p2)))
       (g1-double p1))
      (t
       (let* ((prime (field-prime curve))
              (x1 (g1-point-x p1)) (y1 (g1-point-y p1))
              (x2 (g1-point-x p2)) (y2 (g1-point-y p2))
              (s-num (mod (- y2 y1) prime))
              (s-den (mod-inv (mod (- x2 x1) prime) prime))
              (s (mod (* s-num s-den) prime))
              (x3 (mod (- (* s s) x1 x2) prime))
              (y3 (mod (- (* s (- x1 x3)) y1) prime)))
         (make-g1-point :x x3 :y y3 :curve curve))))))

(defun g1-scalar-mul (p scalar)
  "Multiply a G1 point by a scalar using double-and-add."
  (let* ((curve (g1-point-curve p))
         (n (if (field-element-p scalar)
                (field-element-value scalar)
                scalar))
         (result (make-g1-point :x 0 :y 0 :curve curve))
         (temp p))
    (loop while (> n 0) do
      (when (oddp n)
        (setf result (g1-add result temp)))
      (setf temp (g1-double temp))
      (setf n (ash n -1)))
    result))

;;; ============================================================================
;;; G2 Point Structure (over Fp2)
;;; ============================================================================

(defstruct (g2-point (:constructor %make-g2-point))
  "A point on the G2 curve (coordinates in Fp2)."
  (x (cons 0 0) :type cons)  ; (real . imag)
  (y (cons 0 0) :type cons)
  (curve +kzg-default-curve+ :type keyword))

(defun make-g2-point (&key x y (curve +kzg-default-curve+))
  "Create a G2 point."
  (%make-g2-point :x x :y y :curve curve))

(defun g2-generator (curve)
  "Get the generator point for G2."
  (case curve
    (:bn254
     (make-g2-point
      :x (cons 11559732032986387107991004021392285783925812861821192530917403151452391805634
               10857046999023057135944570762232829481370756359578518086990519993285655852781)
      :y (cons 4082367875863433681332203403145435568316851327593401208105741076214120093531
               8495653923123431417604973247489272438418190587263600148770280649306958101930)
      :curve curve))
    (:bls12-381
     (make-g2-point
      :x (cons 0 0) :y (cons 0 0) :curve curve))
    (otherwise (error 'kzg-error :message "Unknown curve"))))

;;; ============================================================================
;;; Fp2 Arithmetic
;;; ============================================================================

(defun fp2-add (a b prime)
  "Add two Fp2 elements."
  (cons (mod (+ (car a) (car b)) prime)
        (mod (+ (cdr a) (cdr b)) prime)))

(defun fp2-mul (a b prime)
  "Multiply two Fp2 elements: (a0 + a1*i)(b0 + b1*i) = (a0*b0 - a1*b1) + (a0*b1 + a1*b0)*i"
  (let ((a0 (car a)) (a1 (cdr a))
        (b0 (car b)) (b1 (cdr b)))
    (cons (mod (- (* a0 b0) (* a1 b1)) prime)
          (mod (+ (* a0 b1) (* a1 b0)) prime))))

;;; ============================================================================
;;; G2 Point Arithmetic
;;; ============================================================================

(defun g2-add (p1 p2)
  "Add two G2 points (simplified)."
  (let ((curve (g2-point-curve p1)))
    (cond
      ((and (zerop (car (g2-point-x p1))) (zerop (cdr (g2-point-x p1)))) p2)
      ((and (zerop (car (g2-point-x p2))) (zerop (cdr (g2-point-x p2)))) p1)
      (t
       ;; Simplified: return first point for non-trivial addition
       (make-g2-point
        :x (fp2-add (g2-point-x p1) (g2-point-x p2) (field-prime curve))
        :y (fp2-add (g2-point-y p1) (g2-point-y p2) (field-prime curve))
        :curve curve)))))

(defun g2-scalar-mul (p scalar)
  "Multiply a G2 point by a scalar."
  (let* ((curve (g2-point-curve p))
         (prime (field-prime curve))
         (n (if (field-element-p scalar)
                (field-element-value scalar)
                scalar)))
    ;; Simplified: scale coordinates
    (make-g2-point
     :x (cons (mod (* (car (g2-point-x p)) n) prime)
              (mod (* (cdr (g2-point-x p)) n) prime))
     :y (cons (mod (* (car (g2-point-y p)) n) prime)
              (mod (* (cdr (g2-point-y p)) n) prime))
     :curve curve)))

;;; ============================================================================
;;; Pairing
;;; ============================================================================

(defun pairing (g1 g2)
  "Compute pairing e(G1, G2) -> GT.
   This is a simplified placeholder - production requires Miller loop."
  (declare (ignore g1 g2))
  ;; Return placeholder GT element
  1)

;;; ============================================================================
;;; Helper: Modular Inverse
;;; ============================================================================

(defun mod-inv (a p)
  "Compute modular inverse of a mod p using extended Euclidean algorithm."
  (when (zerop (mod a p))
    (return-from mod-inv 0))
  (let ((old-r p) (r (mod a p))
        (old-s 0) (s 1))
    (loop while (not (zerop r)) do
      (let ((q (floor old-r r)))
        (psetf old-r r r (- old-r (* q r)))
        (psetf old-s s s (- old-s (* q s)))))
    (if (= old-r 1)
        (mod old-s p)
        (error 'kzg-error :message "No inverse exists"))))
