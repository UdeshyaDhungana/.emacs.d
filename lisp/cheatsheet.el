;;; cheatsheet.el --- index of my own commands  -*- lexical-binding: t; -*-
;;
;; C-c ? pops up a side window listing every ud/ function with its key
;; binding and the first line of its docstring.
;;
;; There is nothing to register.  The list is built by walking the obarray
;; at call time, so a ud/ function appears the moment it is evaluated --
;; write one, reload, and it is in the list.  The one consequence worth
;; knowing: a function in a file that has not been loaded yet is invisible,
;; because nothing has defined the symbol.
;;
;; Everything in here except the entry point is named cheatsheet-*, not
;; ud/*: ud/ is the M-x namespace, so a non-interactive helper put in it
;; would show up as a command you can run.
;;
;; The payoff for keeping docstrings on your commands is here, so the list
;; calls out the ones that lack a docstring rather than leaving a blank.

(defconst cheatsheet-buffer-name "*My Commands*"
  "Name of the buffer the cheatsheet renders into.")

(defun cheatsheet--symbols ()
  "Every ud/ function, sorted by name."
  (let (syms)
    (mapatoms
     (lambda (sym)
       (when (and (fboundp sym)
                  (string-prefix-p "ud/" (symbol-name sym)))
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
  "Build `tabulated-list-entries' for the ud/ functions.
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
  "Major mode for the ud/ command cheatsheet.
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
(defun ud/shortcuts-cheatsheet ()
  "List my ud/ commands with their key bindings and one-line summaries.
Opens a side window on the right; q closes it, RET describes the
function on the current line.  The list is regenerated on every call, so
newly written ud/ functions show up without registering them anywhere."
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
    (message "%d ud/ command(s).  q to close, RET to describe, g to refresh"
             (length entries))))

(global-set-key (kbd "C-c ?") #'ud/shortcuts-cheatsheet)

(provide 'cheatsheet)
;;; cheatsheet.el ends here
