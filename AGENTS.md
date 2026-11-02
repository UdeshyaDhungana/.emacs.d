# Notes for LLM agents working on this Emacs setup

Written 2026-10-10 on macOS 26 (Darwin 27), Apple Silicon, Emacs 31.1.
Read this before changing `init.el` or reproducing the setup elsewhere.
These are the things that cost time to discover — not a full inventory.

---

## 0. The one that will bite you: `custom-file`

`init.el` sets `custom-file` to `custom.el`. **Do not remove this.**

If `custom-file` is unset it defaults to `init.el`. Every `package-install`
calls `customize-save-variable` on `package-selected-packages`, which runs
`custom-save-all` → `find-file-noselect custom-file` → `save-buffer`. If a
*stale* `init.el` buffer is already open in the daemon, that save writes the
stale contents back, **silently reverting any edit made to the file since the
buffer was loaded**. This destroyed two edits in one session before it was
diagnosed: each one looked successful, verified green, then reverted the
moment the next package installed.

If you edit `init.el` from outside Emacs while a daemon is running:

```sh
emacsclient -e '(let ((b (get-file-buffer (expand-file-name "~/.emacs.d/init.el")))) (when b (kill-buffer b)))'
```

...then edit, then reload. Always read the file back after writing it.

## 1. Native compilation is broken on this machine — two separate switches

Emacs.app (emacsformacosx) is built `--with-native-comp` and bundles
`libgccjit`, but **not** the gcc driver binary libgccjit shells out to. Any
compile fails with:

```
clang: error: invalid version number in '-mmacosx-version-min=18.0'
libgccjit.so: error: error invoking gcc driver
```

Two independent variables must both be nil:

| variable | what it covers | how it fails |
|---|---|---|
| `native-comp-jit-compilation` | compiling `.el` on load | warning spam at startup |
| `native-comp-enable-subr-trampolines` | shim built when a package **advises a primitive** | **runtime** failure inside the package, long after load |

The second one is the subtle one. `markdown-preview-mode` advises
`make-network-process`; with trampolines enabled its HTTP server silently
never starts and the browser just says "unable to connect". Nothing appears
at load time. If a package mysteriously half-works, suspect this.

To actually *fix* rather than disable: `brew install gcc libgccjit` and flip
both back to `t`. Not attempted here.

## 2. Two Emacs installs coexist on purpose

- `/opt/homebrew/bin/emacs` — Homebrew formula, **terminal only**, no `NS` in
  `system-configuration-features`.
- `/Applications/Emacs.app` — `brew install --cask emacs-app`, the GUI build.

The cask skips its binary symlinks because the formula owns them; that is
fine and expected. **Cmd-key remapping only works in the GUI build** — a
terminal swallows Cmd before Emacs sees it, and no elisp can change that.

## 3. macOS modifier keys

Current: both Command keys → `meta`, both Option keys → `super`.

```elisp
(setq ns-command-modifier 'meta  ns-right-command-modifier 'meta
      ns-option-modifier  'super ns-right-option-modifier  'super)
```

These are read **when a frame is created**. Reloading `init.el` affects only
*new* frames — `C-x 5 2` to test, don't restart the daemon for it.

Consequence the user has accepted: no Cmd shortcut reaches macOS inside
Emacs (no Cmd-C/V/Q/W), and Option no longer composes accented characters.
`ns-right-option-modifier 'none` would give accent typing back.

## 4. The daemon

`~/Library/LaunchAgents/gnu.emacs.daemon.plist` runs
`/Applications/Emacs.app/Contents/MacOS/Emacs --fg-daemon` with `KeepAlive`.

**The socket path is pinned** to `~/.emacs.d/server/server` via
`server-socket-dir` + the `EMACS_SOCKET_NAME` export in `~/.zshrc`. This is
not decoration: launchd and an interactive shell can resolve different
`$TMPDIR`s, which is the usual cause of "emacsclient can't find the socket".
Keep both sides in agreement if you move it.

Shell helpers live in `~/.zshrc`: `e`, `et`, `ew`, `ev`, `emacs-daemon`.

**Prefer reloading over restarting.** `launchctl kickstart -k` kills every
client frame and loses the user's windows:

```sh
emacsclient -e '(load-file "~/.emacs.d/init.el")'
```

**Do not "fix" `C-x C-c`.** It does *not* kill the daemon. Frames from
`emacsclient -n` carry `client = nowait`, and `server-save-buffers-kill-terminal`
only calls `save-buffers-kill-emacs` when it is the last frame standing —
which never happens, because the daemon holds an invisible initial frame.
Verified empirically. Rebinding it is a fix for a non-problem.

