(use-package company
  :ensure t
  :custom
  (company-auto-complete t)
  (company-idle-delay 0.4)
  (company-require-match nil)
  (company-minimum-prefix-length 2)
  :init
  ;; should abort on pressing space
  (global-company-mode 1)
  (defun company-abort-and-insert-space ()
  (interactive)
  (company-abort)
  (insert " "))
  :config
  (define-key company-active-map (kbd "SPC") #'company-abort-and-insert-space))
  
;; yasnippet
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; eglot
(use-package eglot
  :ensure t
  :config
  (add-to-list 'eglot-server-programs '((c-mode) "clangd"))
  (add-to-list 'eglot-server-programs '((python-mode) "pyls"))
  (add-hook 'c-mode-hook 'eglot-ensure)
  (add-hook 'python-mode-hook 'eglot-ensure))

;; company quickhelp
(use-package company-quickhelp
  :ensure t
  :after company
  :custom
  (company-quickhelp-color-background "#4F4F4F")
  (company-quickhelp-color-foreground "#DCDCCC")
  (company-quickhelp-delay 0.1)
  (company-quickhelp-mode t)
  (company-quickhelp-use-propertized-text t)
  :config 
  (add-to-list 'company-frontends 'company-quickhelp-frontend))

(use-package flycheck
  :ensure t
  :defer t
  :commands (flycheck-mode))

(use-package lsp-ui
  :ensure t
  :defer t 
  :after '(lsp-mode))

(use-package lsp-mode
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :ensure t 
  :defer t 
  :commands (lsp lsp-mode)
  :bind (:map lsp-mode-map
	      ("M-." . lsp-find-definition)
	      ("M-?" . lsp-find-references)
	      ("M-," . pop-tag-mark))
  :init
  (setq lsp-keymap-prefix "M-m l")
  :config
  (setq lsp-auto-configure t)

  (setq lsp-enable-symbol-highlighting t)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-lens-enable t)
  (setq lsp-headerline-breadcrumb-enable t)
  ;; Sideline code actions 
  (setq lsp-ui-sideline-show-code-actions nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-modeline-code-actions-enable nil)
  ;; * hide only errors
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-eldoc-enable-hover t)
  (setq lsp-modeline-diagnostics-enable t)
  (setq lsp-signature-auto-activate t)
  (setq lsp-signature-render-documentation t))
