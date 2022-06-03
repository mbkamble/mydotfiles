(use-modules (gnu) (nongnu packages linux))
(use-service-modules
 cups
 desktop
 networking
 ssh
 xorg)
(use-package-modules shells) ;; tmux gnupg python fonts graphviz wget binutils image-viewers)

(define %xorg-libinput-config
  "Section \"InputClass\"
  Identifier \"Touchpads\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsTouchpad \"on\"

  Option \"Tapping\" \"on\"
  Option \"TappingDrag\" \"on\"
  Option \"DisableWhileTyping\" \"on\"
  Option \"MiddleEmulation\" \"on\"
  Option \"ScrollMethod\" \"twofinger\"
EndSection
Section \"InputClass\"
  Identifier \"Keyboards\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsKeyboard \"on\"
EndSection
")

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/Chicago")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "kamble9343guix")
 
 (users (cons* (user-account
		(name "mbkamble")
		(comment "Milind Kamble")
		(group "users")
		(home-directory "/home/mbkamble")
		(shell (file-append fish "/bin/fish"))
		(supplementary-groups
		 '("wheel" "netdev" "audio" "video" "lp")))
	       (user-account
		(name "tester1")
		(comment "Tester Kamble")
		(group "users")
		(home-directory "/home/tester1")
		;; (shell (file-append fish "/bin/fish"))
		(supplementary-groups
		 '("wheel" "netdev" "audio" "video" "lp")))
	       %base-user-accounts))
 
 (packages
  (append
   (list
    ;; emacs
    (specification->package "emacs")
    (specification->package "emacs-exwm")
    (specification->package "emacs-desktop-environment")
    ;; system tools
    (specification->package "nss-certs")
    (specification->package "nss-certs")
    (specification->package "glibc-locales")
    ;; Xorg
    (specification->package "libinput")
    )
   %base-packages))
 
 (services
  (append
   (list (service gnome-desktop-service-type)
	 (service openssh-service-type)
	 (service cups-service-type)
	 (set-xorg-configuration
	  (xorg-configuration
	   (keyboard-layout keyboard-layout)
	   (extra-config (list %xorg-libinput-config)))))
   %desktop-services))

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets (list "/boot/efi"))
   (keyboard-layout keyboard-layout)))

 (swap-devices
  (list (swap-space
	 (target
	  (uuid "db35b3c6-8f65-41a9-91af-e8c0bdb28fad")))))

 (mapped-devices
  (list (mapped-device
	 (source
	  (uuid "52820bd7-9b0a-419c-a744-357943b252c2"))
	 (target "home")
	 (type luks-device-mapping))
	(mapped-device
	 (source
	  (uuid "6ec1485e-0424-406e-848f-9f2334159da8"))
	 (target "guixroot")
	 (type luks-device-mapping))))

 (file-systems
  (cons* (file-system
	  (mount-point "/home")
	  (device "/dev/mapper/home")
	  (type "ext4")
	  (dependencies mapped-devices))
	 (file-system
	  (mount-point "/")
	  (device "/dev/mapper/guixroot")
	  (type "ext4")
	  (dependencies mapped-devices))
	 (file-system
	  (mount-point "/boot/efi")
	  (device (uuid "24D8-3A48" 'fat32))
	  (type "vfat"))
	 %base-file-systems))

 )
