;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
 (ice-9 format)
 (ice-9 getopt-long)
 (ice-9 textual-ports)
 (gnu home)
 (gnu packages)
 (gnu services)
 (guix gexp)
 (gnu packages shells)
 (gnu packages emacs)
 (gnu home services)
 (gnu home services shells) ;; using -L, we are overriding our version of this module to be taken instead of from guix installation
 (gnu home services mbk-shells)
 (gnu home-services-utils)
 (gnu home services emacs)
 (gnu home services gnupg)
 (gnu home services fontutils)
 ;; (guix scripts build)
 (srfi srfi-1)
;; (srfi srfi-37)
 (emacs-packages))

;;(format #t "~s~%" %load-path)
;; print the %load-path and %load-compiled-path for debug so that we know which paths are being used for module resolution
;; tried to use ice-9 getopts-long and srfi-37 args-fold, but args-fold was bigger bite than I can chew for now, and getopts-long throws exception if we don't specify all options (essentiallt redoing %standard-build-options)
;; args-fold is being used for cli argument parsing where in %standard-build-options is exported by guix scripts build
;; for now we are hacking a simple arg parser that just looks for --debug=level option and parses out the level value. If level > 2, we print the paths else remain silent
(define stderr (current-error-port))
(let* ((option-str-maybe (member "--debug" (command-line) string-prefix?))
       (option-value
	(if option-str-maybe 
	    (string->number (cadr (string-split (car option-str-maybe) #\=)))
	    0)
	))
  (when (> option-value 2)
    (display "%load-path=\n" stderr)    
    (map (lambda (x) (display x stderr ) (newline stderr)) %load-path)
    (display "%load-compiled-path=\n" stderr)
    (map (lambda (x) (display x stderr) (newline stderr)) %load-compiled-path)))

;; create a defualt home-environment so that we can get the list of defualt essential home services
;; (home-environment-default-essential-services tmo-he) returns that list. From it we dlete the home-shell-profile-service-type
;; so that the add-shell-profile-file form (gnu home servies shells) does not get executed. 
(define tmp-he
  (home-environment))

(display (local-file-absolute-file-name  (local-file "../../dotgpg/gpg-agent.conf")))(newline)  ;; (local-file ...) returns <local-file> record
(define mbk-gpg-agent-string (call-with-input-file (local-file-absolute-file-name (local-file "../../dotgpg/gpg-agent.conf"))(lambda (port) (get-string-all port)))) ;; providing full path works
(define mbk-gpg-string (call-with-input-file (local-file-absolute-file-name (local-file "../../dotgpg/gpg.conf")) (lambda (port) (get-string-all port))))
;(define mbk-gpg-agent-string (call-with-input-file "../../dotgpg/gpg-agent.conf" (lambda (port) (get-string-all port)))) ;; relative path name does not work. throws error : guix home: error: failed to load '/home/mbkamble/opensource/mydotfiles/dotconfig/guix/homeenv.scm': No such file or directory
;; (display "mbk-gpg-agent-string=\n")(display mbk-gpg-agent-string)(newline)

(define mbk-he
  (home-environment
   (packages
    (map (compose list specification->package+output)
	 (list
	  "gnupg@2"
	  "fish" 
	  "fish-foreign-env"
	  "git"
	  "font-victor-mono"
	  "font-adobe-source-sans-pro"
	  "font-google-material-design-icons"
	  "clang"   ;; for clang, clang++, clangd and other tools
	  "node"    ;; Node.js

	  ;; following are provided by %base-pacakges
	  ;; "less" "grep" "which"

	  ;; following are provided through system.scm
          ;; "glibc-locales"
	  )))
   ;; explicitly specify the essential-services we want by deleting the home-shell-profile-service-type.
   ;; We will add home-shell-mbk-profile-service-type in services field
   (essential-services
    (modify-services
     (home-environment-essential-services tmp-he)
     (delete home-shell-profile-service-type)))
   (services
    (list
     (simple-service 'all-my-init-files
		     ;; setup init files for all tools and apps
		     home-files-service-type
		     `(
		       (".profile"                         ,(local-file "../../dotprofile"))
		       (".guile"                            ,(local-file "../../dotguile"))
		       (".gitconfig"                     ,(local-file "../../dotgitconfig"))
		       (".hgrc"                           ,(local-file "../../dothgrc"))
		       (".tmux.conf"                   ,(local-file "../../dottmux.conf"))
		       (".config/fish/config.fish" ,(local-file "../fish/config.fish"))
                       ;; a(".config/fish/conf.d/abbrev.fish" ,(local-file "../fish/conf.d/mbkabbrev.fish"))
		       (".emacs.d/lisp/utils.el"    ,(local-file "../../dotemacsdotd/lisp/utils.el"))
		       (".config/npm/npmrc"      ,(local-file "../npm/npmrc"))
                       (".emacs.d/init.el"             ,(local-file "../../dotemacsdotd/init.el"))
                       (".emacs.d/early-init.el"             ,(local-file "../../dotemacsdotd/early-init.el"))
                       ;; (".gnupg/gpg-agent.conf" ,(local-file "../../dotgpg/gpg-agent.conf"))
                       ;; (".gnupg/gpg.conf"            ,(local-file "../../dotgpg/gpg.conf"))
		       ))
     (simple-service 'some-useful-env-vars
		     home-environment-variables-service-type
		     '(("MBK_FOR_SHEPHERD" . "this_works:visible")
		       ("GUILE_WARN_DEPRECATED" . "detailed")
                       ("SSH_AUTH_SOCK" . "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh") ; resetting this because even though it is setup correctly in setup-environment, it seems to get reset to $XDG_RUNTIME_DIR/keyring/ssh
		       ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
                       ;; https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md
                       ("NPM_CONFIG_USERCONFIG" . "$XDG_CONFIG_HOME/npm/npmrc") ;;  sets prefix
		       ("NPM_PACKAGES" . "$HOME/.npm-packages")
		       ("PATH" . "$PATH:$NPM_PACKAGES/bin")
		       ("MANPATH" . "$NPM_PACKAGES/share/man:$MANPATH")))
     ;; (service home-shell-mbk-profile-service-type)
     
     (service
      home-gnupg-service-type
      (home-gnupg-configuration
       (gpg-config
        (home-gpg-configuration
         (extra-content  mbk-gpg-string)
         ))
       (gpg-agent-config
        (home-gpg-agent-configuration
         (extra-content mbk-gpg-agent-string)
         ))))
     (service
      home-emacs-service-type
      (home-emacs-configuration
       (package emacs)
       (rebuild-elisp-packages? #t)
       (elisp-packages
	(map specification->package my-emacs-packages))
       (xdg-flavor? #f)
       (server-mode?  #t)))
     ))))


mbk-he ;; return the home-environment

;; developer notes
;; declaratively specifying the home-fish-configuration was a steep learning curve especially to figure out how to customize the content of .config/fish/config.fish file. This was achieved by specing the "config" field of the home-fish-configuration record constructor. In doing so, we experimented to see how "plain-file" and "mixed-text-file" constructs could be used. For setting GUIX_PROFILE. it is important to set it in global scope and exporting it so that sourcing the etc/profile works correctly such that canonical names "profile-name/{bin|share}" etc are used instead of "/gnu/store/...profile/{bin|share}".
;; Also, the semantics of file-like objects created by "plain-file" and "mixed-text-file" is that Guix crated files named blah1-my-plain-custom.fish and blah2-my-mixed-custom.fish are created in the store and that content is also included in config.fish
;; when emacs-service was tried for the first few iterations, it created synlinks in "$HOME/emacs.d/{init,early-init}.el instead of in $HOME/.emacs. The flaw was in rde/gnu/home-services/emacs.scm where get-emacs-configuration-files function was using the strings "emacs/" and "emacs.d/". The hack was to copy this file to <mydotfilesrepo>/dotconfig/guix/my-modules/gnu/home/services/emacs.scm, and fix the strings and reconfigure
;; value of a service is a configuration
;;(define mbkfoo
;;  (map (lambda (x) (service-kind x))  (home-environment-services mbk-he))) ;; enumerate all services defined in a home-environment
;;(define mbkfoo2
;;  (filter (lambda (x) (eq? (service-kind x) home-profile-service-type)) (home-environment-services mbk-he))) ;; select service of a particular type
;; command to reconfigure is: guix home reconfigure -L <mydotfiles-repo>/dotconfig/guix/my-modules <this-file>
