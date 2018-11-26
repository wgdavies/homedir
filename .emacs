;; Add top-level Emacs modules here
(add-to-list 'load-path "~/.elisp")

;; Emacs packages
(require 'package)
(package-initialize)

;; Finally biting the bullet and adding MELPA
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

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

;; Hooks for CLang
(require 'clang-format)
;; (setq exec-path (append exec-path '("/usr/local/bin/clang-format")))
;; (global-set-key [C-M-tab] 'clang-format-region)
;; 
;; (require 'clang-format)
(global-set-key (kbd "C-c i") 'clang-format-region)
(global-set-key (kbd "C-c u") 'clang-format-buffer)

(setq clang-format-style-option "llvm")

;; GNU Global Ctags support (from MELPA)
(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'asm-mode)
              (ggtags-mode 1))))

(define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
(define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
(define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
(define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
(define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
(define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)
(define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark)

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (company helm-gtags helm ggtags))))
;; (require 'setup-helm)
  (add-to-list 'exec-path "/usr/local/bin")
  (setq-local imenu-create-index-function #'ggtags-build-imenu-index)

  (setq
    helm-gtags-ignore-case t
    helm-gtags-auto-update t
    helm-gtags-use-input-at-cursor t
    helm-gtags-pulse-at-cursor t
    helm-gtags-prefix-key "\C-cg"
    helm-gtags-suggested-key-mapping t
  )

  (require 'helm-gtags)
 ;; Enable helm-gtags-mode
  (add-hook 'dired-mode-hook 'helm-gtags-mode)
  (add-hook 'eshell-mode-hook 'helm-gtags-mode)
  (add-hook 'c-mode-hook 'helm-gtags-mode)
  (add-hook 'c++-mode-hook 'helm-gtags-mode)
  (add-hook 'asm-mode-hook 'helm-gtags-mode)

  (define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
  (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-select)
  (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
  (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
  (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
  (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(global-hl-line-mode t)
