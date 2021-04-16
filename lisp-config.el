
;; slime
(use-package slime
  :ensure t
  :commands (slime cl-services)
  :hook
  (add-to-list 'company-backends 'company-slime)
  :bind ("C-c d" . slime-documentation)
  :config
  (setq inferior-lisp-program "sbcl"))

;; slime company
(use-package slime-company
  :after (slime company)
  (slime-setup '(slime-fancy slime-company)))

;; cl snippets
(use-package common-lisp-snippets
  :ensure t)
