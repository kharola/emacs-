;; Load the package manager
(require 'package)

;; Add the Melpa stable community repository
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Initialize the package manager
(package-initialize)
;; Load any changes to the package repository
(package-refresh-contents)

;; Install the use-package package
(package-install 'use-package)

;; Install and configure Cider
(use-package cider
  :ensure t
  :init
  ;; When using Homebrew on the macOS
  (setq cider-lein-command "/usr/local/bin/lein")
  ;; When following along with Project Trivia
  (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")
  :config
  (add-hook 'cider-repl-mode-hook #'eldoc-mode))



(use-package clj-refactor
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'clj-refactor-mode))

;; Install paredit, enable in elisp and Clojure modes
(use-package paredit
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  )

;; Install code completion and enable it globally
(use-package company
  :ensure t
  :bind (("C-c /". company-complete))
  :config
  (global-company-mode))

;; Install the Git frontend Magit
(use-package magit
  :ensure t)

(use-package which-key
  :ensure   t
  :config
  (which-key-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (clj-refactor cljr-refactor use-package paredit magit company cider))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
