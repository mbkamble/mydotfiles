(define-module (emacs-packages))

(define-public my-emacs-packages
 '(
   ;; "emacs"   ; the desired emacs-flavor needs to be incuded (see developer notes)
   "emacs-use-package"
   "emacs-exwm"
   "emacs-desktop-environment"
   "emacs-no-littering"
   "emacs-undo-tree"
   "emacs-all-the-icons"
   "emacs-vertico"
   "emacs-orderless"
   "emacs-consult"
   "emacs-marginalia"
   "emacs-embark"
   "emacs-avy"
   "emacs-default-text-scale"
   "emacs-ace-window"
   "emacs-visual-fill-column"
   "emacs-dired-single"
   ;; "emacs-dired-hacks"
   "emacs-all-the-icons-dired"
   "emacs-org"
   "emacs-org-superstar"
   "emacs-magit"
   "emacs-magit-todos"
   "emacs-git-gutter"
   "emacs-git-gutter-fringe"
   "emacs-projectile"
   "ripgrep" ;; For counsel-projectile-rg
   "emacs-lispy"
   "emacs-lispyville"
   "emacs-helpful"
   "emacs-geiser"
   "emacs-guix"
   "emacs-geiser-guile"
   "emacs-markdown-mode"
   "emacs-yaml-mode"
   "emacs-flycheck"
   "emacs-yasnippet"
   "emacs-yasnippet-snippets"
   "emacs-smartparens"
   "emacs-rainbow-delimiters"
   "emacs-rainbow-mode"
   "emacs-keycast"
   "emacs-eshell-z"
   "emacs-esh-autosuggest"
   "emacs-fish-completion"
   "emacs-eshell-syntax-highlighting"
   "emacs-eshell-toggle"
   "emacs-daemons"

   ;; stuff from other people
   ;; "emacs-embrace"
   ;; "emacs-lsp-mode"
   ;; "emacs-lsp-ui"
   ))
   

;; developer notes
;; install these packages in a dedicated profile using the command
;; guix pacakge -m path-to-this-file -p $GUIX_EXTRA_PROFILES/emacs/emacs
;; after first mkdir -p $GUIX_EXTRA_PROFILES/emacs
;; to upgrade all packages in this manifest, just rerun the above command again and Guix will create a new generation appropriately

;; emacs needs to be included if you are creating a emacs-oreinted profile using a manifest file
;; when done so, emacs binary is sym-linked from the <prfile>/bin and EMACSLOADPATH is set in the <profile>/etc/profile to include <profile>/share/emacs/site-lisp, which contains subdirs.el whose content is to inlcude the lisp source dirs of all the emacs packages installed through the manifest

;; however we have switched to using emacs as a service through home-environment configuration. There we specify the emacs flavor, which thus installs emacs package and also the emacs packages that we specify. So in that situation, the EMACSLOADPATH points to $HOME/.guix-home/share/emacs/site-llsp, ie the profile now is .guix-home instead of $GUIX_EXTRA_PROFILES/emacs/emacs
