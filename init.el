(load-theme 'gruvbox-dark-medium t)

;; Maximize on start
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Simple use-package declaration
(eval-when-compile
  (require 'use-package))

;; ============================================================
;; Loaded from emacs GUI settings
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#3c3836" "#fb4933" "#b8bb26" "#fabd2f" "#83a598" "#d3869b" "#8ec07c" "#ebdbb2"])
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(compilation-message-face 'default)
 '(custom-safe-themes nil)
 '(display-battery-mode t)
 '(display-line-numbers-type 'relative)
 '(fci-rule-color "#383838")
 '(global-display-line-numbers-mode t)
 '(highlight-changes-colors '("#FD5FF0" "#AE81FF"))
 '(highlight-tail-colors
   '(("#3C3D37" . 0)
     ("#679A01" . 20)
     ("#4BBEAE" . 30)
     ("#1DB4D0" . 50)
     ("#9A8F21" . 60)
     ("#A75B00" . 70)
     ("#F309DF" . 85)
     ("#3C3D37" . 100)))
 '(magit-diff-use-overlays nil)
 '(nrepl-message-colors
   '("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3"))
 '(package-selected-packages
   '(counsel-projectile projectile slime-company gruvbox-theme ewal-spacemacs-themes slime avy multiple-cursors company-quickhelp rainbow-mode emojify company smartparens evil-smartparens magit counsel which-key use-package))
 '(pdf-view-midnight-colors '("#fdf4c1" . "#282828"))
 '(pos-tip-background-color "#FFFACE" t)
 '(pos-tip-foreground-color "#272822" t)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   '((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3")))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(weechat-color-list
   '(unspecified "#272822" "#3C3D37" "#F70057" "#F92672" "#86C30D" "#A6E22E" "#BEB244" "#E6DB74" "#40CAE4" "#66D9EF" "#FB35EA" "#FD5FF0" "#74DBCD" "#A1EFE4" "#F8F8F2" "#F8F8F0")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Fira Code" :foundry "CTDB" :slant normal :weight normal :height 108 :width normal))))
 '(company-scrollbar-bg ((t (:background "#45bb4ed351db"))))
 '(company-scrollbar-fg ((t (:background "#39f441834408"))))
 '(company-tooltip ((t (:inherit default :background "#32e339873bbd"))))
 '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
 '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))
;; ============================================================
;; More editor settings

;; Changing yes/no to y/n
(defalias 'yes-or-no-p 'y-or-n-p)

;; Add MELPA to emacs
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))

;; Packages
;; ============================================================

;; which-key
(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))

;; Ivy
(use-package ivy
  :ensure t
  :config
  (ivy-mode t)
  (setq ivy-use-virtual-buffers t
	ivy-count-format "[%d/%d] "))

;; Counsel
(use-package counsel
  :ensure t
  :bind (("C-s" . swiper-isearch)
	 ("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 ("M-y" . counsel-yank-pop)
	 ("<f1> f" . counsel-describe-function)
	 ("<f1> v" . counsel-describe-variable)
	 ("<f1> l" . counsel-find-library)
	 ("<f2> i" . counsel-info-lookup-symbol)
	 ("<f2> u" . counsel-unicode-char)
	 ("<f2> j" . counsel-set-variable)
	 ("C-x b" . ivy-switch-buffer)
	 ("C-<tab>" . ivy-switch-buffer)
	 ("C-c v" . ivy-push-view)
	 ("C-c V" . ivy-pop-view)))

;; Swiper
(use-package swiper
  :ensure t)

;; Magit
(use-package magit
  :ensure t
  :defer t)

;; Smartparens
(use-package smartparens
  :ensure t
  :init
  (require 'smartparens-config)
  :config
  (smartparens-global-mode t)
  :hook ((prog-mode . smartparens-mode))
  :bind (
	 ;; Unlisted are unchanged
	 ;; Movement
	 ("C-M-a" . sp-beginning-of-sexp)
	 ("C-M-e" . sp-end-of-sexp)

	 ;; wrapping and unwrapping
	 ("C-M-d" . sp-unwrap-sexp)))

;; Emojify
(use-package emojify
  :hook (after-init . global-emojify-mode))

;; Rainbow mode
(use-package rainbow-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode))

(use-package company
  :ensure t
  :demand t
  :init
  (setf company-frontends
	'(company-echo-frontend company-pseudo-tooltip-frontend company-echo-metadata-frontend company-preview-if-just-one-frontend))
  (global-company-mode 1)
  :custom
  (company-idle-delay 0.2)
  (company-auto-complete t)
  (company-minimum-prefix-length 2)
  
  :bind (("C-?" . company-show-doc-buffer)))

(use-package company-quickhelp
  :ensure t
  :after company
  :custom
  ;; (company-quickhelp-color-background "#4F4F4F")
  ;; (company-quickhelp-color-foreground "#DCDCCC")
  (company-quickhelp-mode t)
  (company-quickhelp-use-propertized-text t)
  :config
  (add-to-list 'company-frontends 'company-quickhelp-frontend))

;; multiple cursors
(use-package multiple-cursors
  :ensure t
  :defer t
  :commands (mc/edit-lines mc/mark-next-like-this mc/mark-previous-like-this mc/mark-all-like-this)
  :bind (("C-|" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

;; avy
(use-package avy
  :ensure t
  :defer t
  :config
  (setq avy-timeout-seconds 1)
  :bind (("C-:" . avy-goto-char)
	 ("C-'" . avy-goto-char-2)
	 ("C-\"" . avy-goto-char-timer)))

;; slime
;; workflow
(use-package slime
  :ensure t
  :hook
  (add-to-list 'company-backends 'company-slime)
  :config
  (setq inferior-lisp-program "sbcl")
  (require 'slime-autoloads))

;; projectile
(use-package projectile
  :ensure t
  :defer t
  :config
  (require 'counsel-projectile)
  :init 
  (setq projectile-indexing-method 'alien)
  :bind-keymap ("C-c p" . projectile-command-map))

;; Counsel projectile
(use-package counsel-projectile
  :ensure t
  :defer t 
  :config
  (counsel-projectile-mode 1))

;; Learn magit
;; Learn org writing
;; Learn org agendas
;; ====================
;; setup C development
;; setup python development
;; setup web development
;; setup flutter development
