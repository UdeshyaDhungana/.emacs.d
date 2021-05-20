
(use-package web-mode
  :ensure t
  :mode (("\\.html\\'" . web-mode)
	 ("\\.phtml\\'" . web-mode)
	 ("\\.tpl\\'" . web-mode)
;;	 ("\\.php\\'" . web-mode)
	 ("\\.[agj]sp\\'" . web-mode)
	 ("\\.as[cp]x\\'" . web-mode)
	 ("\\.erb\\'" . web-mode)
	 ("\\.mustache\\'" . web-mode)
	 ("\\.djhtml\\'" . web-mode)))

(use-package company-web
  :ensure t
  :defer t
  :after (web-mode)
  :hook (web-mode . (lambda ()
		      (require 'company-web)
		      (setq-local company-backends (cons 'company-web-html company-backends)))))

(use-package emmet-mode
  :ensure t
  :config
  (add-hook 'web-mode-hook 'emmet-mode)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode)
  (setq emmet-move-cursor-between-quotes t))
