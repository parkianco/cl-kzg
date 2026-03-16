;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-kzg.test
  (:use #:cl #:cl-kzg)
  (:export #:run-tests))

(in-package #:cl-kzg.test)

(defun run-tests ()
  (format t "Running professional test suite for cl-kzg...~%")
  (assert (initialize-kzg))
  (format t "Tests passed!~%")
  t)
