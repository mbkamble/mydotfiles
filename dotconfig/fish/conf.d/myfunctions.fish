function asciidoctor
    bash -c "source ~/.rvm/scripts/rvm; \command \asciidoctor $argv"
end

function bean-query-help
    set helpmsg "get all transactions of a given account"
    set helpmsg $helpmsg "> bean-query $BCT 'select date,maxwidth(description, 50), account, position, balance where account ~ Macys; '"
    for msg in $helpmsg
        printf "%s\n" $msg
    end
end

function sscan
    # Deepin Graphical-UI sets XDG_CURRENT_DESKTOP to be 'Deepin'
    # Simplescan requires XDG_CURRENT_DESKTOP to be set to one of Unity, XFCE, MATE, LXDE, Cinnamon, X-Cinnamon or i3 for
    # keyboard shortcuts to work. So we override it here
    # See https://gitlab.gnome.org/GNOME/simple-scan/issues/14
    # mbk: I thought setting it to GNOME would be more compatible for Deepin and keyboard shortcuts would work. But they don't.
    #      keyboard shortcuts are working only with Unity, XFCE etc.
    set -x XDG_CURRENT_DESKTOP XFCE
    command simple-scan 2>&1 1>/dev/null &
end

function cathtml
#    html2text -style pretty -width 350 -ascii $argv
    links -dump $argv
end

function catpdf
    #pdftotext -layout -enc ASCII7 $argv -
    pdftotext -fixed 3 -enc ASCII7 $argv -
end

function gio_drives_info -a drive_num uuid_or_path
    # get detailed info using gio; filter lines of interest (Drive and uuid) and join them
    # into one line. Grep those lines for drive number provided in drive_num
    if test $uuid_or_path = "uuid"
        gio mount -l -i | sed -nr "/^Drive/{h}; /uuid:/{G; s/\s+uuid: //; s/\n/ /g; s/'//g; p}"|grep "Drive.$drive_num"
    else
        gio mount -l -i | sed -nr "/^Drive/{h}; /default_location/{G; s/\s+default_location=//; s/\n/ /g; p}"|grep "Drive.$drive_num"
    end
end

function mountflash
    set drv (gio_drives_info $argv uuid)
    # printf "drv=%s\n" $drv
    set uuid (string split -m1 " " $drv)
    # printf "uuid=%s\n" $uuid
    if string length $uuid[1] > 0
        # printf "%s\n" "gio mount -d $uuid[1]"
        gio mount -d $uuid[1]
    else
        printf "%s\n" "No drive matched for argument: $argv[1]"
    end
end

function unmountflash
    set drv (gio_drives_info $argv path)
    # printf "drv=%s\n" $drv
    set uuid (string split -m1 " " $drv)
    # printf "uuid=%s\n" $uuid
    if string length $uuid[1] > 0
        # printf "%s\n" "gio mount -u $uuid[1]"
        gio mount -u $uuid[1]
    else
        printf "%s\n" "No drive matched for argument: $argv[1]"
    end
end

function kbsetup
    # identify the keyboard id using xinput list; then reset the keyboard layout and finally set to desired layout with relevant options
    # the first setxkbmap -option "" resets the keyboard
    switch $argv[1]
        case sofle
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /Sofle\s+id.+keyboard/') ; and [ -n "$dev_id" ];
            and setxkbmap -device $dev_id -layout us -option ""
        case rk61
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /RK/') ; and [ -n "$dev_id" ];
            and setxkbmap -device $dev_id -layout us -option ""; and setxkbmap -device $dev_id -layout us -variant dvorak -option 'ctrl:nocaps'; and xmodmap ~/xmodmap.rk61
        case 'k7*'
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /Logitech K7/') ; and [ -n "dev_id" ];
            and setxkbmap -device $dev_id -layout us -option ""; and setxkbmap -device $dev_id -layout us -variant dvorak -option 'ctrl:nocaps,altwin:swap_lalt_lwin'
        case 'Ina*'
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /Inateck/') ; and [ -n "dev_id" ];
            and setxkbmap -device $dev_id -layout us -option ""; and setxkbmap -device $dev_id -layout us -variant dvorak -option 'ctrl:nocaps,altwin:swap_lalt_lwin'
        case 'scu*'
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print "$F[1]\n" if /Micro.+keybo/' | head -1) ; and [ -n "dev_id" ];
            and setxkbmap -device $dev_id -layout us -option ""; and setxkbmap -device $dev_id -layout us -variant dvorak -option 'ctrl:nocaps'
        case builtin 'b*'
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /AT Translated/') ; and [ -n "dev_id" ] ;
            and setxkbmap -device $dev_id -layout us -option ""; and setxkbmap -device $dev_id -layout us -variant dvorak -option 'ctrl:nocaps,altwin'
        case resetbuiltin
            set dev_id (xinput list | perl -F'/^.+id=|\s+/' -ne 'print $F[1] if /AT Translated/') ; and [ -n "dev_id" ] ;
            and setxkbmap -device $dev_id -layout us -option ""
    end
    set -e dev_id
end
