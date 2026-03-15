;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Package definition for cl-kzg

(defpackage #:cl-kzg
  (:use #:cl)
  (:export
   ;; Constants
   #:+kzg-default-curve+

   ;; Field Elements
   #:field-element
   #:field-element-p
   #:make-field-element
   #:field-element-value
   #:field-element-curve
   #:field-add
   #:field-sub
   #:field-mul
   #:field-neg
   #:field-inv
   #:field-div
   #:field-exp
   #:field-prime
   #:scalar-order

   ;; G1 Points
   #:g1-point
   #:g1-point-p
   #:make-g1-point
   #:g1-point-x
   #:g1-point-y
   #:g1-point-curve
   #:g1-generator
   #:g1-add
   #:g1-double
   #:g1-scalar-mul

   ;; G2 Points
   #:g2-point
   #:g2-point-p
   #:make-g2-point
   #:g2-point-x
   #:g2-point-y
   #:g2-point-curve
   #:g2-generator
   #:g2-add
   #:g2-scalar-mul

   ;; Pairing
   #:pairing

   ;; Polynomials
   #:polynomial
   #:polynomial-p
   #:make-polynomial
   #:polynomial-coeffs
   #:poly-degree
   #:poly-add
   #:poly-sub
   #:poly-mul
   #:poly-eval
   #:poly-divide

   ;; KZG SRS
   #:kzg-srs
   #:kzg-srs-p
   #:make-kzg-srs
   #:kzg-srs-g1-powers
   #:kzg-srs-g2-powers
   #:kzg-srs-max-degree
   #:kzg-srs-curve

   ;; KZG Commitment
   #:kzg-commitment
   #:kzg-commitment-p
   #:kzg-commitment-point
   #:kzg-commitment-curve

   ;; KZG Opening
   #:kzg-opening
   #:kzg-opening-p
   #:kzg-opening-point
   #:kzg-opening-value
   #:kzg-opening-eval-point
   #:kzg-opening-curve

   ;; KZG Protocol
   #:kzg-setup
   #:kzg-commit
   #:kzg-open
   #:kzg-verify
   #:kzg-batch-open
   #:kzg-batch-verify

   ;; Commitment Operations
   #:kzg-commitment-add
   #:kzg-commitment-scale

   ;; Errors
   #:kzg-error))
