;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-kzg)

(define-condition cl-kzg-error (error)
  ((message :initarg :message :reader cl-kzg-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-kzg error: ~A" (cl-kzg-error-message condition)))))
