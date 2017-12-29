(add-to-list 'load-path "~/.elisp")
(autoload 'buffer-time-stamp "buffer-timestamp-mode"
   "Show buffer timestamps in modeline" t)
(add-to-list 'interpreter-mode-alist
	     '("ksh93" . shell-script-mode))
(add-to-list 'load-path "/opt/go/misc/emacs/" t)
(require 'go-mode-load)
(add-hook 'go-mode-hook
  (lambda ()
    (setq-default)
    (setq tab-width 4)
    (setq standard-indent 4)
    (setq indent-tabs-mode nil)))

(setq c-default-style "bsd"
	c-basic-offset 4)

(require 'doxymacs)
(add-hook 'c-mode-common-hook'doxymacs-mode)

(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)

(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq line-number-mode t)
(setq column-number-mode t)
(desktop-save-mode 1)
(setq desktop-restore-frames t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(ps-paper-type (quote letter))
 '(ps-print-footer nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
