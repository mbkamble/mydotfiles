if status --is-interactive
    # based on example code in documentation/commands.html
    set -g fish_user_abbreviations
    # abbr -a lsfl
    abbr -a gop 'gio open'
    abbr -a area52nasdoc 'sudo mount -t cifs //192.168.7.10/Documents -o vers=3.0,username=mbkamble,domain=WORKGROUP,uid=1000,gid=1000 ~/area52nas_shares/Documents'
    abbr -a aaaa "kbsetup built"
    abbr -a adad "kbsetup rk61"
    abbr -a agag "kbsetup Inatek"
    abbr -a ahah "kbsetup sculpt"
    abbr -a asas "kbsetup k7"
    abbr -a bbbb "kbsetup resetbuiltin"
    abbr -a batt "upower -i (upower -e|grep battery) | grep -P 'percentage|time|state'"
    abbr -a cathtml "links -dump"
    abbr -a cs "xdg-open ^ /dev/null"
    abbr -a deltrash "gio trash --empty"
    abbr -a ec 'emacsclient -nc'
    abbr -a ee 'emacsclient -e'
    abbr -a en 'emacsclient -n'
    abbr -a ggp "git grep -Pi"
    abbr -a listtrash "gio list trash://"
    abbr -a llt 'ls -ltrh'
    abbr -a lsremov "gio_drives_info . uuid"
    abbr -a ns "command nmcli con show --active"
    abbr -a pf 'printf "%s\n"'
    abbr -a simple-scan 'sscan'
    abbr -a vdah "nmcli con down id AstuteHook-2G"
    abbr -a vdah5 "nmcli con down id AstuteHook-5G"
    abbr -a vdbm "nmcli con down id blurrymedian_5G"
    abbr -a vdeast "nmcli con down id PIAEast"
    abbr -a vdin "nmcli con down id piaindia"
    abbr -a vdk3 "nmcli con down id kamble3"
    abbr -a vdk3g "nmcli con down id kamble3_5G"
    abbr -a vdph "nmcli con down id gargoylearea55phoot"
    abbr -a vdsr "nmcli con down id SARC"
    abbr -a vdtx "nmcli con down id PIATX"
    abbr -a vdmtk "nmcli con down id MTKAP2"
    abbr -a vuah "nmcli con up id AstuteHook-2G"
    abbr -a vuah5 "nmcli con up id AstuteHook-5G"
    abbr -a vubm "nmcli con up id blurrymedian_5G"
    abbr -a vueast "nmcli con up id PIAEast"
    abbr -a vuin "nmcli con up id piaindia"
    abbr -a vuk3 "nmcli con up id kamble3"
    abbr -a vuk3g "nmcli con up id kamble3_5G"
    abbr -a vuph "nmcli con up id gargoylearea55phoot"
    abbr -a vusr "nmcli con up id SARC"
    abbr -a vutx "nmcli con up id PIATX"
    abbr -a vumtk "nmcli con up id MTKAP2"
    abbr -a picoR64 "picocom -b 115200"
    abbr -a dugui "baobab"
    abbr -a whowns "eopkg sf"
    abbr -a bill16 "~/docs/Bills_Reciepts_Rebates/2016/"
    abbr -a bill17 "~/docs/Bills_Reciepts_Rebates/2017/"
    abbr -a bill18 "~/docs/Bills_Reciepts_Rebates/2018/"
    abbr -a bill19 "~/docs/Bills_Reciepts_Rebates/2019/"
    abbr -a bill20 "~/docs/Bills_Reciepts_Rebates/2020/"
    for i in (seq 1 30) ; abbr -a c$i "echo $i | cdh"; end

end
