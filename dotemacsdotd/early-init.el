(defvar mbk/default-gc-cons-threshold gc-cons-threshold
  "Backup of the default GC threshold.")
(defvar mbk/default-gc-cons-percentage gc-cons-percentage
  "Backup of the default GC cons percentage.")
;; and reset it to "normal" when done
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold mbk/default-gc-cons-threshold
                  gc-cons-percentage mbk/default-gc-cons-percentage)))

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      package-enable-at-startup nil     ;; Packages will be initialized by use-package later
      package-archives nil
      frame-inhibit-implied-resize t    ;; Do not resize the frame at this early stage
      ;; comp-deferred-compilation nil     ;; Prevent unwanted runtime builds. Packages are compiled at install and site files are compiled when gccemacs is installed.
      )

;; Ignore Xresources
(advice-add #'x-apply-session-resources :override #'ignore)
;; TODO: Probably the better approach is:
;; (setq inhibit-x-resources t)


;; From doom-emacs
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; user-emacs-directory/lisp contains my elisp snippets
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
