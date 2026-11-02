;;; init.el --- basic setup -*- lexical-binding: t; -*-

;; --- macOS modifier keys (GUI Emacs only) ---
;; Both Command keys -> Meta, so either Cmd-x is M-x.
;; Both Option keys  -> Super, giving s- bindings a home key.
(when (eq system-type 'darwin)
  (setq ns-command-modifier        'meta
        ns-right-command-modifier  'meta
        ns-option-modifier         'super
        ns-right-option-modifier   'super))

;; --- native compilation: off ---
;; Emacs.app bundles libgccjit but not the gcc driver binary it shells out to,
;; so every JIT attempt dies with "error invoking gcc driver". Byte-code only.
(setq native-comp-jit-compilation nil
      native-comp-enable-subr-trampolines nil
      native-comp-async-report-warnings-errors nil)

;; --- dired on macOS ---
;; BSD ls has no --dired; use GNU ls (brew install coreutils) when present.
(let ((gls (executable-find "gls")))
  (if gls
      (setq insert-directory-program gls)
    (setq dired-use-ls-dired nil)))

;; --- frame geometry ---
;; maximized = fills the screen but stays a normal window
;; (fullscreen would take over its own macOS Space).
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . right))
(add-to-list 'default-frame-alist '(font . "Fira Code-18"))

;; --- basics ---
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))

(menu-bar-mode 1)
(tool-bar-mode -1)
(set-scroll-bar-mode 'right)
(column-number-mode 1)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(savehist-mode 1)
(fido-vertical-mode 1)          ; nicer completion in the minibuffer

(setq-default indent-tabs-mode nil
              tab-width 4)

;; --- server ---
;; Fixed socket path so emacsclient always finds the daemon, regardless of
;; how TMPDIR differs between launchd and your shell.
(setq server-socket-dir (expand-file-name "server" user-emacs-directory))
(require 'server)
(unless (server-running-p)
  (server-start))

;; Pull a newly created client frame to the front.
(add-hook 'server-after-make-frame-hook
          (lambda () (select-frame-set-input-focus (selected-frame))))

;; package archives, for when you want to install something
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)


;; Custom writes here, not into this file. `package-install' saves
;; `package-selected-packages' via Custom, which opens `custom-file' in a
;; buffer and saves it -- pointed at init.el that silently reverts
;; hand-written config from a stale buffer.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(setopt display-line-numbers-width-start t)


;; ============================================================================
;; Packages
;; ============================================================================
;; One `use-package' block per package: it installs (`:ensure'), configures,
;; and defers loading in a single form. Built into Emacs since 29.

(require 'package)
(unless package-archive-contents (package-refresh-contents))
(setq use-package-always-ensure t)   ; every block below installs if missing
(setq package-selected-packages
      '(auctex cdlatex gruvbox-theme markdown-mode markdown-preview-mode
        org-appear org-fragtog org-modern org-roam racket-mode
        ultra-scroll))

;; markdown-mode
;; -------------
;; Editing + live HTML preview for .md files.
;;   C-c C-c l   markdown-live-preview-mode  preview in an eww side window
;;   C-c C-c p   markdown-preview            one-shot render in the browser
;;   C-c C-c m   markdown-other-window       show the raw HTML
;; Rendering goes through pandoc; gfm-mode gives GitHub syntax (tables,
;; task lists, fenced code).
(use-package markdown-mode
  :mode (("\\.md\\'"       . gfm-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-command
   (concat (executable-find "pandoc")
           " --from=gfm --to=html5 --standalone --mathjax --highlight-style=pygments"))
  (markdown-fontify-code-blocks-natively t)
  (markdown-live-preview-delete-export 'delete-on-destroy))


;; markdown-preview-mode
;; ---------------------
;; As-you-type preview. markdown-mode's own `markdown-live-preview-mode'
;; only refreshes on `after-save-hook', and `markdown-export' saves the
;; source buffer behind your back when it is dirty. This pushes the
;; rendered buffer to a browser tab over a websocket on every keystroke
;; instead, reusing `markdown-command' above -- no extra runtime needed.
(use-package markdown-preview-mode
  :after markdown-mode
  :bind (:map markdown-mode-map ("C-c C-c v" . markdown-preview-mode)))


;; Reload this file without restarting.
(defun ud/reload-config ()
  "Re-evaluate init.el in the running Emacs."
  (interactive)
  (load user-init-file nil t)
  (message "Reloaded %s" (abbreviate-file-name user-init-file)))


;; --------------------- ZETTELKASTEN --------------------
;; Note-taking config (org, org-roam, math) lives in its own file.
;; `load', not `require', so ud/reload-config picks up edits to it.
(load (expand-file-name "lisp/zettelkasten.el" user-emacs-directory))

;; --------------------- CHEATSHEET ----------------------
;; C-c ? lists every ud/ command with its key and docstring summary.
;; Loaded last so the ud/ functions defined above already exist -- though
;; the list is rebuilt on each call, so load order only affects the first.
(load (expand-file-name "lisp/cheatsheet.el" user-emacs-directory))

;; theme

;; (load-theme 'ef-fig t) ;; nostalgic ubuntu theme
(load-theme 'ef-autumn t)  ;; High contrast dark: Pleasant onl eyes at night
;; (load-theme 'ef-reverie t) ;; Creamy and slightly pink light theme
;; (load-theme 'ef-cyprus t) ;; Creamy and slightly green light theme

;; Smooth scrolling
;; -----------------
(use-package ultra-scroll
  :init
  (setq scroll-conservatively 101
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

;; display tab bar
(global-tab-line-mode 1)
(put 'narrow-to-region 'disabled nil)
