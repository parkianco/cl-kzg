;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause
;;;;
;;;; cl-kzg.asd - ASDF system definition for KZG polynomial commitments

(asdf:defsystem #:cl-kzg
  :description "Pure Common Lisp KZG polynomial commitment scheme"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
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
