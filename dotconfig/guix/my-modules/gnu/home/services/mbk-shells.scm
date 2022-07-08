;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2022 Milind Kamble <milindbkamble@gmail.com>

(define-module (gnu home services mbk-shells)
  #:use-module (gnu services configuration)
  #:use-module (gnu home-services-utils)
  #:use-module (gnu home services)
  #:use-module (gnu packages shells)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 match)

  #:replace (home-shell-mbk-profile-service-type
            home-shell-mbk-profile-configuration

	    home-fish-service-type
	    home-fish-configuration
	    home-fish-extension))

;;; Commentary:

;;; Code:


;;;
;;; Shell profile.
;;;
(define path? string?)
(define (serialize-path field-name val) val)

(define-configuration home-shell-mbk-profile-configuration
  (profile
   (text-config '())
   "\
@code{profile} is a list of file-like objects, which will go to
@file{~/.mbk-profile}."))

 (define (add-shell-profile-file config)
   `((".profile"
      ,(mixed-text-file
        "mbk-shell-profile"
        "\
 HOME_ENVIRONMENT=$HOME/.guix-home
 . $HOME_ENVIRONMENT/setup-environment
echo $(date) ::: pid sourcing home/.profile is $$ >> $HOME/tmp/startup_profile.log
echo $(date) ::: $(pstree -sp $$) >> $HOME/tmp/startup_profile.log

if [ ! -e $XDG_RUNTIME_DIR/guix-extra-profiles-sourced ]
   then
       export GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
       for i in $GUIX_EXTRA_PROFILES/*; do
	   profile=$i/$(basename $i)
	   if [ -f $profile/etc/profile ]; then
	       GUIX_PROFILE=$profile
	       . $GUIX_PROFILE/etc/profile
	   fi
	   unset profile
       done
       touch $XDG_RUNTIME_DIR/guix-extra-profiles-sourced
fi

 $HOME_ENVIRONMENT/on-first-login
echo $(date) ::: pid $$ finished running on-first-login >> $HOME/tmp/startup_profile.log
\n"
        (serialize-configuration
         config
         (filter-configuration-fields
          home-shell-mbk-profile-configuration-fields '(profile)))))))

(define home-shell-mbk-profile-service-type
  (service-type (name 'home-shell-mbk-profile)
                (extensions
                 (list (service-extension
                        home-files-service-type
                        add-shell-profile-file)))
                (default-value (home-shell-mbk-profile-configuration))
                (description "Create @file{~/.profile}, which is used
for environment initialization of POSIX compliant login shells.  This
service type can be extended with a list of file-like objects.")))

(define (generate-home-shell-mbk-profile-documentation)
  (generate-documentation
   `((home-shell-mbk-profile-configuration
      ,home-shell-mbk-profile-configuration-fields))
   'home-shell-mbk-profile-configuration))


;;;
;;; Fish.
;;;

(define (serialize-fish-aliases field-name val)
  #~(string-append
     #$@(map (match-lambda
               ((key . value)
                #~(string-append "alias " #$key " \"" #$value "\"\n"))
               (_ ""))
             val)))

(define (serialize-fish-abbreviations field-name val)
  #~(string-append
     #$@(map (match-lambda
               ((key . value)
                #~(string-append "abbr --add -g " #$key " " #$value "\n"))
               (_ ""))
             val)))

(define (serialize-fish-env-vars field-name val)
  #~(string-append
     #$@(map (match-lambda
               ((key . #f)
                "")
               ((key . #t)
                #~(string-append "set  -x " #$key "\n"))
               ((key . value)
                #~(string-append "set -x " #$key " "  #$value "\n")))
             val)))

(define-configuration home-fish-configuration
  (package
    (package fish)
    "The Fish package to use.")
  (config
   (text-config '())
   "List of file-like objects, which will be added to
@file{$XDG_CONFIG_HOME/fish/config.fish}.")
  (environment-variables
   (alist '())
   "Association list of environment variables to set in Fish."
   serialize-fish-env-vars)
  (aliases
   (alist '())
   "Association list of aliases for Fish, both the key and the value
should be a string.  An alias is just a simple function that wraps a
command, If you want something more akin to @dfn{aliases} in POSIX
shells, see the @code{abbreviations} field."
   serialize-fish-aliases)
  (abbreviations
   (alist '())
   "Association list of abbreviations for Fish.  These are words that,
when typed in the shell, will automatically expand to the full text."
   serialize-fish-abbreviations))

(define (fish-files-service config)
  `(("fish/config.fish"
     ,(mixed-text-file
       "fish-config.fish"
       #~(string-append "\
# if we haven't sourced the login config, do it
status --is-login; and not set -q __fish_login_config_sourced
and begin
  set --prepend fish_function_path "
                        #$fish-foreign-env
                        "/share/fish/functions
  fenv source $HOME/.profile
  set -e fish_function_path[1]
  set -g __fish_login_config_sourced 1
end\n\n")
       (serialize-configuration
        config
        home-fish-configuration-fields)))))

(define (fish-profile-service config)
  (list (home-fish-configuration-package config)))

(define-configuration/no-serialization home-fish-extension
  (config
   (text-config '())
   "List of file-like objects for extending the Fish initialization file.")
  (environment-variables
   (alist '())
   "Association list of environment variables to set.")
  (aliases
   (alist '())
   "Association list of Fish aliases.")
  (abbreviations
   (alist '())
   "Association list of Fish abbreviations."))

(define (home-fish-extensions original-config extension-configs)
  (home-fish-configuration
   (inherit original-config)
   (config
    (append (home-fish-configuration-config original-config)
            (append-map
             home-fish-extension-config extension-configs)))
   (environment-variables
    (append (home-fish-configuration-environment-variables original-config)
            (append-map
             home-fish-extension-environment-variables extension-configs)))
   (aliases
    (append (home-fish-configuration-aliases original-config)
            (append-map
             home-fish-extension-aliases extension-configs)))
   (abbreviations
    (append (home-fish-configuration-abbreviations original-config)
            (append-map
             home-fish-extension-abbreviations extension-configs)))))

;; TODO: Support for generating completion files
;; TODO: Support for installing plugins
(define home-fish-service-type
  (service-type (name 'home-fish)
                (extensions
                 (list (service-extension
                        home-xdg-configuration-files-service-type
                        fish-files-service)
                       (service-extension
                        home-profile-service-type
                        fish-profile-service)))
                (compose identity)
                (extend home-fish-extensions)
                (default-value (home-fish-configuration))
                (description "\
Install and configure Fish, the friendly interactive shell.")))
