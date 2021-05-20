;; Essentials

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(unless (package-installed-p 'dracula-theme)
  (package-refresh-contents)
  (package-install 'dracula-theme))

;; ========================================GUI settings
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#3c3836" "#fb4933" "#b8bb26" "#fabd2f" "#83a598" "#d3869b" "#8ec07c" "#ebdbb2"])
 '(column-number-mode t)
 '(custom-safe-themes
   '("a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0" "fc041225c2c6c34143f46493fa69b347c6136464cbd9dac08d196259d7315ce4" default))
 '(display-line-numbers-type 'relative)
 '(global-display-line-numbers-mode t)
 '(line-number-mode nil)
 '(org-agenda-files
   '("~/Org/hobbies.org" "~/Org/coursework.org" "~/Notes/keybindings.org"))
 '(package-selected-packages
   '(slime-autoloads emmet-mode company-web web-mode emojify exec-path-from-shell elpy ace-window python-mode company-jedi lsp-python-ms jedi-core lsp-jedi common-lisp-snippets dracula-theme eglot slime company-lsp flycheck emacs-ccls yasnippet company-box company-irony company lsp-ui magit lsp-mode multiple-cursors swiper popup-kill-ring telephone-line spaceline dashboard hungry-delete rainbow-mode avy smex ido-vertical-mode org-bullets gruvbox-theme which-key use-package))
 '(pdf-view-midnight-colors '("#fdf4c1" . "#282828"))
 '(show-paren-mode t)
 '(tool-bar-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :foundry "DAMA" :family "Fira Code Retina")))))

;; ========================================Editor custom settings
(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;Maximize on start

;; ansi-term
(defvar my-term-shell "/bin/bash")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)
;; launch ansi term shortcut
(global-set-key (kbd "<s-M-return>") 'ansi-term)

;; scrolling
(setq scroll-conservatively 100)
;; disable bell
(setq ring-bell-function 'ignore)
;; Disable annyoances
(when window-system (global-hl-line-mode t))
(setq make-backup-files nil)
(setq auto-save-default nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Ido mode
(setq ido-enable-flex-matching nil)
(setq ido-create-new-buffer 'always)
(setq ido-everywhere t)
(ido-mode 1)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

;; iBuffer
(global-set-key (kbd "C-x b") 'ibuffer)

;; Editing config files
(defun config-visit()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c e") 'config-visit)

;; Reloading config files
(defun config-reload()
  (interactive)
  (load-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c r") 'config-reload)

;; Better windows
(defun split-and-follow-horizontally()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(setq electric-pair-pairs '(
			    (?\( . ?\))
			    (?\[ . ?\])
			    (?\{ . ?\})))
(electric-pair-mode t)

(line-number-mode 1)
(column-number-mode 1)

;; kill current buffer
(defun kill-curr-buffer()
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key (kbd "C-x k") 'kill-curr-buffer)

;; Copy line
(defun copy-whole-line()
  (interactive)
  (save-excursion
    (kill-new
     (buffer-substring
      (point-at-bol)
      (point-at-eol)))))
(global-set-key (kbd "C-c w l") 'copy-whole-line)

;; clock
(display-time-mode 1)

;; show parenthesis
(show-paren-mode)

;; for kde gaps
(setq frame-resize-pixelwise t)

;; ========================================Packages

;; which-key
(use-package which-key
  :ensure t
  :init
  (which-key-mode))

;; org bullets
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode))))

;; make emacs path variable same as bash path
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (daemonp)
  (exec-path-from-shell-initialize)))

;; Ido-vertical
(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

;; Smex (ido for M-x)
(use-package smex
  :ensure t
  :init (smex-initialize)
  :bind
  ("M-x" . smex))

;; avy
(use-package avy
  :ensure t
  :bind
  ("M-s" . avy-goto-char-2))

;; ace-window
(use-package ace-window
  :ensure t
  :bind ("C-x o" . ace-window))

;; rainbow mode
(use-package rainbow-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode))

;; hungry-delete
;; (use-package hungry-delete
;;   :ensure t
;;   :config (global-hungry-delete-mode))

;; Dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 10)))
  (setq dashboard-banner-logo-title "What a wonderful world! 🌹")
  (setq dashboard-startup-banner "~/Pictures/emacs.png"))

;; emojify mode
(use-package emojify
  :hook (after-init . global-emojify-mode))

;; swiper
(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

;; multiple cursors
(use-package multiple-cursors
  :ensure t
  :defer t
  :commands (mc/edit-lines mc/mark-next-like-this mc/mark-previous-like-this mc/mark-all-like-this)
  :bind (("C-|" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

;; magit
(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status)))

;; ========================================Languages
;; setup using lsp

;; Modules
(load "~/.emacs.d/programming.el")
(load "~/.emacs.d/lisp.el")
(load "~/.emacs.d/python.el")
(load "~/.emacs.d/orgmode.el")
(load "~/.emacs.d/web.el")
