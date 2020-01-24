;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Magnus Bergmark"
      user-mail-address "magnus.bergmark@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/Org/")

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

(setq
 projectile-project-search-path '("~/Projects")
 )

(map!
 :niv "C-s" 'save-buffer
 :n "C-h" 'evil-window-left
 :n "C-j" 'evil-window-down
 :n "C-k" 'evil-window-up
 :n "C-l" 'evil-window-right
 :n "L" 'centaur-tabs-forward
 :n "H" 'centaur-tabs-backward
 )

                                        ; Make C-k work in search results, command output, etc. too
(map!
 :map 'grep-mode-map
 :n "C-k" 'evil-window-up
 :n "C-j" 'evil-window-down
 )

(map!
 :map 'company-active-map
 :n "C-k" 'evil-window-up
 :n "C-j" 'evil-window-down
 )

                                        ; C-k and C-j shadows useful bindings from time machine.
(map!
 :map 'git-timemachine-mode-map
 :n "J" 'git-timemachine-show-next-revision
 :n "K" 'git-timemachine-show-previous-revision
 )

                                        ; Tabs should be grouped by project, but by file type
(setq centaur-tabs-buffer-groups-function 'centaur-tabs-projectile-buffer-groups)

(add-hook 'enh-ruby-mode-hook
          (lambda()
            (setq-local flycheck-command-wrapper-function
                        (lambda (command)
                          (append '("bundle" "exec") command)))))


; ws-butler doesn't seem to work too well. Anyway, I'm fine with being the
; "whitespace police" and just fix all lines in a file. If it gets noisy, I'll
; commit the whitespace changes in a separate commit anyway.
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq
  show-trailing-whitespace t
  whitespace-style '(face tabs trailing lines-tail empty space-before-tab space-after-tab tab-mark newline-mark)
  )
;; (remove-hook 'after-change-major-mode-hook 'doom-highlight-non-default-indentation-h)
