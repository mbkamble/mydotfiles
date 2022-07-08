;; %default-channels is exported by module (guix channels) and points to guix
;; channel rde is Adrew Tropins Reproducible Dev Env and provides =home-environment= and =operating-system= configuration

(cons*   ;; -- so long as we are not using %default-channels
 (channel
  (name 'nonguix)
  (url "https://gitlab.com/nonguix/nonguix")
  (branch "master")
  ;; (Commit
  ;;  "a95251a11f108b4d7f86a483841e3bf962ce9606")
  (introduction
   (make-channel-introduction
    "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
    (openpgp-fingerprint
     "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
 (channel
  (name 'flat)
  (url "https://github.com/flatwhatson/guix-channel.git")
  ;; (commit
  ;;         "657da22f0229b978b7bf4e4d476f59f17f6a175f")
  (introduction
   (make-channel-introduction
    "33f86a4b48205c0dc19d7c036c85393f0766f806"
    (openpgp-fingerprint
     "736A C00E 1254 378B A982  7AF6 9DBE 8265 81B6 4490"))))
;; (channel
;;  (name 'rde)
;;  (url "https://git.sr.ht/~abcdw/rde")
;;  ;; (commit
;;  ;;         "67c337acfa34eb4ee0a10e807b54a72a53f03f68")
;;  (introduction
;;   (make-channel-introduction
;;    "257cebd587b66e4d865b3537a9a88cccd7107c95"
;;    (openpgp-fingerprint
;;     "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))
 (channel
  (name 'emacs)
  (url "https://github.com/babariviere/guix-emacs")
  ;; (commit
  ;;         "6815af364c4652afc368d562f972ed87c083f76a")
  (introduction
   (make-channel-introduction
    "72ca4ef5b572fea10a4589c37264fa35d4564783"
    (openpgp-fingerprint
     "261C A284 3452 FB01 F6DF  6CF4 F9B7 864F 2AB4 6F18"))))
  %default-channels
 )

;; other channels to consider
;;;; (channel
;;   (name 'baba)
;;   (url "https://github.com/babariviere/dotfiles")
;;   (branch "guix")
;;   (introduction
;;    (make-channel-introduction
;;     "78e60924c559697195eddafb5dc7f47a86a12d6e"
;;     (openpgp-fingerprint
;;      "261C A284 3452 FB01 F6DF  6CF4 F9B7 864F 2AB4 6F18"))))
 
