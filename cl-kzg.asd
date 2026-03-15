;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause
;;;;
;;;; cl-kzg.asd - ASDF system definition for KZG polynomial commitments

(asdf:defsystem #:cl-kzg
  :description "Pure Common Lisp KZG polynomial commitment scheme"
  :author "Parkian Company LLC"
  :license "Apache-2.0"
  :version "0.1.0"
  :depends-on ()
  :serial t
  :components
  ((:file "package")
   (:module "src"
    :serial t
    :components
    ((:file "field")
     (:file "curve")
     (:file "polynomial")
     (:file "kzg")))))

(asdf:defsystem #:cl-kzg/test
  :description "Tests for cl-kzg"
  :depends-on (#:cl-kzg)
  :serial t
  :components ((:module "test"
                :components ((:file "test-kzg"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-kzg.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
