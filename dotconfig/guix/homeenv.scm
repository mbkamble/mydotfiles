;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
 (ice-9 format)
 (ice-9 getopt-long)
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
	  "less"

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
     (service home-shell-mbk-profile-service-type)
     ;; (service
;;            home-bash-service-type
;;            (home-bash-configuration
;;             (aliases
;;              '(("ns" . "nmcli con show --active")))
	    
;; 	    ;; copies respective files from home dir to file <blah>-bashrc and <blah>-bash_profile in store
;;             ;; (bashrc
;;             ;;  (list (local-file "/home/mbkamble/.bashrc" "bashrc")))
;;             ;; (bash-profile
;; ;;              `(,(plain-file "my-bash-profile"
;; ;; 			    "\n\
;; ;; export GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
;; ;; for i in $GUIX_EXTRA_PROFILES/*; do
;; ;;   profile=$i/$(basename $i)
;; ;;   if [ -f $profile/etc/profile ]; then
;; ;;     GUIX_PROFILE=$profile
;; ;;     . $GUIX_PROFILE/etc/profile
;; ;;   fi
;; ;;   unset profile
;; ;; done\n")))
;; 	    ))
	  (service
	   home-gnupg-service-type
	   (home-gnupg-configuration
	    (gpg-config
	     (home-gpg-configuration
	      (extra-config
	       '((default-key . "9F711C92")
		 (cipher-algo . "AES256")
		 (expert? . #t)
		 (with-fingerprint? . #t)
		 (list-options . "show-keyring")
		 (with-keygrip? . #t)
		 (keyid-format . "0xlong")
		 (utf8-strings? . #t)
		 (keyserver . "hkp://keys.gnupg.net")
		 ))))
	    (gpg-agent-config
	     (home-gpg-agent-configuration
	      (ssh-agent? #t)
	      (ssh-keys
	       '(("6A9063863762271CCD05409B60FA08E46730BDA4")
		 ("CA067DC323D613B859EC0DD8049BA9A2E68B84A6")))
	      (pinentry-flavor 'rofi)
	      (extra-config
	       `((max-cache-ttl . 214748364)
		 (default-cache-ttl . 214748364)
		 (max-cache-ttl-ssh . 214748364)
		 (default-cache-ttl-ssh . 214748364)
		 (allow-loopback-pinentry? . #t)
		 (allow-emacs-pinentry? . #t)
		 (log-file . ,(string-append (getenv "HOME") "/tmp/gpg-agent.log"))
		 (debug-level . 2)
		 ;; (debug . 1024)   ; debug and debug-pinentry are useful to debug agent-to-pinentry messages
		 ;; (debug-pinentry? . #t)
		 )))
	     ))) ;; should complete service instance of home-gnupg-service-type
	  (service
           home-fish-service-type
           (home-fish-configuration
            (abbreviations
             '(("llt" . "exa -lah -snew")
	       ;; ("pphtml" . "html2text -style pretty -width 350 -ascii") ;; alternative to links
	       ("pphtml" . "links -dump") ;; pretty-print to text format
	       ;; ("asciidoctor" . "source ~/.rvm/scripts/rvm; and asciidoctor")
	       ("sscan" . "simple-scan") ;; we might have to XDG_CURRENT_DESKTOP=XFCE simple-scan if Ctrl-1 etc keyboard shortcuts dont work
	       ("allinstalledpkgs" . "ls -1d /run/current-system/profile  $GUIX_EXTRA_PROFILES/*/* ~/.guix-home/profile ~/.config/guix/current|grep -Pv 'link|lock'|xargs -izzz guix package -p zzz -I . ")	 
	       ("catpdf" . "pdftotext -fixed 3 -enc ASCII7")))
	    ;; there is a bug in guix distribution gnu/home/services/shells.scm in which env variables are being created using "set VAR VALUE" instead of "set -x VAR VALUE". So we had to move some var settings from "environment-variables" to "config"
            (environment-variables
	     '(
               ;; ("SSH_AUTH_SOCK" . "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh") ; resetting this because even though it is setup correctly in setup-environment, it seems to get reset to $XDG_RUNTIME_DIR/keyring/ssh
	       ;; ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
	       ;; ("GUILE_WARN_DEPRECATED" . "detailed")
	       ;; ("GUILE_AUTO_COMPILE" . "0")
	       ;; ("NPM_CONFIG_USERCONFIG" . "$XDG_CONFIG_HOME/npm/npmrc")
	       ;; https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md
               ;; npm config set prefix "${HOME}/.npm-packages"
               ;; ("NPM_PACKAGES" . "$HOME/.npm-packages")
               ("PATH" . "$PATH $NPM_PACKAGES/bin")
               ("MANPATH" . "$NPM_PACKAGES/share/man $MANPATH")
	       ))
            (aliases
             '(("rmi" . "rm -i")))
	    ;; text-config is List of file-like objects (see Info->Guix->G-expr), which will be added to config.fish
	    (config
	     ;; see older versions of this file for an example using `plain-file'
	     `(,(mixed-text-file "my-mixed-custom.fish"
				 #~(string-append "\
;; # activate all the profiles created in $GUIX_EXTRA_PROFILES
;; status --is-login; and not set -q __fish_guix_extra_profiles_sourced
;; and begin
;;   set -xg GUIX_EXTRA_PROFILES $HOME/.guix-extra-profiles
;;   set --prepend fish_function_path " #$fish-foreign-env "/share/fish/functions
;;   for i in $GUIX_EXTRA_PROFILES/*
;;     set -xg GUIX_PROFILE $i/(basename $i)
;;     #echo GUIX_PROFILE=$GUIX_PROFILE
;;     fenv source $GUIX_PROFILE/etc/profile
;;     set -eg GUIX_PROFILE
;;   end
;;   #set -S PATH
;;   set -e fish_function_path[1]
;;   set -g __fish_guix_extra_profiles_sourced 1
;; end
set -xg NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -xg SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
set -xg GUILE_WARN_DEPRECATED detailed
set -xg GUILE_AUTO_COMPILE 0
set -xg NPM_PACKAGES $HOME/.npm-packages\n")))  ;; 
	     )))
	  ;; endservice home-fish-service-type

	  ;; this creates a files blah-utils.el in the store (/gnu/store) and makes a soft link to it
	  ;; in ~/.emacs.d/lisp as well as ~/.guix-home/files/.emacs.d/lisp
	  (simple-service 'my-elisp
			  home-files-service-type
			  `((".emacs.d/lisp/utils.el"
			     ,(local-file "../../dotemacsdotd/lisp/utils.el"))
			    (".config/npm/npmrc"
			     ,(local-file "../npm/npmrc"))
			    ;; (".profile" ,(local-file "../homedotprofile")) ;; does not work. throws an exception: duplicate entry for files -- .profile
			    ))
	  (simple-service 'some-useful-env-vars-service
			  home-environment-variables-service-type
			  '(("MBK_FOR_SHEPHERD" . "this_works:visible")))
	  (service
	   home-emacs-service-type
	   (home-emacs-configuration
	    (package emacs)
	    (rebuild-elisp-packages? #t)
	    (elisp-packages
	     (map specification->package my-emacs-packages))
	    (xdg-flavor? #f)
	    (server-mode?  #t)
	    ;; the following create symlinks in $HOME/.emacs.d and in $HOME/.guix-home/files/.emacs.d
	    (init-el `(,(slurp-file-gexp (local-file "../../dotemacsdotd/init.el"))))
	    (early-init-el `(,(slurp-file-gexp (local-file "../../dotemacsdotd/early-init.el"))))
	    ))            ;; endservice home-emacs-service-type

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
