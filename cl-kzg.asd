(asdf:defsystem #:cl-kzg
  :depends-on (#:alexandria #:bordeaux-threads)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "cl-kzg" :depends-on ("package"))))))