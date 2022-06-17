(define-module (cli-packages))

(define-public my-cli-packages
 '(
   "git" "mercurial"   
   "fish-foreign-env"
   "perl-image-exiftool"
   "file"
   "ispell"
   "efibootmgr"
   "strace"
   "dmidecode"
   "lshw"
   "lsof" "lsofgraph"
   "rsync"
   "ncurses"
   "binutils"
   "man-db"              ; needed for man pages (see https://guix.gnu.org/cookbook/en/guix-cookbook.html
   "info-reader"         ; needed for info pages
   "pkg-config"
   "exa"                 ; replacement for ls
   "grep"
   "ncurses"             ; needed for tput
   "which"
   "fd"                  ; a replacement for find (~80% of use cases)
   "xdg-utils"           ; provides xdg-open,settings,email,mime etc.
   ))
   

