;; My personal config
;; pre-config
;; unrelated to external packages are here!


(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;Maximize on start

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

;; clock
(display-time-mode 1)

;; show parenthesis
(show-paren-mode)

;; for kde gaps
(setq frame-resize-pixelwise t)


;; setting theme ====== PRELUDE
(setq prelude-theme 'wombat)

;; org mode export
(setq org-export-html-validation-link nil)
