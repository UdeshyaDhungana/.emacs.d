;;; init.el --- basic setup -*- lexical-binding: t; -*-

;; os specific
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

;; exec paths
(add-to-list 'exec-path "/Users/udeshya/go/bin")
(setenv "PATH" (concat "/Users/udeshya/go/bin:" (getenv "PATH")))

;; --- basics ---

;; --- frame geometry ---
;; maximized = fills the screen but stays a normal window
;; (fullscreen would take over its own macOS Space).
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . right))
;; setf, not add-to-list: replaces any earlier font entry on reload.
(setf (alist-get 'font default-frame-alist) "JetBrains Mono-18")

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
(setq-default indent-tabs-mode nil tab-width 4)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)
(setopt display-line-numbers-width-start t)
(global-tab-line-mode 1)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)

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

;;----- ud-custom functions----
(defun ud-initel ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun ud-kill-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))
(keymap-global-set "C-x k" 'ud-kill-buffer)

;; Nepali calendar
(defun ud-nepcal ()
  (interactive)
  (let ((buf (generate-new-buffer "*Nepali Calendar*")))
    (shell-command "nepdate cal -e" buf)
    (other-window 1)
    (ansi-color-apply-on-region (point-min) (point-max))
    (view-mode 1)))

(defun ud-kill-all-other-buffers()
  (interactive)
  (dolist (buffer (buffer-list)) (unless (eql buffer (current-buffer)) (kill-buffer buffer))))

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
        move-text org-appear org-autolist org-fragtog org-modern org-roam
        racket-mode ultra-scroll))

