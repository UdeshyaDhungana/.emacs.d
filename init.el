;; ========================================GUI settings
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-enabled-themes '(gruvbox-dark-medium))
 '(custom-safe-themes
   '("8f97d5ec8a774485296e366fdde6ff5589cf9e319a584b845b6f7fa788c9fa9a" default))
 '(display-line-numbers-type 'relative)
 '(global-display-line-numbers-mode t)
 '(line-number-mode nil)
 '(package-selected-packages
   '(multiple-cursors swiper popup-kill-ring telephone-line spaceline dashboard company hungry-delete rainbow-mode avy smex ido-vertical-mode org-bullets gruvbox-theme which-key use-package))
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
(global-set-key (kbd "<s-return>") 'ansi-term)

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
;; (setq ido-everywhere t)
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

;; ========================================Packages
;; Add MELPA to emacs
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

;; Use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(unless (package-installed-p 'gruvbox-theme)
  (package-refresh-contents)
  (package-install 'gruvbox-theme))

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

;; Idon-vertical
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

;; rainbow mode
(use-package rainbow-mode
  :ensure t
  :init (rainbow-mode 1))

;; hungry-delete
(use-package hungry-delete
  :ensure t
  :config (global-hungry-delete-mode))

;; Dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 10)))
  (setq dashboard-banner-logo-title "Welcome!")
  (setq dashboard-startup-banner "~/Pictures/emacs.png"))
  
;; ========================================Company
;; company works by default with elisp
(use-package company
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "SPC") #'company-abort))


;; ========================================
;; spaceline
(use-package telephone-line
  :ensure t
  :config
  (telephone-line-mode 1))

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
