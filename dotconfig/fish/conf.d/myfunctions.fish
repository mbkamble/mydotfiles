function activate_guix_profiles
   set --prepend fish_function_path $GUIX_EXTRA_PROFILES/cli/cli/share/fish/functions
   for i in $GUIX_EXTRA_PROFILES/*
      set -x GUIX_PROFILE $i/(basename $i)
      fenv source $GUIX_PROFILE/etc/profile
      set -e GUIX_PROFILE
   end
end

function kbsetup
   echo kbsetup has been deprecated. see older version in mydotfiles repo to resurrect parts of it if needed
end
