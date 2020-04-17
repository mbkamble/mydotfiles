if test -x /usr/local/texlive/2019
   set PATH $PATH /usr/local/texlive/2019/bin/(uname -m)*
   set -xg MANPATH (manpath -g) /usr/local/texlive/2019/texmf-dist/doc/man
   set -xg INFOPATH "/usr/local/texlive/2019/texmf-dist/doc/info:"
end