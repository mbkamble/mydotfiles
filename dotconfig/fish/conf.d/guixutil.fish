function activate_guix_profiles
   set --prepend fish_function_path $HOME/.guix-home/share/fish/functions
   for i in $GUIX_EXTRA_PROFILES/*
      set -x GUIX_PROFILE $i/(basename $i)
      fenv source $GUIX_PROFILE/etc/profile
      set -e GUIX_PROFILE
   end
end
