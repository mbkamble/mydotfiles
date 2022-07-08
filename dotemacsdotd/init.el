; ** Emacs initialization, customization from scratch        -*- lexical-binding: t; -*-
;; Copyright (C) 2021 by Milind Kamble

(setq mbk/full-name "Milind Kamble")
(setq mbk/email "milindbkamble@gmail.com")

;; In elisp there is a ignore function, but that evaluates its argument, yielding always nil, whereas comment doesn't evaluate its body. It's useful to temporary disable bits of code.
;; source: https://www.omarpolo.com/dots/emacs.html
(defmacro comment (&rest _body)
  "Ignore BODY, just like `ignore', but this is a macro."
  '())

;; *** `use-package'
;; keywords: config -- for code to run after pacakge is loaded, init -- for code to run before pacakge is loaded
(eval-when-compile (require 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure nil)  ;; do not install missing packages
(setq use-package-always-defer t)

;; *** `emacs' native settings
;; see https://www.reddit.com/r/emacs/comments/mk9ehd/curious_whats_the_use_of_usepackage_emacs/
;; use-package emacs is a special way to keep your settings unrelated to any package.
(use-package emacs
  :custom
  ((require-final-newline t)
   ;; ignore case for completions
   (completion-ignore-case t)
   (read-file-name-completion-ignore-case t)
   (read-buffer-completion-ignore-case t)
   (auto-save-visited-mode +1)
   (auto-save-visited-interval 5)
   )
  :config
  (fset 'yes-or-no-p 'y-or-n-p)
  (setq isearch-lazy-count t  ; Some very small tweaks for isearch
	search-whitespace-regexp ".*?"
	isearch-allow-scroll 'unlimited)
  ;; desktop session save settings
  (setq desktop-restore-frames nil)  ;; uses frame parameters (fonts, faces etc) from init file instead from previous session
  (desktop-save-mode 1)  ;; aito save desktop when exiting Emacs
  ;; :init -- I thhink all the customization can be done in config instead of init
  
  ;; begin recommendation by vertico author
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor to move into prompt area of minibuffer
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; end recommendation by vertico author

  ;; ux elements
  (set-face-attribute 'default nil :family "Victor Mono" :height 120)
  ;; As per https://protesilaos.com/codelog/2020-09-05-emacs-note-mixed-font-heights/
  ;; we need to specify height of other fonts relative to default for text-scaling to work
  ;; implicit height does not work, we need to explicitly specify the :height 1.0
  (set-face-attribute 'fixed-pitch nil :family "Victor Mono" :height 1.0)
  (set-face-attribute 'variable-pitch nil :family "Source Sans 3" :height 1.0)

  ;; begin create a hook to run after load-theme so that we can customize some faces in the theme
  (defvar mbk/after-load-theme-hook nil
    "Hook run after a color theme is loaded using `load-theme'.")
  (defadvice load-theme (after mbk/run-after-load-theme-hook activate)
    "Run `after-load-theme-hook'."
    ;; debug (message (format "mbk: calling run-hooks. mbk/after-load-theme-hook=%s" mbk/after-load-theme-hook))
    (run-hooks 'mbk/after-load-theme-hook))
  (defun mbk/customize-poet ()
    "Customize poet theme"
    (if (member 'poet custom-enabled-themes) ;; use `progn' to add debug msg for `then' clause
	(custom-theme-set-faces 'user  ;; need to use `user'. `poet is overridden by `user''
				'(font-lock-comment-face
				  ((t (:slant italic :weight normal))))))) ;; weight = thin|normal|heavy
  ;; end create after load-theme hook
  ;; modeline customization
  ;;**** customize modeline-modified indicator using chain icon 
  ;; mode-line-modified is a mode line construct for displaying whether current buffer is modified.
  ;; we beautify it with faicon (fa means fontawesome family)
  ;; see also https://github.com/domtronn/all-the-icons.el/wiki/Mode-Line
  (defun mbk/modeline-modified ()
    (let* ((config-alist   ;; hash like datastructure. key . (family icon-select-func parameter-for-icon-select)
	    ;; format-mode-line returns a string representing modified status of current buffer
	    ;; "*" means modifed, "-" means unmodified, "%" means read-on;y
            '(("*" all-the-icons-faicon-family all-the-icons-faicon
               "chain-broken" :height 1.2 :v-adjust -0.0)
              ("-" all-the-icons-faicon-family all-the-icons-faicon
               "link" :height 1.2 :v-adjust -0.0)
              ("%" all-the-icons-octicon-family all-the-icons-octicon
               "lock" :height 1.2 :v-adjust 0.1)))
           (result (cdr (assoc (format-mode-line "%*") config-alist))))

      (propertize (format "%s" (apply (cadr result) (cddr result)))
                  'face `(:family ,(funcall (car result)) :inherit ))))
  (setq-default mode-line-modified '(:eval (mbk/modeline-modified)))
  ;;**** indiccate major-mode by suitable icon
  ;; mode-line-client-mode is ':' for normal frames, @ for emacsclient frames
  ;;**** major mode indicator is constructed by 'mode-name'
  ;; we can change the font to italic by customizing mode-line-buffer-id
  (defun mbk/modeline-mode-name ()
    (let* ((icon (all-the-icons-icon-for-mode major-mode))
	   (face-prop (and (stringp icon) (get-text-property 0 'face icon))))
      (when (and (stringp icon) (not (string= major-mode icon)) face-prop)
	(setq mode-name (propertize icon 'display '(:ascent center))))))
  (add-hook 'after-change-major-mode-hook #'mbk/modeline-mode-name)

  
  (add-to-list
   'load-path (expand-file-name "lisp" user-emacs-directory))
  ) ; end of use-package emacs

;; imenu is a mean of navigation in a buffer. It can act like a TOC, for instance

;; *** `blackout'
(use-package blackout)

;; *** `all-the-icons'
(use-package all-the-icons
  :if (display-graphic-p))
(set-fontset-font t 'unicode (font-spec :family "FontAwesome") nil 'prepend)
(set-fontset-font t 'unicode (font-spec :family "all-the-icons") nil 'prepend)

;; *** `no-littering' - keep files inside user-emacs-directory 
(use-package no-littering
  :demand t
  :commands (no-littering-expand-var-file-name
             no-littering-expand-etc-file-name)
  :config
  ;; (add-to-list 'recentf-exclude no-littering-var-directory)
  ;; (add-to-list 'recentf-exclude no-littering-etc-directory)
  (setq
   auto-save-file-name-transforms     ; transform names of saved files
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))
   backup-directory-alist ; store all backup and autosave files in "backups"
   `((".*" . ,(no-littering-expand-var-file-name "backups/")))
   custom-file (no-littering-expand-etc-file-name "custom.el")))

	     
;; ** Version control
;; *** disable native VC backends since we will use magit 
;; Feature `vc-hooks' provides hooks for the Emacs VC package. We
;; don't use VC, because Magit is superior in pretty much every way.
(use-package vc-hooks
  :config

  ;; Disable VC. This improves performance and disables some annoying
  ;; warning messages and prompts, especially regarding symlinks. See
  ;; https://stackoverflow.com/a/6190338/3538165.
  (setq vc-handled-backends nil))

;; *** visualize and resolve git merge conflicts using feature `smerge-mode'
;; smerge-mode is part of std installation under "vc" subdir
(use-package smerge-mode
  :blackout t)

;; *** use emacs as external editor through package `with-editor'
(use-package with-editor)

;; *** `helpful' is an enhanced help
(use-package helpful
  :bind
  ("C-h f" . #'helpful-callable)
  ("C-h v" . #'helpful-variable)
  ("C-h k" . #'helpful-key)
  ("C-c C-d" .  #'helpful-at-point)
  ("C-h C" . #'helpful-command) 	; override describe-coding-system
  :hook ((helpful-mode . visual-line-mode))
  )

;; *** bookmark
(use-package bookmark
  ;; :bind (("C-z b b" . bookmark-jump)   C-z needs to be a keymap. presently it is bound to command avy-goto-char-2
  ;;        ("C-z b a" . bookmark-set)
  ;;        ("C-z b l" . list-bookmarks))
  )

;; *** `ace-window' and `ace-link' 
(use-package ace-window
  :custom
  (aw-keys '(?a ?o ?e ?u ?h ?t ?n ?s))
  :bind
  ("M-o" . #'ace-window)
  )

(use-package ace-link
  :config (ace-link-setup-default))

;; *** `recently' for accessing recently visited files 
(use-package recently
  :blackout t
  :custom
  (recently-max 3000)
  :bind
  ("C-x C-r" . #'recently-show)
  :config
  (recently-mode +1))

;; *** magit requires package `transient' to display popups.
(use-package transient
  :demand t
  :config

  ;; Allow using `q' to quit out of popups, in addition to `C-g'. See
  ;; <https://magit.vc/manual/transient.html#Why-does-q-not-quit-popups-anymore_003f>
  ;; for discussion.
  (transient-bind-q-to-quit))

(use-package magit
  :preface
  (defun magit-dired-other-window ()
    (interactive)
    (dired-other-window (magit-toplevel)))
  :commands (magit-clone
             magit-toplevel
             magit-read-string-ns
             magit-remote-arguments
             magit-get
             magit-remote-add
             magit-define-popup-action)
  :bind (
	 ;; already defined("C-x g" . #'magit-status)
	 ;; already defined("C-x M-g" . #'magit-dispatch)
	 ;; already defined("C-c M-g" . #'magit-file-dispatch)
         :map magit-mode-map
               ("C-o" . magit-dired-other-window)
	       )
  :init
  (setq-default magit-diff-refine-hunk t)
  ;; (defvar magit-last-seen-setup-instructions "1.4.0")
  :config
  (fullframe magit-status magit-mode-quit-window)
  )

(use-package vertico
  :bind
  (:map vertico-map
        ("C-j" . vertico-next)
        ("C-k" . vertico-previous))
  :init
  (vertico-mode)          ;; this call is placed in init instead of config section as per vertico documentation
  (setq vertico-scroll-margin 0) ;; Scroll margin
  ;; (setq vertico-count 10)        ;; Candidates
  (setq vertico-cycle t)        ;; Enable cycling when at top or bottom

  ;; :blackout (foo-mode . " Foo") ; results in (blackout 'foo-mode " Foo")xb

  )
(use-package savehist  ;; recommended by vertico author
  :init (savehist-mode))

;; *** configure `which-key'
;; setting prefix-help-command to my  preferred version based on reading at
;; https://with-emacs.com/posts/ui-hacks/prefix-command-completion/
(use-package which-key
  :after embark
  ;; :demand t
  :blackout t
  ;; :hook
  ;; (which-key-init-buffer . my--wk-help-dbg)
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  (which-key-mode 1))

;; *** `orderless' - a completion style using space-separated patters in any order
(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles . (partial-completion))))))

;; *** `consult'
(use-package consult
  :bind
  (([remap apropos-command] . consult-apropos)
   ([remap switch-to-buffer] . consult-buffer)
   ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
   ([remap yank-pop] . consult-yank-pop)
   :map project-prefix-map
   ("i" . consult-project-imenu)
   :map goto-map
   ("M-i" . consult-imenu)
   ("M-o" . consult-outline)
   ("M-e" . consult-flymake)
   ("M-l" . consult-line)
   :map help-map
   ("M" . consult-man)))

(comment (use-package consult  ;; source: https://www.omarpolo.com/dots/emacs.html
  :bind (("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ("M-g e" . consult-compile-error)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-project-imenu)
         ("M-s f" . op/consult-find)
         ("M-s g" . consult-grep)
         ("M-s l" . consult-line)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s e" . consult-isearch))
  :custom ((register-preview-delay 0)
           (register-preview-function #'consult-register-format)
           ;; use consult to select xref locations with preview
           (xref-show-xrefs-function #'consult-xref)
           (xref-show-definitions-function #'consult-xref)
           (consult-narrow-key "<")
           (consult-project-root #'project-roots)
           (consult-find-args "find .")
           (consult-grep-args "grep --null --line-buffered --ignore-case -RIn"))
  :init
  (advice-add #'register-preview :override #'consult-register-window)

  :config
  ;; make narrowing help available in the minibuffer.
  (define-key consult-narrow-map (vconcat consult-narrow-key "?")
              #'consult-narrow-help)

  ;; a find-builder that works with OpenBSD' find
  (defun op/consult--find-builder (input)
  "Build command line given INPUT."
  (pcase-let* ((cmd (split-string-and-unquote consult-find-args))
               (type (consult--find-regexp-type (car cmd)))
               (`(,arg . ,opts) (consult--command-split input))
               (`(,re . ,hl) (funcall consult--regexp-compiler arg type)))
    (when re
      (list :command
            (append cmd
                    (cdr (mapcan
                          (lambda (x)
                            `("-and" "-iname"
                              ,(format "*%s*" x)))
                          re))
                    opts)
            :highlight hl))))

  (defun op/consult-find (&optional dir)
    (interactive "P")
    (let* ((prompt-dir (consult--directory-prompt "Find" dir))
           (default-directory (cdr prompt-dir)))
      (find-file (consult--find (car prompt-dir) #'op/consult--find-builder ""))))))

;; *** `affe' : asynchronous fuzzy finder for emacs
(use-package affe
  :after orderless
  :custom ((affe-regexp-function #'orderless-pattern-compiler)
           (affe-highlight-function #'orderless-highlight-matches)))

;; *** `marginalia' enable richer annotations including richer annotation of
;; completion candidates
(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  :custom (marginalia-annotators
           '(marginalia-annotators-heavy marginalia-annotators-light nil))
  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

;; *** `embark' package for mini-buffer actions and right-click contextual menu functionality
;; Embark provides custom actions on the minibuffer (technically everywhere)
(use-package embark
  :demand t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :config
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
(comment  ;; bindings used by omarpolo
 (use-package embark
   :bind (("C-." . embark-act)
         :map minibuffer-local-completion-map
              ("M-t" . embark-act)
              ("M-h" . embark-become)
              :map minibuffer-local-map
              ("M-t" . embark-act)
              ("M-h" . embark-become)))
 )
(use-package embark-consult
  :after (embark consult))

(comment
 (look-at "shackle" package which is a rule-based manager for pop-up windows
	  https://depp.brause.cc/shackle/)
 )

;; *** `avy'
(use-package avy
  :bind
  (("C-z" . avy-goto-char-2)
  ;; alternate bindings
  ;; ("M-g c" . avy-goto-char)
  ;; ("M-g C" . avy-goto-char-2)
  ;; ("M-g w" . avy-goto-word-1)
  ;; ("M-g f" . avy-goto-line)
   :map isearch-mode-map
   ("C-'" . avy-isearch))
  :custom
    (avy-keys '(?a ?o ?e ?u ?h ?t ?n ?s)))

;; *** `undo-tree' is a more intuitive way to navigate undo instead of linear traversal
(use-package undo-tree
  :blackout t
  :bind (("C-x u" . undo-tree-visualize))
  :init (global-undo-tree-mode))

;; *** `expand-region' for selecting text objects
(use-package expand-region
  :bind (("C-=" . er/expand-region)))

;; *** `smartparens' handles paired punctuations The auhor recommends
;; initialization using (require 'smartparens-config), but we want to
;; do so using use-package. Found the solution 
;; [[https://www.wisdomandwonder.com/article/9897/use-package-smartparens-config-ensure-smartparens][here]]
(use-package smartparens
  :blackout t
  :bind (:map smartparens-mode-map
              ("C-M-f" . sp-forward-sexp)
              ("C-M-b" . sp-backward-sexp)

              ("C-M-a" . sp-beginning-of-sexp)
              ("C-M-e" . sp-end-of-sexp)
              ("C-M-n" . sp-next-sexp)
              ("C-M-p" . sp-previous-sexp)

              ("C-(" . sp-forward-barf-sexp)
              ("C-)" . sp-forward-slurp-sexp)
              ("C-{" . sp-backward-barf-sexp)
              ("C-}" . sp-backward-slurp-sexp)

              ("C-k" . sp-kill-hybrid-sexp)

              ("C-," . sp-rewrap-sexp)

              :map emacs-lisp-mode-map (";" . sp-comment)
	      :map lisp-mode-map (";" . sp-comment)
	      )
  :config
  (setq sp-show-pair-from-inside nil)
  (require 'smartparens-config)
  (smartparens-global-mode)
  (sp-with-modes 'org-mode
    (sp-local-pair "=" "=" :wrap "C-="))
  (bind-key [remap c-electric-backspace] #'sp-backward-delete-char
            smartparens-strict-mode-map)

  :hook ((prog-mode . turn-on-smartparens-strict-mode)
         (web-mode . op/sp-web-mode)
         (LaTeX-mode . turn-on-smartparens-strict-mode))
  :custom ((sp-highlight-pair-overlay nil))
  )

(use-package highlight-parentheses
  :blackout t
  :config (global-highlight-parentheses-mode))


;; *** `markdown-mode'
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :hook
  (markdown-mode . variable-pitch-mode))

;; *** EPA
(setq
 epa-armor t
 epa-file-name-regexp "\\.\\(gpg\\|asc\\)$"
 epg-pinentry-mode 'loopback	   ; use minibuffer reading passphrase
 epa-file-encrypt-to '("milind.b.kamble@gmail.com"))
(epa-file-name-regexp-update)

;; *** `s' the (long lost) emacs string manipulation library
(use-package s
  :commands (s-replace))

;; *** `org-mode' itself 
(use-package org
  ;; :mode ("\\.org\\'" . org-mode)
  ;; :diminish org-indent-mode
  :config
  (setq org-agenda-files "~/notes/agenda.org")
  (setq org-directory "~/notes")
  (require 'ox-html)
  (require 'ox-latex)
  (require 'ox-md)
  (require 'org-element)
  (setq org-startup-indented t
	org-adapt-indentation nil
	org-edit-src-content-indentation 0
	org-outline-path-complete-in-steps nil
	org-refile-use-outline-path 'full-file-path
	org-refile-allow-creating-parent-nodes 'confirm
	;; org-refile-targets `((nil . (:maxlevel . 3)
	;; 			  (org-agenda-files . (:maxlevel . 3))))
	org-ellipsis "⤵"   ;; alternate: " ▾"
	org-hide-emphasis-markers t
	org-log-into-drawer t
	org-directory org-directory
	org-default-notes-file (concat org-directory "/todo.org"))
  (org-babel-do-load-languages
   'org-babel-load-languages  ;; many more exist
   '((python . t)
     (emacs-lisp . t)
     (shell . t)
     (lisp . t)
     (gnuplot . t)
     (R . t)
     (C . t)))
  (setq org-src-window-setup 'current-window)
  (setq org-agenda-window-setup 'current-window)
  :hook
  ((org-mode . variable-pitch-mode)
   (org-mode . visual-line-mode)
   (org-mode . flyspell-mode)))

;; *** narrow-dwim
(defun mbk/narrow-or-widen-dwim (p)
  "Widen if the buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree or defun,
whichever applies first.  Narrowing to org-src-blocks actually
calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is already
narrowed.  With P being -, narrow to page instead of to defun.

Taken from endless parentheses."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning)
                           (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' isn't a real narrowing
         (cond ((ignore-errors (org-edit-src-code) t))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((eql p '-) (narrow-to-page))
        (t (narrow-to-defun))))

(define-key global-map (kbd "C-c w") #'mbk/narrow-or-widen-dwim)

;; *** unlock keepassxc DB from emacs using dbus
;; read file content into a string http://ergoemacs.org/emacs/elisp_read_file_content.html
(defun get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

;; Unlock the KeepassXC GUI-app
;; remotely without explicitly entering the password
;; Lot of learning and experimenting during development, but the
;; shortness of code is impressive.
;; Reading the safebox.gpg file auto decrypts it into plain text
;; (thanks to EPA). parson-parse converts json-structured
;; string into hierarchical alist, from which we extract the values of
;; password and security file. Finally the dbus API is used to execute
;; the method openDatabase on the keepass service
(defun unlock-keepass ()
  "unlock keepass app using dbus"
  (interactive)
  (require 'dbus)
  (let* ((strong-box (expand-file-name
		      "~/.gnupg/keepass/keepass_safebox.gpg"))
	 (kdbx (expand-file-name
		"~/.gnupg/keepass/khaazgee_milind_keepass.kdbx"))
	 (pwd-db (with-temp-buffer
		   (insert-file-contents strong-box)
		   (json-parse-buffer)))
	 (kdbx-sec (gethash "keepasssec" (gethash "mil" pwd-db)))
	 (pwd (gethash "keepasspwd" (gethash "mil" pwd-db))))
    (cl-assert pwd-db nil "Could not parse strong-box") ;; pwd-db should be non-nil
    (cl-assert pwd nil "Password was not found in strong-box")
    (cl-assert kdbx-sec nil "Keepass security filepath not found in strong-box")
    (dbus-call-method :session "org.keepassxc.KeePassXC.MainWindow"
		      "/keepassxc" "org.keepassxc.KeePassXC.MainWindow" "openDatabase"
		      kdbx pwd kdbx-sec)))

(use-package eshell-z
  :after eshell
  :custom
  (eshell-z-freq-dir-hash-table-file-name
   (concat eshell-directory-name "z-dir-table")))

;; `eshell' utilities
;; other eshell related packxages
;; eshell-autojump  the command j to list common directories and to jump to them.
;; `eshell-bookmark' a simple package integrating eshell with bookmark.el.
;; `eshell-fixedprompt' Minor mode to restrict eshell to use a single fixed prompt
;;     wherein the prev command output isremoved (or scrolled out of sightG)uu;
;; `eshell-outline' Enhanced outline-mode for Eshell
;; `eshell-syntaxhighlighting'
;; `eshell-up' navigating to a specific parent directory in eshell without typing ../.. etc
(use-package eshell
  ;; :bind (:map eshell-mode-map
  ;;             ([remap eshell-pcomplete] . helm-esh-pcomplete)
  ;;             ("M-r" . helm-eshell-history)
  ;;             ("M-s f" . helm-eshell-prompts-all))
  :custom
  (eshell-banner-message "")
  ;; (eshell-scroll-to-bottom-on-input t)
  (eshell-error-if-no-glob t)
  (eshell-hist-ignoredups t)
  (eshell-save-history-on-exit t)
  (eshell-prefer-lisp-functions nil)
  ;; addding history-references to input-functions enable the use of !foo:n
  ;; to insert the nth arg of last command beg with foo
  ;; or !?foo:n for last command containing foo
  (add-to-list 'eshell-expand-input-functions 'eshell-expand-history-references)
  ;; (eshell-destroy-buffer-when-process-dies t)
  ;; (eshell-highlight-prompt nil)

  :config
  (setenv "PAGER" "cat")
  (require 'eshell-z)
  )

;; Being able to narrow to the output of the command at point seems very useful
(defun mbk/eshell-narrow-to-output ()
  "Narrow to the output of the command at point."
  (interactive)
  (save-excursion
    (let* ((start (progn (eshell-previous-prompt 1)
                         (forward-line +1)
                         (point)))
           (end (progn (eshell-next-prompt 1)
                       (forward-line -1)
                       (point))))
      (narrow-to-region start end))))
(defun mbk/eshell-select-from-history ()
  (interactive)
  (let ((item (completing-read "Select from history: "
                               (seq-uniq (ring-elements eshell-history-ring)))))
    (when item
      ;; from eshell-previous-matching-input
      (delete-region eshell-last-output-end (point))
      (insert-and-inherit item))))
(defun mbk/setup-eshell ()
  (define-key eshell-mode-map (kbd "C-c M-l") #'mbk/eshell-narrow-to-output)
  (message "before binding M-r")
  (define-key eshell-mode-map (kbd "M-r") #'mbk/eshell-select-from-history))

;; *** literate calc-mode. Do math in line.
;; (add-hook 'eshell-mode-hook
;; 	   (lambda ()
;; 	     (local-set-key (kbd "C-c h")
;; 			    (lambda ()
;; 			      (interactive)
;;	 		      (insert
;; 			       (ido-completing-read "Eshell history: " ;; there must be something equivalent for consult or vertico
;; 						    (delete-dups
;; 						     (ring-elements eshell-history-ring))))))
;; 	     ))


;; ** TBD
;; dired
;; occur, loccur
;; hideshow
;; gemini mode -- related to blog authoring?
;; olivetti -- Olivetti mode "centers" the buffer, it's nice when writing text (gemini-mode, markdown-mode etc.)
;; my-abbrev is a package-like file to store our custom abbreviations
;; eglot
;; as per OmarPolo : There are two major implementations for emacs: lsp-mode and eglot. lsp-mode is too noisy for me, I prefer eglot as it's less intrusive
;; Emacs-lisp doesn't have namespaces, so usually there's this convention of prefixing every symbol of a package with the package name. Nameless helps with this. It binds _ to insert the name of the package, and it visually replace it with :. It's pretty cool.
;; lua-lsp is the LSP server for lua, to hook it into eglot :
;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs
;;                '((lua-mode) . ("lua-lsp"))))
;; nov is a package to read epub from Emacs. It's really cool, and integrates with both bookmarks and org-mode
;; pq is a postgres library module for elisp.

;; *** `view mode'. Sometimes it's handy to make a buffer read-only. Also, define some key to easily navigate in read-only buffers.
(use-package view
  :bind (("C-x C-q" . view-mode)
         :map view-mode-map
         ("n" . next-line)
         ("p" . previous-line)
         ("l" . recenter-top-bottom)))

;; *** `geiser' 
(use-package geiser
  :config
  ;; (setq geiser-guile-binary "guile3.0")  ;; needed?
  ;; workaround for guix
  (defun geiser-company--setup (x) nil)
  (setq geiser-repl-company-p nil)
  )
;; *** `eglot'    ;; see https://github.com/joaotavora/eglot#how-does-eglot-work
(use-package eglot ;; from https://github.com/clojure8/emacs0/tree/main/modules/lang
  :commands (eglot)
  :bind
  (:map eglot-mode-map
        ("s-<return>" . eglot-code-actions)
        )
  :config
  (setq eglot-connect-timeout 10)
  (setq eglot-sync-connect t)
  (setq eglot-autoshutdown t)
  )
;; *** `consult-eglot'   ;; https://github.com/mohkale/consult-eglot
(use-package consult-eglot
  :after eglot
  :commands (consult-eglot)
  )
(use-package consult-eglot
  :after eglot)

;; *** `yaml'
(use-package yaml-mode
  :mode "\\.yml\\'"
  :hook ((yaml-mode . turn-off-flyspell)))

;; *** `text-mode'
(use-package text-mode
  :hook ((text-mode . visual-line-mode)
	 (text-mode . flyspell-mode)
	 (text-mode . abbrev-mode)
	 (text-mode . variable-pitch-mode)))

;; ** my customization
;; *** UX
(use-package poet-theme
  :init
  (add-hook 'mbk/after-load-theme-hook #'mbk/customize-poet)  ; need to add-hook before loading thee
  (load-theme 'poet t)    ; see `custom-available-themes' for optional themes
)


(when (file-exists-p custom-file) (load custom-file))
(require 'utils)
