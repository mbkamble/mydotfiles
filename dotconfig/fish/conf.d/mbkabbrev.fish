if status --is-interactive
    # based on example code in documentation/commands.html
    set -g fish_user_abbreviations
    # abbr -ga lsfl
    abbr -ga mcsleep 'sudo bash -c "echo mem > /sys/power/state"'
    abbr -ga sfldvl 'gio open ~/Pictures/sofle_dvorak_layer.png'
    abbr -ga sfllrl 'gio open ~/Pictures/sofle_lower_layer.png'
    abbr -ga sflrsl 'gio open ~/Pictures/sofle_raise_layer.png'
    abbr -ga sflmml 'gio open ~/Pictures/sofle_mmedia_layer.png'
    abbr -ga pia 'wget --quiet https://www.privateinternetaccess.com/ -O -|pandoc -f html -t plain|grep -iP "you are .*protect"'
    abbr -ga slideshow 'eog -s'  # eye-of-gnome slideshow viewer
    abbr -ga slides 'eog -s'  # eye-of-gnome slideshow viewer
    abbr -ga qb 'flatpak run org.qutebrowser.qutebrowser &'
    abbr -ga gop 'gio open'
    abbr -ga area52nasdoc 'sudo mount -t cifs //192.168.7.10/Documents -o vers=3.0,username=mbkamble,domain=WORKGROUP,uid=1000,gid=1000 ~/area52nas_shares/Documents'
    abbr -ga aaaa "setxkbmap -device (xinput list|sed -En '/AT Trans.+keyboard/ {s/.+id=([0-9]+)\s.+/\1/p}') -layout us -variant dvorak -option 'ctrl:nocaps'"
    abbr -ga bbbb "setxkbmap -device (xinput list|sed -En '/AT Trans.+keyboard/ {s/.+id=([0-9]+)\s.+/\1/p}') -layout us -option ''"
    abbr -ga dybo "setxkbmap -device (xinput list|sed -En '/Sofle\s+id.+keyboard/ {s/.+id=([0-9]+)\s.+/\1/p}') -layout us -option ''"
    abbr -ga adad "kbsetup rk61"
    abbr -ga agag "kbsetup Inatek"
    abbr -ga ahah "kbsetup sculpt"
    abbr -ga asas "kbsetup k7"
    abbr -ga batt 'upower -i (upower -e|grep battery) | perl -ane \'if (/state:/) {$state=$F[-1]}; if (/time to /) {$rem="$F[-2] $F[-1]"}; if (/percentage:/){$per=$F[-1]}; END{print "$state($per) time remaining:$rem\n"}\''
    abbr -ga cathtml "links -dump" # pretty-print to text format. alternative "html2text -style pretty -width 350 -ascii"
    abbr -ga catpdf 'pdftotext -fixed 3 -enc ASCII7'
    abbr -ga cs "xdg-open ^ /dev/null"
    abbr -ga rmi 'rm -i'
    abbr -ga asciidoctor "source ~/.rvm/scripts/rvm; and asciidoctor"
    abbr -ga deltrash "gio trash --empty"
    abbr -ga ec 'emacsclient -nc'
    abbr -ga ee 'emacsclient -e'
    abbr -ga en 'emacsclient -n'
    abbr -ga ggp "git grep -Pi"
    abbr -ga listtrash "gio list trash://"
    abbr -ga llt 'ls -ltrh' # future enhancement 'exa -lah -snew'
    abbr -ga lsremov "gio_drives_info . uuid"
    abbr -ga ns "command nmcli con show --active"
    abbr -ga pf 'printf "%s\n"'
    abbr -ga sscan simple-scan # might need to XDG_CURRENT_DESKTOP=XFCE simple-scan if Ctrl-1 etc keyboard shortcuts dont work
    abbr -ga allinstalledpkgs  'ls -1d /run/current-system/profile  $GUIX_EXTRA_PROFILES/*/* ~/.guix-home/profile ~/.config/guix/current|grep -Pv "link|lock"|xargs -izzz guix package -p zzz -I . '
    abbr -ga vdah "nmcli con down id AstuteHook-2G"
    abbr -ga vdah5 "nmcli con down id AstuteHook-5G"
    abbr -ga vdbm "nmcli con down id blurrymedian_5G"
    abbr -ga vdeast "nmcli con down id PIAEast"
    abbr -ga vdin "nmcli con down id piaindia"
    abbr -ga vdk3 "nmcli con down id kamble3"
    abbr -ga vdk3g "nmcli con down id kamble3_5G"
    abbr -ga vdph "nmcli con down id gargoylearea55phoot"
    abbr -ga vdsr "nmcli con down id SARC"
    abbr -ga vdtx "nmcli con down id PIATX"
    abbr -ga vdmtk "nmcli con down id MTKAP2"
    abbr -ga vuah "nmcli con up id AstuteHook-2G"
    abbr -ga vuah5 "nmcli con up id AstuteHook-5G"
    abbr -ga vubm "nmcli con up id blurrymedian_5G"
    abbr -ga vueast "nmcli con up id PIAEast"
    abbr -ga vuin "nmcli con up id piaindia"
    abbr -ga vuk3 "nmcli con up id kamble3"
    abbr -ga vuk3g "nmcli con up id kamble3_5G"
    abbr -ga vuph "nmcli con up id gargoylearea55phoot"
    abbr -ga vusr "nmcli con up id SARC"
    abbr -ga vutx "nmcli con up id PIATX"
    abbr -ga vumtk "nmcli con up id MTKAP2"
    abbr -ga picoR64 "picocom -b 115200"
    abbr -ga dugui "baobab"
    abbr -ga whowns "eopkg sf"
    abbr -ga bill16 "~/docs/Bills_Reciepts_Rebates/2016/"
    abbr -ga bill17 "~/docs/Bills_Reciepts_Rebates/2017/"
    abbr -ga bill18 "~/docs/Bills_Reciepts_Rebates/2018/"
    abbr -ga bill19 "~/docs/Bills_Reciepts_Rebates/2019/"
    abbr -ga bill20 "~/docs/Bills_Reciepts_Rebates/2020/"
    for i in (seq 1 30) ; abbr -ga c$i "echo $i | cdh"; end
    abbr -ga kccomm "echo Comma is on Dvrk-bottomrow-ring"
    abbr -ga kcqot "echo Quote is on Dvrk-bottomrow-pinky"
    abbr -ga kcdot "echo Comma is on Dvrk-bottomrow-middle"
    abbr -ga kcplus "echo Plus is on Lower-homerow-I"
    abbr -ga kcmins "echo Minus is on Lower-homerow-d"
    abbr -ga kcund "echo Underscore is on Lower-homerow-D or Lower-bottomrow-x"
    abbr -ga kccln "echo Colon is on Lower-bottomrow-dot or Lower-bottomrow-W"
    abbr -ga kcsemi "echo Semicolon is on Lower-bottomrow-w"
    abbr -ga kclbrc "echo Leftbrace is on Lower-homerow-n"
    abbr -ga kcrbrc "echo Rightbrace is on Lower-homerow-s"
    abbr -ga kclbrk "echo LeftBracket is on Lower-bottomrow-quote"
    abbr -ga kcrbrk "echo RightBracket is on Lower-bottomrow-comma"
    abbr -ga kcque "echo Question is on Lower-bottomrow-m or   Dvrk-bottomrow-rightextendedpinky-shift"
    abbr -ga kcsls "echo ForwardSlash is on Dvrk-bottomrow-rightextendedpinky"
    abbr -ga kcbsl "echo Backslash is on Lower-bottomrow-v"
    abbr -ga kcpip "echo Pipe is on Lower-bottomrow-z or Lower-bottomrow-V"
end
