;;; zettelkasten.el --- note-taking: org, org-roam, math  -*- lexical-binding: t; -*-
;;
;; Everything note-related lives here; init.el loads it.  Keys under C-c n:
;;   j today's scratch   f find note      i insert link    e extract subtree
;;   d jump to a date    c new note       s search text
;; Not bound, run with M-x: ud/org-roam-delete-note

(require 'cl-lib)

;; org mode
(use-package org
  :hook (org-mode . visual-line-mode)
  :custom (org-pretty-entities t))

;; One todo file, kept outside the org-roam vault on purpose so it is neither
;; a node (C-c n f) nor grepped by C-c n s.  M-S-RET adds a "- [ ] " item,
;; C-c C-c toggles it, C-S-backspace deletes the line.
(defun ud/org-todo ()
  "Open the todo file."
  (interactive)
  (find-file "~/Documents/todo.org"))
(global-set-key (kbd "C-c t") #'ud/org-todo)

;; appearance
(setq org-hide-emphasis-markers t
      org-pretty-entities t)          ; \alpha -> α, no LaTeX needed

;; BasicTeX installs to /Library/TeX/texbin, which is not in the PATH launchd
;; hands the daemon, so Emacs cannot find latex without this.
(let ((texbin "/Library/TeX/texbin"))
  (when (file-directory-p texbin)
    (add-to-list 'exec-path texbin)
    (setenv "PATH" (concat texbin ":" (getenv "PATH")))))

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
  :custom (org-modern-list '((?- . "•") (?+ . "◦") (?* . "–"))))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom (org-appear-autoemphasis t))

;; Extract the subtree at point into its own file, accepting the default
;; filename.  Stock `org-roam-extract-subtree' prompts, and fido's RET
;; cannot accept a filename that does not exist yet -- cancelling there
;; leaves an :ID: behind with no file.
(require 'cl-lib)
(defun ud/org-roam-extract-subtree ()
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
(defun ud/org-roam-search (regexp)
  "Search the text of every note for REGEXP."
  (interactive "sSearch notes: ")
  (require 'org-roam)
  (let ((default-directory org-roam-directory))
    (grep (format "rg --line-number --with-filename --no-heading --smart-case --color=never %s"
                  (shell-quote-argument regexp)))))

;; Delete a note, warning about backlinks first.
(defun ud/org-roam-delete-note ()
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
         ("C-c n e" . ud/org-roam-extract-subtree)
         ("C-c n d" . org-roam-dailies-goto-date)
         ("C-c n c" . org-roam-capture)
         ("C-c n s" . ud/org-roam-search))
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

;; Convert bullets to checkboxes in org mode
(defun ud/org-convert-to-checkbox (arg)
  "Turn the next ARG lines, or the active region, into \"- [ ] \" checkboxes."
  (interactive "P")
  (let ((n (or arg 1)))
    (when (region-active-p)
      (setq n (count-lines (region-beginning)
                           (region-end)))
      (goto-char (region-beginning)))
    (dotimes (i n)
      (beginning-of-line)
      (insert "- [ ] ")
      (forward-line))
    (beginning-of-line)))

(provide 'zettelkasten)
;;; zettelkasten.el ends here
