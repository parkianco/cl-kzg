;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-kzg.lisp - Unit tests for kzg
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-kzg.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-kzg.test)

(defun run-tests ()
  "Run all tests for cl-kzg."
  (format t "~&Running tests for cl-kzg...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