;; Smooth scrolling
;; -----------------
(use-package ultra-scroll
  :init
  (setq scroll-conservatively 101
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

;; move-text
;; ---------
;; M-<up> / M-<down> move the line (or region) up/down everywhere.  Org keeps
;; its own M-<up> (org-metaup), which moves whole items and subtrees.
(use-package move-text
  :config (move-text-default-bindings))

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


;; slime
;; -----
;; Common Lisp REPL and editing environment.
(use-package slime
  ;; `setq' in :init, not :custom: slime declares this with a bare `defvar',
  ;; so a Customize setting made before it loads is overwritten by "lisp".
  :init
  (setq inferior-lisp-program "/opt/homebrew/bin/sbcl")
  :config
  (slime-setup '(slime-fancy)))

(defun ud-prep ()
  "Open the NTC exam prep TODO list."
  (interactive)
  (find-file "~/Documents/ntc-prep.org"))


;; END OF THE FILE: Any packages should be declared above this line
;; Reload this file without restarting.
(defun ud-reload-config ()
  "Re-evaluate init.el in the running Emacs."
  (interactive)
  (load user-init-file nil t)
  (message "Reloaded %s" (abbreviate-file-name user-init-file)))

;; Themes-------
;; light
;; ef-melissa-light
;; ef-arcadia
;; ef-arbutus
;; ef-summer
;; ef-spring
;; ef-reverie
;; ef-orange

;; dark
;; ef-autumn
;; ef-elea-dark
;; ef-dream
;; ef-bio
;; ef-trio-dark
;; ef-symbiosis
;; ef-owl (plain)
(load-theme 'ef-autumn t)

;;;;;; zettelkasten ;;;;;;

;;
;; Everything note-related lives here.  Keys under C-c n:
;;   j today's scratch   f find note      i insert link    e extract subtree
;;   d jump to a date    c new note       s search text
;;   t todo file
;; Devanagari keys live under C-c d (C-c d h r: half-ra).
;; Math keys live under C-c m (i inline, d display).
;; Not bound, run with M-x: ud-org-roam-delete-note

(require 'cl-lib)

;; Half-ra for Devanagari typing: र + virama + zero-width joiner, so the next
;; consonant joins as र्‍य rather than forming the reph (र्य).
(defun ud-insert-half-ra ()
  "Insert र् + ZWJ (half-ra form), ready to be followed by a consonant."
  (interactive)
  (insert "र्‍"))

;; Insert an empty math pair with point inside, ready for cdlatex keys.
(defun ud-insert-inline-math ()
  "Insert \\( \\) with point in the middle."
  (interactive)
  (insert "\\(  \\)")
  (backward-char 3))

(defun ud-insert-display-math ()
  "Insert \\[ \\] with point in the middle."
  (interactive)
  (insert "\\[  \\]")
  (backward-char 3))

;; org mode
(use-package org
  :hook (org-mode . visual-line-mode)
  :bind (:map org-mode-map
              ("C-c d h r" . ud-insert-half-ra)
              ("C-c m i"   . ud-insert-inline-math)
              ("C-c m d"   . ud-insert-display-math)
              ;; Unbound: it adds files to the agenda list behind your back.
              ("C-c [" . nil)
              ("C-c ]" . nil))
  ;; The agenda reads only the todo file below, set here rather than via
  ;; Customize so custom.el does not carry it.
  :custom ((org-pretty-entities t)
           (org-agenda-files '("~/Documents/todo.org"))))

;; One todo file, kept outside the org-roam vault on purpose so it is neither
;; a node (C-c n f) nor grepped by C-c n s.  M-S-RET adds a "- [ ] " item,
;; C-c C-c toggles it, C-S-backspace deletes the line.
(defun ud-org-todo ()
  "Open the todo file."
  (interactive)
  (find-file "~/Documents/todo.org"))
(global-set-key (kbd "C-c n t") #'ud-org-todo)

;; appearance
(setq org-hide-emphasis-markers t
      org-pretty-entities t           ; \alpha -> α, no LaTeX needed
      ;; ...but leave _{} ^{} visible: hiding them makes empty cdlatex
      ;; templates (suml TAB) look like they have no braces.
      org-pretty-entities-include-sub-superscripts nil)

;; BasicTeX installs to /Library/TeX/texbin, which is not in the PATH launchd
;; hands the daemon, so Emacs cannot find latex without this.  Guarded because
;; this file is re-run on every config reload and `setenv' would stack copies.
(let ((texbin "/Library/TeX/texbin"))
  (when (file-directory-p texbin)
    (add-to-list 'exec-path texbin)
    (unless (member texbin (split-string (getenv "PATH") ":"))
      (setenv "PATH" (concat texbin ":" (getenv "PATH"))))))

;; math
;; dvisvgm renders fragments as SVG, so they stay sharp at 18pt and when zoomed.
;; `org-format-latex-options' is a defcustom in org.el, so it only exists once
;; org is loaded -- and the `use-package org' above defers that.  Mutating it at
;; top level voided the variable and aborted the rest of init.
(with-eval-after-load 'org
  (setq org-preview-latex-default-process 'dvisvgm)
  (plist-put org-format-latex-options :scale 1.6))

;; Preview a fragment when point leaves it, show the source when point enters.
(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

;; Fast math input: C-c { for environments, ` for Greek, / for \frac, TAB to
;; jump between template holes.
(use-package cdlatex
  :hook (org-mode . org-cdlatex-mode))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  ;; `replace' stars: the default `fold' style uses ⯈/⯆ at level 3, which
  ;; JetBrains Mono lacks.
  :custom ((org-modern-star 'replace)
           (org-modern-list '((?- . "•") (?+ . "◦") (?* . "–")))))

;; RET on a list item starts the next one (a checkbox if this one has one);
;; RET on an empty item ends the list.  Saves reaching for M-RET / M-S-RET.
(use-package org-autolist
  :hook (org-mode . org-autolist-mode)
  :config
  ;; Its checkbox branch reads the item via (plist-get (cadr el) :parent),
  ;; which Org 9.7's org-element rewrite broke, so "- [ ] foo" RET falls
  ;; through to plain `org-meta-return' and loses the box.  Put it back,
  ;; only for RET so M-RET keeps its meaning.
  (define-advice org-meta-return (:around (fn &rest args) zettelkasten--checkbox)
    (let ((item (org-in-item-p)))
      (if (and (eq this-command 'org-return) item
               (save-excursion (goto-char item) (org-at-item-checkbox-p)))
          (org-insert-item t)
        (apply fn args)))))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom (org-appear-autoemphasis t))

;; Extract the subtree at point into its own file, accepting the default
;; filename.  Stock `org-roam-extract-subtree' prompts, and fido's RET
;; cannot accept a filename that does not exist yet -- cancelling there
;; leaves an :ID: behind with no file.
(require 'cl-lib)
(defun ud-org-roam-extract-subtree ()
  "Extract the subtree at point into its own file, no prompt."
  (interactive)
  (let ((source (buffer-file-name (buffer-base-buffer))))
    ;; `org-roam-extract-subtree' reads the new file name from the node in the
    ;; database, so the node has to be indexable for the length of the call --
    ;; otherwise its title is nil and ${slug} fails.  Re-index afterwards so
    ;; the daily drops back out.
    (cl-letf (((symbol-function 'read-file-name)
               (lambda (_prompt &optional dir default-filename &rest _)
                 (expand-file-name (or default-filename "") dir))))
      (let ((org-roam-db-node-include-function (lambda () t)))
        (org-roam-extract-subtree)))
    ;; The permissive save above recorded the daily's hash, so a plain
    ;; update would be a no-op.  Clear the row first to force a re-index.
    (when source
      (org-roam-db-clear-file source)
      (org-roam-db-update-file source))))

;; Full-text search across every note.  C-c n f only matches titles.
(defun ud-org-roam-search (regexp)
  "Search the text of every note for REGEXP."
  (interactive "sSearch notes: ")
  (require 'org-roam)
  (let ((default-directory org-roam-directory))
    (grep (format "rg --line-number --with-filename --no-heading --smart-case --color=never %s"
                  (shell-quote-argument regexp)))))

;; Delete a note, warning about backlinks first.
(defun ud-org-roam-delete-note ()
  "Delete the file of a note chosen by title, after showing its backlinks."
  (interactive)
  (require 'org-roam)
  (let* ((node (org-roam-node-read nil nil nil t "Delete note: "))
         (file (org-roam-node-file node))
         (title (org-roam-node-title node))
         (sources (delete-dups
                   (mapcar (lambda (b)
                             (org-roam-node-title (org-roam-backlink-source-node b)))
                           (org-roam-backlinks-get node :unique t)))))
    (unless (zerop (org-roam-node-level node))
      (user-error "\"%s\" is a heading inside %s, not its own file"
                  title (file-name-nondirectory file)))
    ;; Nothing points here, so nothing can break: delete without asking.
    ;; Only an incoming link is worth a confirmation.
    (if (and sources
             (not (yes-or-no-p
                   (format "%d note(s) link to \"%s\" (%s) -- those links will break.  Delete anyway? "
                           (length sources) title (string-join sources ", ")))))
        (message "Kept \"%s\"" title)
      (delete-file file t)                ; t = macOS Trash, recoverable
      (message "Trashed %s%s" (file-name-nondirectory file)
               (if sources (format " -- %d broken link(s)" (length sources)) "")))))

(use-package org-roam
  :custom (org-roam-directory (file-truename "~/Documents/org-roam"))
  :bind (("C-c n j" . org-roam-dailies-goto-today)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n e" . ud-org-roam-extract-subtree)
         ("C-c n d" . org-roam-dailies-goto-date)
         ("C-c n c" . org-roam-capture)
         ("C-c n s" . ud-org-roam-search))
  :config
  ;; Dailies are scratch, not notes: keep every node in daily/ out of the
  ;; database so they never appear in C-c n f.
  (setq org-roam-db-node-include-function
        (lambda ()
          (not (string-prefix-p (expand-file-name "daily/" org-roam-directory)
                                (or (buffer-file-name (buffer-base-buffer)) "")))))
  (org-roam-db-autosync-mode))

;; Start on today's daily note instead of whatever buffer the daemon happens
;; to have current.  `initial-buffer-choice' is the right hook rather than
;; `server-after-make-frame-hook': server.el consults it only when the client
;; passed no file arguments, so "emacsclient -c foo.el" still opens foo.el.
;; Must return a buffer without selecting it -- hence save-window-excursion
;; around `org-roam-dailies-goto-today', which has no -noselect variant.
(defun zettelkasten--today-buffer ()
  "Return the buffer of today's daily note, creating the file if absent.
Falls back to *scratch* on any error, so a broken note or an org-roam
problem can never leave you staring at an unusable frame."
  (or (ignore-errors
        (require 'org-roam)
        (save-window-excursion
          (org-roam-dailies-goto-today)
          (current-buffer)))
      (get-scratch-buffer-create)))

(setq initial-buffer-choice #'zettelkasten--today-buffer)

;;;;;; cheatsheet ;;;;;;

;;
;; C-c ? pops up a side window listing every ud- function with its key
;; binding and the first line of its docstring.
;;
;; There is nothing to register.  The list is built by walking the obarray
;; at call time, so a ud- function appears the moment it is evaluated --
;; write one, reload, and it is in the list.  The one consequence worth
;; knowing: a function in a file that has not been loaded yet is invisible,
;; because nothing has defined the symbol.
;;
;; Everything in here except the entry point is named cheatsheet-*, not
;; ud-*: ud- is the M-x namespace, so a non-interactive helper put in it
;; would show up as a command you can run.
;;
;; The payoff for keeping docstrings on your commands is here, so the list
;; calls out the ones that lack a docstring rather than leaving a blank.

(defconst cheatsheet-buffer-name "*My Commands*"
  "Name of the buffer the cheatsheet renders into.")

(defun cheatsheet--symbols ()
  "Every ud- function, sorted by name."
  (let (syms)
    (mapatoms
     (lambda (sym)
       (when (and (fboundp sym)
                  (string-prefix-p "ud-" (symbol-name sym)))
         (push sym syms))))
    (sort syms (lambda (a b) (string< (symbol-name a) (symbol-name b))))))

(defun cheatsheet--key (sym)
  "Key sequence bound to SYM as a string, empty if it has none.
Only meaningful for commands, and resolved against the keymaps active
in the buffer the cheatsheet was called from -- so a binding local to
some other major mode will not show up here."
  (if-let* ((keys (and (commandp sym) (where-is-internal sym nil t))))
      (propertize (key-description keys) 'face 'help-key-binding)
    ""))

(defun cheatsheet--summary (sym)
  "First line of SYM's docstring, or a note that there is not one."
  (let ((doc (ignore-errors (documentation sym t))))
    (if (and doc (not (string-empty-p (string-trim doc))))
        (car (split-string doc "\n" t))
      (propertize "no docstring" 'face 'shadow))))

(defun cheatsheet--key< (a b)
  "Order entries A and B so bound commands sort before unbound ones.
Within each group the order is alphabetical by key sequence."
  (let ((ka (aref (cadr a) 0))
        (kb (aref (cadr b) 0)))
    (cond ((string-empty-p ka) nil)
          ((string-empty-p kb) t)
          (t (string< ka kb)))))

(defun cheatsheet--entries ()
  "Build `tabulated-list-entries' for the ud- functions.
Call this in the buffer you want key bindings resolved against, not in
the cheatsheet buffer itself."
  (mapcar (lambda (sym)
            (list sym
                  (vector (cheatsheet--key sym)
                          (propertize (symbol-name sym)
                                      'face 'font-lock-function-name-face)
                          (cheatsheet--summary sym))))
          (cheatsheet--symbols)))

;; RET on a row opens the function's help, which is the natural next step
;; after spotting something in the list you half remember.
(defvar-keymap cheatsheet-mode-map
  :doc "Keymap for `cheatsheet-mode'."
  "RET" #'cheatsheet-describe)

(define-derived-mode cheatsheet-mode tabulated-list-mode "Commands"
  "Major mode for the ud- command cheatsheet.
\\<cheatsheet-mode-map>\\[quit-window] closes the window, \
\\[cheatsheet-describe] describes the function on the current line."
  (setq tabulated-list-format [("Key" 11 cheatsheet--key<)
                               ("Command" 35 t)
                               ("What it does" 0 t)]
        tabulated-list-padding 1
        ;; Sort so the commands that have a shortcut come first; a plain
        ;; string sort would put the empty Key cells on top instead.
        tabulated-list-sort-key '("Key" . nil))
  (tabulated-list-init-header))

(defun cheatsheet-describe ()
  "Describe the function on the current cheatsheet line."
  (interactive)
  (if-let* ((sym (tabulated-list-get-id)))
      (describe-function sym)
    (user-error "No function on this line")))

;;;###autoload
(defun ud-shortcuts-cheatsheet ()
  "List my ud- commands with their key bindings and one-line summaries.
Opens a side window on the right; q closes it, RET describes the
function on the current line.  The list is regenerated on every call, so
newly written ud- functions show up without registering them anywhere."
  (interactive)
  ;; Resolve bindings here, while the original buffer is still current --
  ;; inside the cheatsheet buffer only its own keymaps would be active.
  (let ((entries (cheatsheet--entries))
        (buf (get-buffer-create cheatsheet-buffer-name)))
    (with-current-buffer buf
      (cheatsheet-mode)
      (setq tabulated-list-entries entries)
      ;; g re-scans instead of redrawing a stale list.
      (add-hook 'tabulated-list-revert-hook
                (lambda () (setq tabulated-list-entries (cheatsheet--entries)))
                nil t)
      (tabulated-list-print))
    (select-window
     (display-buffer-in-side-window
      buf '((side . right) (window-width . 76) (slot . 0))))
    (message "%d ud- command(s).  q to close, RET to describe, g to refresh"
             (length entries))))

(global-set-key (kbd "C-c ?") #'ud-shortcuts-cheatsheet)
