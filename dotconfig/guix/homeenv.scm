;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
  (gnu home)
  (gnu packages)
  (gnu services)
  (guix gexp)
  (gnu packages shells)
  (gnu home services shells))

(home-environment
  (packages
    (map (compose list specification->package+output)
         (list
	  "gnupg@2"
	  "pinentry"
          "file"
	  "fish"

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
              (bashrc
                (list (local-file "/home/mbkamble/.bashrc" "bashrc")))
              (bash-profile
                (list (local-file
                        "/home/mbkamble/.bash_profile"
                        "bash_profile")))))
	  (service
            home-fish-service-type
            (home-fish-configuration
              (abbreviations
               '(("llt" . "exa -lahtr")
		 ;; ("pphtml" . "html2text -style pretty -width 350 -ascii") ;; alternative to links
		 ("pphtml" . "links -dump") ;; pretty-print to text format
		 ;; ("asciidoctor" . "source ~/.rvm/scripts/rvm; and asciidoctor")
		 ("sscan" . "simple-scan") ;; we might have to XDG_CURRENT_DESKTOP=XFCE simple-scan if Ctrl-1 etc keyboard shortcuts dont work
		 ("catpdf" . "pdftotext -fixed 3 -enc ASCII7")))
              (environment-variables
	       '(("SSH_AUTH_SOCK" . "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh")
		 ;; ("GUIX_EXTRA_PROFILES" . "$HOME/.guix-extra-profiles")
		 ))
              (aliases
               '(("rmi" . "rm -i")))
	      ; text-config is List of file-like objects (see Info->Guix->G-expr), which will be added to config.fish
	      (config
	       `(,(plain-file "my-plain-custom.fish"
			      "set -x MBK1 hello
if true; and set -x MBK1; end")
		 ,(mixed-text-file "my-mixed-custom.fish"
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
end\n")))
	       )))
	  )))


;; developer notes
;; declaratively specifying the home-fish-configuration was a steep learning curve especially to figure out how to customize the content of .config/fish/config.fish file. This was achieved by specing the "config" field of the home-fish-configuration record constructor. In doing so, we experimented to see how "plain-file" and "mixed-text-file" constructs could be used. For setting GUIX_PROFILE. it is important to set it in global scope and exporting it so that sourcing the etc/profile works correctly such that canonical names "profile-name/{bin|share}" etc are used instead of "/gnu/store/...profile/{bin|share}".
;; Also, the semantics of file-like objects created by "plain-file" and "mixed-text-file" is that Guix crated files named blah1-my-plain-custom.fish and blah2-my-mixed-custom.fish are created in the store and that content is also included in config.fish