## 5. Dock launcher

`~/Applications/Emacs Client.app` is a hand-built bundle whose executable is
a zsh script running `emacsclient -n -c -a ""` plus an `osascript ... activate`
(a launchd-spawned daemon does not reliably raise itself). `LSUIElement` is
true so it does not leave a second Dock icon. Icon came from a webp via
`sips` → iconset → `iconutil`.

## 6. Markdown

- Emacs 31 **does bundle `markdown-ts-mode`** (mode-line lighter: "Markdown",
  which is misleading), but nothing registers it in `auto-mode-alist`, it has
  no autoload cookies, and it needs tree-sitter grammars that are not
  installed. `.md` in `emacs -Q` is **fundamental-mode**. `markdown-mode` from
  MELPA is genuinely required.
- **`markdown-live-preview-mode` saves the user's file.** `markdown-export`
  ends with `(when (buffer-modified-p init-buf) (erase-buffer) (insert …)
  (save-buffer) …)`. Never drive it from a timer — that is an autosave, and it
  churns undo history. This is why the as-you-type preview uses
  `markdown-preview-mode` (websocket → browser) instead.
- Its preview page pulls jQuery + CSS from CDNs; offline it renders unstyled.

## 7. Other small ones

- **dired**: BSD `ls` has no `--dired`. `dired-use-ls-dired` is nil, with a
  branch that prefers `gls` if coreutils ever gets installed.
- **org-roam**: vault at `~/Documents/org-roam` (plain convention, nothing
  requires `~/org`). Emacs 31 has `SQLITE3` built in, so no `emacsql-sqlite`
  compilation is needed. After moving files on disk, `M-x org-roam-db-sync`.
- **Homebrew `brew uninstall` can autoremove unrelated formulae.** Removing
  `minimal-racket` here also took `llvm@21` + `lld@21` (1.5 GB) as "unneeded".
  Check the full output, don't `tail` it.
- **A stale cask checksum is not necessarily tampering.** `brew install --cask
  racket` failed on SHA mismatch because upstream rebuilt the 9.3 installer.
  The correct move is to verify against the vendor's published checksum
  (racket-lang.org lists SHA256 per installer) and install from the verified
  download — not to force Homebrew past the check.

## 8. Reproducing on a fresh machine

```sh
brew install --cask emacs-app          # GUI build (Cmd remapping needs NS)
brew install emacs pandoc              # terminal emacs + markdown rendering
# optional: brew install --cask racket ; raco pkg install --auto sicp
```

Then copy `init.el`, `custom.el`, `AGENTS.md`, the LaunchAgent plist, the
`~/.zshrc` emacs block, and `~/Documents/org-roam`. Packages self-install via
`use-package-always-ensure` on first start. Load the agent with
`launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/gnu.emacs.daemon.plist`.

## 9. Working style the user expects

- Explain the mechanism, don't just patch. They ask "why" and check.
- Keep `init.el` small. They pushed back on a 60-line hand-rolled minor mode
  and asked for a package; use `use-package`, one block per package, with a
  short comment saying what the keys are and why any non-default is set.
- Verify claims by evaluating in the running daemon (`emacsclient -e`) rather
  than asserting. They will notice.
- **At most one config-file backup, ever.** The user does not want `.bak` /
  `.prev` snapshots of `init.el`, `custom.el`, or anything under `lisp/`
  accumulating; a pile of `init.el.prev6`..`prev12` got cleaned out on
  2026-11-02. If you need a pre-edit snapshot, write it to `init.el.bak`
  (one canonical slot per config file) so the next edit overwrites it --
  never a new suffix per change. Prefer no snapshot at all for small edits.
  This is about hand-made copies, not Emacs's own `backups/` directory,
  which is already one-per-file and must be left alone: 25 of its entries
  are the only recovery copies for `~/Documents/org-roam` notes.
- **`ud/` is the interactive namespace.** The prefix exists so `M-x ud/TAB`
  lists the user's own commands. Only `(interactive)` functions get it.
  Helpers -- including ones that serve a single command, and major modes or
  keymaps reachable only from their own buffer -- take their file's namespace
  with `--` for internals: `cheatsheet--symbols` in `lisp/cheatsheet.el`.
  Needing a filter to hide helpers from `M-x` or from `C-c ?` means they were
  misnamed.
