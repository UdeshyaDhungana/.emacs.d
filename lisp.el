;; slime
(use-package slime
  :ensure t
  :commands (slime cl-services)
  :hook
  (add-to-list 'company-backends 'company-slime)
  :bind ("C-c d" . slime-documentation)
  :config
  (add-hook 'lisp-mode-hook (lambda() (slime-mode t)))
  (add-hook 'inferior-lisp-mode-hook (lambda() (inferior-slime-mode t)))
  (setq inferior-lisp-program "sbcl")
  (setq slime-contribs '(slime-fancy slime-repl)))

;; Currently, on the first launch of slime, I have to enable slime mode separately. Looking forward to automating this

;; slime company
(use-package slime-company
  :after (slime company)
  (slime-setup '(slime-fancy slime-company)))

;; cl snippets
(use-package common-lisp-snippets
  :ensure t)
