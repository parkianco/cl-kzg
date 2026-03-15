;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-kzg)

;;; Core types for cl-kzg
(deftype cl-kzg-id () '(unsigned-byte 64))
(deftype cl-kzg-status () '(member :ready :active :error :shutdown))
