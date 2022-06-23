;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
 (ice-9 format)
 (gnu home)
 (gnu packages)
 (gnu services)
 (guix gexp)
 (gnu packages shells)
 (gnu packages emacs)
 (gnu home services)
 (gnu home services shells)
 (my-home-services emacs)
 (gnu home-services gnupg)
 (gnu home-services-utils)
 (emacs-packages))

;;(display "hello world")
;;(format #t "~s~%" %load-path)
(map (lambda (x) (display x) (newline)) %load-path)

(home-environment
 (packages
  (map (compose list specification->package+output)
       (list
	"gnupg@2"
	"fish"
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
 (services
  (list (service
         home-bash-service-type
         (home-bash-configuration
          (aliases
           '(("grep" . "grep --color=auto")
             ("ll" . "ls -l")
             ("ls" . "ls -p --color=auto")))
	  
	  ;; copies respective files from home dir to file <blah>-bashrc and <blah>-bash_profile in store
          (bashrc
           (list (local-file "/home/mbkamble/.bashrc" "bashrc")))
          (bash-profile
           (list (local-file
                  "/home/mbkamble/.bash_profile"
                  "bash_profile")))))
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
          (environment-variables
	   '(("SSH_AUTH_SOCK" . "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh")
	     ;; ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
	     ("NPM_CONFIG_USERCONFIG" . "$XDG_CONFIG_HOME/npm/npmrc")
	     ;; https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md
             ;; npm config set prefix "${HOME}/.npm-packages"
             ("NPM_PACKAGES" . "$HOME/.npm-packages")
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
# activate all the profiles created in $GUIX_EXTRA_PROFILES
status --is-login; and not set -q __fish_guix_extra_profiles_sourced
and begin
  set -xg GUIX_EXTRA_PROFILES $HOME/.guix-extra-profiles
  set --prepend fish_function_path " #$fish-foreign-env "/share/fish/functions
  for i in $GUIX_EXTRA_PROFILES/*
    set -xg GUIX_PROFILE $i/(basename $i)
    #echo GUIX_PROFILE=$GUIX_PROFILE
    fenv source $GUIX_PROFILE/etc/profile
    set -eg GUIX_PROFILE
  end
  #set -S PATH
  set -e fish_function_path[1]
  set -g __fish_guix_extra_profiles_sourced 1
end
export NPM_CONFIG_USERCONFIG\n")))
	   )))       ;; endservice home-fish-service-type

	;; this creates a file blah-init.el in the store (/gnu/store) and makes a soft link to it
	;; in ~/.guix-home/files/config/emacs/foo-init.el
	(simple-service 'my-elisp
			home-files-service-type
			`((".emacs.d/lisp/utils.el"
			   ,(local-file "../../dotemacsdotd/lisp/utils.el"))
			  (".config/npm/npmrc"
			   ,(local-file "../npm/npmrc"))
			  ))
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

	)))


;; developer notes
;; declaratively specifying the home-fish-configuration was a steep learning curve especially to figure out how to customize the content of .config/fish/config.fish file. This was achieved by specing the "config" field of the home-fish-configuration record constructor. In doing so, we experimented to see how "plain-file" and "mixed-text-file" constructs could be used. For setting GUIX_PROFILE. it is important to set it in global scope and exporting it so that sourcing the etc/profile works correctly such that canonical names "profile-name/{bin|share}" etc are used instead of "/gnu/store/...profile/{bin|share}".
;; Also, the semantics of file-like objects created by "plain-file" and "mixed-text-file" is that Guix crated files named blah1-my-plain-custom.fish and blah2-my-mixed-custom.fish are created in the store and that content is also included in config.fish
;; when emacs-service was tried for the first few iterations, it created synlinks in "$HOME/emacs.d/{init,early-init}.el instead of in $HOME/.emacs. The flaw was in rde/gnu/home-services/emacs.scm where get-emacs-configuration-files function was using the strings "emacs/" and "emacs.d/". The hack was to copy this file to <mydotfilesrepo>/dotconfig/guix/my-modules/my-home-services/emacs.scm, update the module definition to match the new path, update the use-modules in homeenv.scmw fix the strings and reconfigure

;; command to reconfigure is: guix home reconfigure -L <mydotfiles-repo>/dotconfig/guix/my-modules <this-file>
