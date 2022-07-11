# if we haven't sourced the login config, do it
status --is-login; and not set -q __fish_login_config_sourced
and begin
  set --prepend fish_function_path $HOME/.guix-home/profile/share/fish/functions
  fenv source $HOME/.profile
  set -e fish_function_path[1]
  set -g __fish_login_config_sourced 1
end

set -xg NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -xg SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
set -xg GUILE_WARN_DEPRECATED detailed
set -xg GUILE_AUTO_COMPILE 0
set -xg NPM_PACKAGES $HOME/.npm-packages

set -x PATH $PATH $NPM_PACKAGES/bin
set -x MANPATH $NPM_PACKAGES/share/man $MANPATH
alias rmi "rm -i"
abbr --add -g llt exa -lah -snew
abbr --add -g pphtml links -dump
abbr --add -g sscan simple-scan
abbr --add -g allinstalledpkgs ls -1d /run/current-system/profile  $GUIX_EXTRA_PROFILES/*/* ~/.guix-home/profile ~/.config/guix/current|grep -Pv 'link|lock'|xargs -izzz guix package -p zzz -I . 
abbr --add -g catpdf pdftotext -fixed 3 -enc ASCII7
