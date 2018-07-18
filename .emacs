;; Add top-level Emacs modules here
(add-to-list 'load-path "~/.elisp")

;; Pretty-print time in modeline
(autoload 'buffer-time-stamp "buffer-timestamp-mode"
   "Show buffer timestamps in modeline" t)

;; Set shell-mode editing properly
(add-to-list 'interpreter-mode-alist
	     '("ksh93" . shell-script-mode))

;; Set default shell for [ansi-]term mode
(setq explicit-shell-file-name "/bin/ksh")

;; Hooks and info for Git
(require 'git)
(require 'git-blame)

;; Hooks and info for Golang
;; (add-to-list 'load-path "/opt/go/misc/emacs/" t)
(require 'go-mode-load)
(add-hook 'go-mode-hook
  (lambda ()
    (setq-default)
    (setq tab-width 4)
    (setq standard-indent 4)
    (setq indent-tabs-mode nil)))

;; Hooks and info for C
(setq c-default-style "bsd"
	c-basic-offset 4)

;; Documentation module
(require 'doxymacs)
(add-hook 'c-mode-common-hook'doxymacs-mode)

;; Markdown support
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; Compile all the .elc files which have a corresponding newer .el file 
(byte-recompile-directory "~/.elisp")

;; Global customisations follow
(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)

(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq line-number-mode t)
(setq column-number-mode t)
(desktop-save-mode 1)
(setq desktop-restore-frames t)
