;; ** Emacs initialization, customization from scratch        -*- lexical-binding: t; -*-
;; Copyright (C) 2021 by Milind Kamble

(setq mbk "hello world")

;;; activate use-package
(eval-when-compile (require 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure nil)  ;; do not install missing packages

(use-package all-the-icons
	     :demand t)

(use-package vertico
  :bind
  (:map vertico-map
        ("C-j" . vertico-next)
        ("C-k" . vertico-previous))
  :init
  (vertico-mode)
  (setq vertico-scroll-margin 0) ;; Scroll margin
  ;; (setq vertico-count 10)        ;; Candidates
  ;; (setq vertico-cycle t)        ;; Enable cycling

  ;; :blackout (foo-mode . " Foo") ; results in (blackout 'foo-mode " Foo")xb

  )

(use-package all-the-icons
  :if (display-graphic-p))
