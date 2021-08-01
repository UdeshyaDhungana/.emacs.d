;; Personal config
;; post config
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

;; iBuffer
(global-set-key (kbd "C-x b") 'ibuffer)
(super-save-mode -1)

;; switch between themes
(defvar *dude-theme-dark* 'wombat)
(defvar *dude-theme-light* 'adwaita)
(defvar *dude-current-theme* *dude-theme-dark*)

;; disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))


(defun dude/next-theme (theme)
  (if (eq theme 'default)
      (disable-theme *dude-current-theme*)
    (progn
      (load-theme theme t)))
  (setq *dude-current-theme* theme))

(defun dude/toggle-theme ()
  (interactive)
  (cond ((eq *dude-current-theme* *dude-theme-dark*) (dude/next-theme *dude-theme-light*))
        (t (dude/next-theme *dude-theme-dark*))))


;; Use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; org bullets
(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode))))

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

(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

(use-package emmet-mode
  :ensure t
  :config
  (add-hook 'web-mode-hook 'emmet-mode)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode)
  (setq emmet-move-cursor-between-quotes t))

;; evil leader mode
(use-package evil-leader
  :ensure
  :after evil
  :config
  (global-evil-leader-mode)
      (evil-leader/set-leader ",")
      (evil-leader/set-key
        "," 'save-buffer
        "b" 'switch-to-buffer
        "l" 'evil-window-right
        "h" 'evil-window-left
        "k" 'evil-window-up
        "j" 'evil-window-down
        "v" 'evil-window-vsplit
        "d" 'evil-window-split
        "i" 'ibuffer
        "q" 'kill-curr-buffer
        "0" 'delete-window
        "1" 'delete-other-windows
        "f" 'ido-find-file)
      (evil-mode t))

;; company settings
(setq company-idle-delay 0.2)
(with-eval-after-load 'company
  (define-key company-active-map [tab] 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle))
