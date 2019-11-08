(setq user-full-name "Arjen Wiersma")
(setq user-mail-address "arjen@wiersma.org")

;;  (if (fboundp 'gnutls-available-p)
;;      (fmakunbound 'gnutls-available-p))

(require 'cl)
(setq tls-checktrust t)

(setq python (or (executable-find "py.exe")
                 (executable-find "python")
                 ))

(let ((trustfile
       (replace-regexp-in-string
        "\\\\" "/"
        (replace-regexp-in-string
         "\n" ""
         (shell-command-to-string (concat python " -m certifi"))))))
  (setq tls-program
        (list
         (format "gnutls-cli%s --x509cafile %s -p %%p %%h"
                 (if (eq window-system 'w32) ".exe" "") trustfile)))
  (setq gnutls-verify-error t)
  (setq gnutls-trustfiles (list trustfile)))

;; Test the settings by using the following code snippet:
;;  (let ((bad-hosts
;;         (loop for bad
;;               in `("https://wrong.host.badssl.com/"
;;                    "https://self-signed.badssl.com/")
;;               if (condition-case e
;;                      (url-retrieve
;;                       bad (lambda (retrieved) t))
;;                    (error nil))
;;               collect bad)))
;;    (if bad-hosts
;;        (error (format "tls misconfigured; retrieved %s ok" bad-hosts))
;;      (url-retrieve "https://badssl.com"
;;                    (lambda (retrieved) t))))

(require 'package)

(defvar gnu '("gnu" . "https://elpa.gnu.org/packages/"))
(defvar melpa '("melpa" . "https://melpa.org/packages/"))
(defvar melpa-stable '("melpa-stable" . "https://stable.melpa.org/packages/"))
(defvar org-elpa '("org" . "http://orgmode.org/elpa/"))

;; Add marmalade to package repos
(setq package-archives nil)
(add-to-list 'package-archives melpa-stable t)
(add-to-list 'package-archives melpa t)
(add-to-list 'package-archives gnu t)
(add-to-list 'package-archives org-elpa t)

(package-initialize)

(unless (and (file-exists-p (concat init-dir "elpa/archives/gnu"))
             (file-exists-p (concat init-dir "elpa/archives/melpa"))
             (file-exists-p (concat init-dir "elpa/archives/melpa-stable")))
  (package-refresh-contents))

(defun packages-install (&rest packages)
  (message "running packages-install")
  (mapc (lambda (package)
          (let ((name (car package))
                (repo (cdr package)))
            (when (not (package-installed-p name))
              (let ((package-archives (list repo)))
                (package-initialize)
                (package-install name)))))
        packages)
  (package-initialize)
  (delete-other-windows))

;; Install extensions if they're missing
(defun init--install-packages ()
  (message "Lets install some packages")
  (packages-install
   ;; Since use-package this is the only entry here
   ;; ALWAYS try to use use-package!
   (cons 'use-package melpa)
   ))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(use-package diminish
  :ensure t)

(fset 'yes-or-no-p 'y-or-n-p)

(use-package guru-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'guru-mode))

(use-package bm
  :ensure t
  :bind (("C-c =" . bm-toggle)
         ("C-c [" . bm-previous)
         ("C-c ]" . bm-next)))

(use-package counsel
  :ensure t
  :bind
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line)))

(use-package swiper
  :pin melpa-stable
  :diminish ivy-mode
  :ensure t
  :bind*
  (("C-s" . swiper)
   ("C-c C-r" . ivy-resume)
   ("C-x C-f" . counsel-find-file)
   ("C-c h f" . counsel-describe-function)
   ("C-c h v" . counsel-describe-variable)
   ("C-c i u" . counsel-unicode-char)
   ("M-i" . counsel-imenu)
   ("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c k" . counsel-ag)
   ;;      ("C-c l" . scounsel-locate)
   )
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (define-key read-expression-map (kbd "C-r") #'counsel-expression-history)
    (ivy-set-actions
     'counsel-find-file
     '(("d" (lambda (x) (delete-file (expand-file-name x)))
        "delete"
        )))
    (ivy-set-actions
     'ivy-switch-buffer
     '(("k"
        (lambda (x)
          (kill-buffer x)
          (ivy--reset-state ivy-last))
        "kill")
       ("j"
        ivy--switch-buffer-other-window-action
        "other window")))))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

(use-package ivy-hydra :ensure t)

(global-set-key (kbd "C-x k") 'kill-this-buffer)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

(use-package projectile
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'projectile-mode))

(custom-set-variables '(epg-gpg-program  "/usr/local/MacGPG2/bin/gpg2"))

(if (or
     (eq system-type 'darwin)
     (eq system-type 'berkeley-unix))
    (setq system-name (car (split-string system-name "\\."))))

(setenv "PATH" (concat "/Users/arjen/go/bin:/usr/local/bin:/usr/local/go/bin:" (getenv "PATH")))
(setenv "GOPATH" "/Users/arjen/go")
(push "/Users/arjen/go/bin" exec-path)
(push "/usr/local/bin" exec-path)
(push "/Users/arjen/go/bin/" exec-path)

;; /usr/libexec/java_home
;;(setenv "JAVA_HOME" "/Library/Java/JavaVirtualMachines/jdk1.8.0_05.jdk/Contents/Home")

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq mac-option-modifier 'none)
(setq mac-command-modifier 'meta)
(setq ns-function-modifier 'hyper)

;; Backup settings
(defvar --backup-directory (concat init-dir "backups"))

(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))

(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )
  (setq delete-by-moving-to-trash t
        trash-directory "~/.Trash/emacs")

  (setq backup-directory-alist `(("." . ,(expand-file-name
                                          (concat init-dir "backups")))))

(setq ns-pop-up-frames nil)

(defun spell-buffer-dutch ()
  (interactive)
  (ispell-change-dictionary "nederlands")
  (flyspell-buffer))

(defun spell-buffer-english ()
  (interactive)
  (ispell-change-dictionary "en_US")
  (flyspell-buffer))

(use-package ispell
  :config
  (when (executable-find "hunspell")
    (setq-default ispell-program-name "hunspell")
    (setq ispell-really-hunspell t))

  ;; (setq ispell-program-name "aspell"
  ;;       ispell-extra-args '("--sug-mode=ultra"))
  :bind (("C-c N" . spell-buffer-dutch)
         ("C-c e" . spell-buffer-english)))

;;; what-face to determine the face at the current point
(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "C-x o") 'ace-window))

(use-package ace-jump-mode
  :ensure t
  :config
  (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

(setq inhibit-startup-message t)
;;  (global-linum-mode)
(global-hl-line-mode +1)

(custom-set-faces
 '(line-number-current-line ((t (:inherit default :background "#282635")))))

(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key (kbd "C-c n") 'iwb)

(electric-pair-mode t)

(when (window-system)
  ;;(load "~/.emacs.d/arc-dark-theme/arc-dark-theme.el")
  (load-theme 'solarized-light t)
  )

(when (window-system)
  (set-default-font "Hack-14"))

(use-package command-log-mode
  :ensure t)

(defun live-coding ()
  (interactive)
  (set-face-attribute 'default nil :font "Hack-18")
  (add-hook 'prog-mode-hook 'command-log-mode)
  ;;(add-hook 'prog-mode-hook (lambda () (focus-mode 1)))
  )

(defun normal-coding ()
  (interactive)
  (set-face-attribute 'default nil :font "Hack-14")
  (add-hook 'prog-mode-hook 'command-log-mode)
  ;;(add-hook 'prog-mode-hook (lambda () (focus-mode 1)))
  )

(eval-after-load "org-indent" '(diminish 'org-indent-mode))

;;   (use-package all-the-icons
;;     :ensure t)

;; http://stackoverflow.com/questions/11679700/emacs-disable-beep-when-trying-to-move-beyond-the-end-of-the-document
(defun my-bell-function ())

(setq ring-bell-function 'my-bell-function)
(setq visible-bell nil)

(use-package request
  :ensure t)

;;(add-to-list 'load-path (expand-file-name (concat init-dir "ox-leanpub")))
;;(load-library "ox-leanpub")
(add-to-list 'load-path (expand-file-name (concat init-dir "ox-ghost")))
(load-library "ox-ghost")
;;; http://www.lakshminp.com/publishing-book-using-org-mode

;;(defun leanpub-export ()
;;  "Export buffer to a Leanpub book."
;;  (interactive)
;;  (if (file-exists-p "./Book.txt")
;;      (delete-file "./Book.txt"))
;;  (if (file-exists-p "./Sample.txt")
;;      (delete-file "./Sample.txt"))
;;  (org-map-entries
;;   (lambda ()
;;     (let* ((level (nth 1 (org-heading-components)))
;;            (tags (org-get-tags))
;;            (title (or (nth 4 (org-heading-components)) ""))
;;            (book-slug (org-entry-get (point) "TITLE"))
;;            (filename
;;             (or (org-entry-get (point) "EXPORT_FILE_NAME") (concat (replace-regexp-in-string " " "-" (downcase title)) ".md"))))
;;       (when (= level 1) ;; export only first level entries
;;         ;; add to Sample book if "sample" tag is found.
;;         (when (or (member "sample" tags)
;;                   ;;(string-prefix-p "frontmatter" filename) (string-prefix-p "mainmatter" filename)
;;                   )
;;           (append-to-file (concat filename "\n\n") nil "./Sample.txt"))
;;         (append-to-file (concat filename "\n\n") nil "./Book.txt")
;;         ;; set filename only if the property is missing
;;         (or (org-entry-get (point) "EXPORT_FILE_NAME")  (org-entry-put (point) "EXPORT_FILE_NAME" filename))
;;         (org-leanpub-export-to-markdown nil 1 nil)))) "-noexport")
;;  (org-save-all-org-buffers)
;;  nil
;;  nil)
;;
;;(require 'request)
;;
;;(defun leanpub-preview ()
;;  "Generate a preview of your book @ Leanpub."
;;  (interactive)
;;  (request
;;   "https://leanpub.com/clojure-on-the-server/preview.json" ;; or better yet, get the book slug from the buffer
;;   :type "POST"                                             ;; and construct the URL
;;   :data '(("api_key" . ""))
;;   :parser 'json-read
;;   :success (function*
;;             (lambda (&key data &allow-other-keys)
;;               (message "Preview generation queued at leanpub.com.")))))

(use-package langtool
  :ensure t
  :config (setq langtool-language-tool-server-jar (concat (getenv "HOME") "/.emacs.d/LanguageTool-4.4/languagetool-server.jar"))
  :bind (("\C-x4w" . langtool-check)
         ("\C-x4W" . langtool-check-done)
         ("\C-x4l" . langtool-switch-default-language)
         ("\C-x44" . langtool-show-message-at-point)
         ("\C-x4c" . langtool-correct-buffer)))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda ()
                   (flyspell-mode 1)
                   (visual-line-mode 1)
                   )))

(use-package markdown-mode
  :ensure t)

(use-package htmlize
  :ensure t)

(defun my/with-theme (theme fn &rest args)
  (let ((current-themes custom-enabled-themes))
    (mapcar #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (let ((result (apply fn args)))
      (mapcar #'disable-theme custom-enabled-themes)
      (mapcar (lambda (theme) (load-theme theme t)) current-themes)
      result)))

;; (advice-add #'org-export-to-file :around (apply-partially #'my/with-theme 'arjen-grey-theme))
;; (advice-add #'org-export-to-buffer :around (apply-partially #'my/with-theme 'arjen-grey-theme))

(use-package s
  :ensure t)

(use-package hydra
  :ensure t)

(use-package hideshow
  :ensure t
  :bind (("C->" . my-toggle-hideshow-all)
         ("C-<" . hs-hide-level)
         ("C-;" . hs-toggle-hiding))
  :config
  ;; Hide the comments too when you do a 'hs-hide-all'
  (setq hs-hide-comments nil)
  ;; Set whether isearch opens folded comments, code, or both
  ;; where x is code, comments, t (both), or nil (neither)
  (setq hs-isearch-open t)
  ;; Add more here


  (setq hs-set-up-overlay
        (defun my-display-code-line-counts (ov)
          (when (eq 'code (overlay-get ov 'hs))
            (overlay-put ov 'display
                         (propertize
                          (format " ... <%d>"
                                  (count-lines (overlay-start ov)
                                               (overlay-end ov)))
                          'face 'font-lock-type-face)))))

  (defvar my-hs-hide nil "Current state of hideshow for toggling all.")
       ;;;###autoload
  (defun my-toggle-hideshow-all () "Toggle hideshow all."
         (interactive)
         (setq my-hs-hide (not my-hs-hide))
         (if my-hs-hide
             (hs-hide-all)
           (hs-show-all)))

  (add-hook 'prog-mode-hook (lambda ()
                              (hs-minor-mode 1)
                              ))
  (add-hook 'clojure-mode-hook (lambda ()
                              (hs-minor-mode 1)
                              ))
  )

(global-prettify-symbols-mode 1)

(use-package paredit
  :ensure t
  :diminish paredit-mode
  :config
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
  :bind (("C-c d" . paredit-forward-down))
  )

;; Ensure paredit is used EVERYWHERE!
(use-package paredit-everywhere
  :ensure t
  :diminish paredit-everywhere-mode
  :config
  (add-hook 'list-mode-hook #'paredit-everywhere-mode))

(use-package highlight-parentheses
  :ensure t
  :diminish highlight-parentheses-mode
  :config
  (add-hook 'emacs-lisp-mode-hook
            (lambda()
              (highlight-parentheses-mode)
              )))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'lisp-mode-hook
            (lambda()
              (rainbow-delimiters-mode)
              )))

(global-highlight-parentheses-mode)

(use-package yasnippet
  :ensure t
  :diminish yas
  :config
  (yas/global-mode 1)
  (add-to-list 'yas-snippet-dirs (concat init-dir "snippets")))

(use-package clojure-snippets
  :ensure t)

(use-package company
  :ensure t
  :bind (("C-c /". company-complete))
  :config
  (global-company-mode)
  )

(use-package magit
  :ensure t
  :bind (("C-c m" . magit-status)))

(use-package magit-gitflow
  :ensure t
  :config
  (add-hook 'magit-mode-hook 'turn-on-magit-gitflow))

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode +1))

(use-package restclient
  :ensure t)

(use-package cider
    :ensure t
    :pin melpa-stable

    :config
    (add-hook 'cider-repl-mode-hook #'company-mode)
    (add-hook 'cider-mode-hook #'company-mode)
    (add-hook 'cider-mode-hook #'eldoc-mode)
;;    (add-hook 'cider-mode-hook #'cider-hydra-mode)
    (add-hook 'clojure-mode-hook #'paredit-mode)
    (setq cider-repl-use-pretty-printing t)
    (setq cider-repl-display-help-banner nil)
    ;;    (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")

    :bind (("M-r" . cider-namespace-refresh)
           ("C-c r" . cider-repl-reset)
           ("C-c ." . cider-reset-test-run-tests))
    )

  (use-package clj-refactor
    :ensure t
    :config
    (add-hook 'clojure-mode-hook (lambda ()
                                   (clj-refactor-mode 1)
                                   ;; insert keybinding setup here
                                   ))
    (cljr-add-keybindings-with-prefix "C-c C-m")
    (setq cljr-warn-on-eval nil)
    :bind ("C-c '" . hydra-cljr-help-menu/body)
    )

;;  (load-library (concat init-dir "cider-hydra.el"))
;;  (require 'cider-hydra)

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.xhtml?\\'" . web-mode))

  (defun my-web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-enable-auto-closing t)
    (setq web-mode-enable-auto-quoting t)
    (setq web-mode-markup-indent-offset 2))

  (add-hook 'web-mode-hook  'my-web-mode-hook))

(use-package less-css-mode
  :ensure t)

(use-package emmet-mode
  :ensure t
  :config
  (add-hook 'clojure-mode-hook 'emmet-mode))

(use-package racer
  :ensure t
  :config
  (add-hook 'racer-mode-hook #'company-mode)
  (setq company-tooltip-align-annotations t)
  (setq racer-rust-src-path "/home/arjen/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src"))

(use-package rust-mode
  :ensure t
  :config
  (add-hook 'rust-mode-hook #'racer-mode)
  (add-hook 'racer-mode-hook #'eldoc-mode)
  (setq rust-format-on-save t))

(use-package cargo
  :ensure t
  :config
  (setq compilation-scroll-output t)
  (add-hook 'rust-mode-hook 'cargo-minor-mode))

(use-package flycheck-rust
  :ensure t
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
  (add-hook 'rust-mode-hook 'flycheck-mode))

(use-package company-go
  :ensure t
  :config
  (setq company-tooltip-limit 20)                      ; bigger popup window
  (setq company-idle-delay .3)                         ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)                          ; remove annoying blinking
  (setq company-begin-commands '(self-insert-command)) ; start autocompletion only after typing
  (add-hook 'go-mode-hook (lambda ()
                            (set (make-local-variable 'company-backends) '(company-go))
                            (company-mode))))

(setq-default tab-width 4)

(use-package go-mode
  :ensure t
  :bind (("C-c t t" . go-test-current-test)
         ("C-c t p" . go-test-current-project)
         ("C-c t c" . go-test-current-coverage)
         ("C-c t f" . go-test-current-file))
  :config
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save))

(use-package go-guru
  :ensure t)

(use-package go-errcheck
  :ensure t)

;; Yasnippets
(use-package go-snippets
  :ensure t)

;; eldoc integration
(use-package go-eldoc
  :ensure t)

;; (use-package gocode
;;   :ensure t)

;; (use-package godef
;;   :ensure t)

(use-package gotest
  :ensure t)

(use-package flycheck-golangci-lint
  :ensure t
  :hook (go-mode . flycheck-golangci-lint-setup))

(use-package treemacs :ensure t)
(use-package lsp-mode :ensure t)
(use-package company-lsp :ensure t)
(use-package lsp-ui :ensure t)
(use-package java-snippets :ensure t)
(use-package lsp-java :ensure t :after lsp
  :config (add-hook 'java-mode-hook 'lsp))

(use-package dap-mode
  :ensure t :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package dap-java :after (lsp-java))
(use-package lsp-java-treemacs :after (treemacs))

(use-package dockerfile-mode
  :ensure t)

;; helper functions
(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(setq mac-right-alternate-modifier nil)

;; Customize EWW for dark background
(setq shr-color-visible-luminance-min 80)

(use-package html-to-hiccup
  :ensure t
  :config
  ;;(define-key clojure-mode-map (kbd "H-h") 'html-to-hiccup-convert-region)
  )

(defun fc-insert-date (prefix)
  "Insert the current date. With prefix-argument, use ISO format. With
two prefix arguments, write out the day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%Y-%m-%dT%H:%M:%S %Z")
                 ((equal prefix '(4)) "%d.%m.%Y")
                 (t "%A, %d. %B %Y")))
        (system-time-locale "nl_NL"))
    (insert (format-time-string format))))

;;  (use-package spaceline
;;    :ensure t
;;    :init
;;    (setq powerline-default-separator 'utf-8)
;;
;;    :config
;;    (require 'spaceline-config)
;;    (spaceline-spacemacs-theme)
;;    )

;; Reference: https://github.com/hlissner/.emacs.d/blob/master/core/core-modeline.el

(use-package f
  :ensure t)


(use-package moody
  :ensure t
  :config
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package minions
  :ensure t
  :config (minions-mode 1))

(use-package org
  :ensure t)

(setq org-catch-invisible-edits 'show-and-error)

(require 'org-habit)

(add-to-list 'org-modules 'org-habit)

(setq org-hide-emphasis-markers t)

(font-lock-add-keywords 'org-mode
                        '(("^ +\\([-*]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(setq org-link-frame-setup
      (quote
       ((vm . vm-visit-folder-other-frame)
        (vm-imap . vm-visit-imap-folder-other-frame)
        (gnus . org-gnus-no-new-news)
        (file . find-file)
        (wl . wl-other-frame))))


(when (window-system)
  (let* ((variable-tuple (cond ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                               ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                               ((x-list-fonts "Verdana")         '(:font "Verdana"))
                               ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                               (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

    (custom-theme-set-faces 'user
                            `(org-level-8 ((t (,@headline ,@variable-tuple))))
                            `(org-level-7 ((t (,@headline ,@variable-tuple))))
                            `(org-level-6 ((t (,@headline ,@variable-tuple))))
                            `(org-level-5 ((t (,@headline ,@variable-tuple))))
                            `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
                            `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
                            `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
                            `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
                            `(org-document-title ((t (,@headline ,@variable-tuple :height 1.5 :underline nil))))))
  )

(setq org-agenda-files '("~/Dropbox/Apps/MobileOrg/inbox.org"
                         "~/Dropbox/Apps/MobileOrg/notes.org"
                         "~/Dropbox/Apps/MobileOrg/gtd.org"
                         "~/Dropbox/Apps/MobileOrg/_Goals.org"
                         "~/Dropbox/Apps/MobileOrg/tickler.org"
                         "~/Dropbox/Apps/MobileOrg/gcal-NOVI.org"
                         "~/Dropbox/Apps/MobileOrg/gcal-Arjen.org"))

(setq org-capture-templates '(("t" "Todo [inbox]" entry
                               (file+headline "~/Dropbox/Apps/MobileOrg/inbox.org" "Tasks")
                               "* TODO %i%?")
                              ("T" "Tickler" entry
                               (file+headline "~/Dropbox/Apps/MobileOrg/tickler.org" "Tickler")
                               "* %i%? \n %U")
                              ("e" "email" entry (file+headline "~/Dropbox/Apps/MobileOrg/inbox.org" "Tasks from Email")
                               "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n%a\n")))

(setq org-refile-targets '(("~/Dropbox/Apps/MobileOrg/notes.org" :level . 2)
                           ("~/Dropbox/Apps/MobileOrg/tickler.org" :maxlevel . 2)))

(setq org-agenda-custom-commands
      '(("b" "Build fun things" tags-todo "@bft"
         ((org-agenda-overriding-header "BuildFunThings")
          (org-agenda-skip-function #'my-org-agenda-skip-all-siblings-but-first)))))

(defun my-org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry)
    (unless (org-current-is-todo)
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
        (when (org-current-is-todo)
          (setq should-skip-entry t))))
    (when should-skip-entry
      (or (outline-next-heading)
          (goto-char (point-max))))))

(defun org-current-is-todo ()
  (string= "TODO" (org-get-todo-state)))

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

(require 'ox-html)
(require 'ox-publish)


(use-package htmlize
  :ensure t)

(add-to-list 'load-path (expand-file-name (concat init-dir "ox-rss")))
(require 'ox-rss)

(setq org-mode-websrc-directory "~/Dropbox/Apps/MobileOrg/website")
(setq org-mode-publishing-directory "~/Dropbox/Apps/MobileOrg/website/_site")

(setq org-html-htmlize-output-type 'css)

(defun my-org-export-format-drawer (name content)
  (concat "<div class=\"drawer " (downcase name) "\">\n"
          "<h6>" (capitalize name) "</h6>\n"
          content
          "\n</div>"))
(setq org-html-format-drawer-function 'my-org-export-format-drawer)

(defun org-mode-blog-preamble (options)
  "The function that creates the preamble top section for the blog.
            OPTIONS contains the property list from the org-mode export."
  (let ((base-directory (plist-get options :base-directory)))
    (org-babel-with-temp-filebuffer (expand-file-name "top-bar.html" base-directory) (buffer-string))))

(defun org-mode-blog-postamble (options)
  "The function that creates the postamble, or bottom section for the blog.
            OPTIONS contains the property list from the org-mode export."
  (let ((base-directory (plist-get options :base-directory)))
    (org-babel-with-temp-filebuffer (expand-file-name "bottom.html" base-directory) (buffer-string))))

(defun org-mode-blog-prepare (options)
  "`index.org' should always be exported so touch the file before publishing."
  (let* (
         (buffer (find-file-noselect (expand-file-name "index.org" org-mode-websrc-directory) t)))
    (with-current-buffer buffer
      (set-buffer-modified-p t)
      (save-buffer 0))
    (kill-buffer buffer)))

;; Options: http://orgmode.org/manual/Publishing-options.html
(setq org-publish-project-alist
      `(("all"
         :components ("site-content" "site-rss" "site-static"))

        ("site-content"
         :base-directory ,org-mode-websrc-directory
         :base-extension "org"
         :publishing-directory ,org-mode-publishing-directory
         :recursive t
         :publishing-function org-html-publish-to-html
         :preparation-function org-mode-blog-prepare

         :html-head "<link rel=\"stylesheet\" href=\"/css/style.css\" type=\"text/css\" />
<link rel=\"stylesheet\" href=\"/css/all.min.css\" type=\"text/css\" />"

         :headline-levels      4
         :auto-preamble        t
         :auto-postamble       nil
         :auto-sitemap         t
         :sitemap-title        "Build Fun Things"
         :section-numbers      nil
         :table-of-contents    t
         :with-toc             nil
         :with-author          nil
         :with-creator         nil
         :with-tags            nil
         :with-smart-quotes    nil

         :html-doctype         "html5"
         :html-html5-fancy     t
         :html-preamble        org-mode-blog-preamble
         :html-postamble       org-mode-blog-postamble

         :html-head-include-default-style nil
         :html-head-include-scripts nil
         )

        ("site-rss"
         :base-directory ,org-mode-websrc-directory
         :base-extension "org"
         :publishing-directory ,org-mode-publishing-directory
         :recursive t
         :publishing-function (org-rss-publish-to-rss)
         :html-link-home "https://www.buildfunthings.com"
         :html-link-use-abs-url t
         :exclude ".*"
         :include ("feed.org")
         )
        ("site-static"
         :base-directory       ,org-mode-websrc-directory
         :base-extension       "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|ttf\\|woff\\|woff2\\|ico\\|webmanifest"
         :publishing-directory ,org-mode-publishing-directory
         :exclude "_site"
         :recursive            t
         :publishing-function  org-publish-attachment
         )
        ))

;; (use-package ox-reveal
;;   :ensure t
;;   :config
;;   (setq org-reveal-root "file:///home/arjen/Documents/BuildFunThings/Security/reveal.js-3.5.0/js/reveal.js"))

(use-package org-journal
  :ensure t
  :config (setq org-journal-dir "~/Dropbox/Apps/MobileOrg/journal"))

(setq mu4e-drafts-folder "/Personal/Drafts")
(setq mu4e-sent-folder   "/Personal/Sent Items")
(setq mu4e-trash-folder  "/Personal/Trash")

;; this is where the install procedure above puts your mu4e
(add-to-list 'load-path "/usr/local/Cellar/mu/1.0_1/share/emacs/site-lisp/mu/mu4e")

(require 'mu4e)

;; path to our Maildir directory
(setq mu4e-maildir "~/Maildir")

(setq mu4e-get-mail-command "mbsync -a")
(setq mu4e-view-show-images t)
(setq mu4e-html2text-command "w3m -dump -T text/html")

;; Prevent duplicate UIDs when moving files around
(setq mu4e-change-filenames-when-moving t)

;; This enables unicode chars to be used for things like flags in the message index screens.
;; I've disabled it because the font I am using doesn't support this very well. With this
;; disabled, regular ascii characters are used instead.
                                        ;(setq mu4e-use-fancy-chars t)
;; This enabled the thread like viewing of email similar to gmail's UI.
(setq mu4e-headers-include-related t)
(setq mu4e-attachment-dir  "~/Downloads")
;; This prevents saving the email to the Sent folder since gmail will do this for us on their end.
;;  (setq mu4e-sent-messages-behavior 'delete)
(setq message-kill-buffer-on-exit t)
(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))

;; Sometimes html email is just not readable in a text based client, this lets me open the
;; email in my browser.
(add-to-list 'mu4e-view-actions '("View in browser" . mu4e-action-view-in-browser) t)

;; Spell checking ftw.
(add-hook 'mu4e-compose-mode-hook 'flyspell-mode)

;; This hook correctly modifies the \Inbox and \Starred flags on email when they are marked.
;; Without it refiling (archiving) and flagging (starring) email won't properly result in
;; the corresponding gmail action.
(add-hook 'mu4e-mark-execute-pre-hook
          (lambda (mark msg)
            (cond ((member mark '(refile trash)) (mu4e-action-retag-message msg "-\\Inbox"))
                  ((equal mark 'flag) (mu4e-action-retag-message msg "\\Starred"))
                  ((equal mark 'unflag) (mu4e-action-retag-message msg "-\\Starred")))))



(defun my-make-mu4e-context (name address signature)
  "Return a mu4e context named NAME with :match-func matching
    its ADDRESS in From or CC fields of the parent message. The
    context's `user-mail-address' is set to ADDRESS and its
    `mu4e-compose-signature' to SIGNATURE."
  (lexical-let ((addr-lex address))
    (make-mu4e-context :name name
                       :vars `((user-mail-address . ,address)
                               (mu4e-compose-signature . ,signature))
                       :match-func
                       (lambda (msg)
                         (when msg
                           (or (mu4e-message-contact-field-matches msg :to addr-lex)
                               (mu4e-message-contact-field-matches msg :cc addr-lex)))))))

(setq mu4e-contexts
      `( ,(my-make-mu4e-context "fastmail" "arjen@wiersma.org"
                                "")
         ,(my-make-mu4e-context "gmail" "arjenw@gmail.com"
                                "A very professional signature.")))

;; This is a helper to help determine which account context I am in based
;; on the folder in my maildir the email (eg. ~/.mail/nine27) is located in.
(defun mu4e-message-maildir-matches (msg rx)
  (when rx
    (if (listp rx)
        ;; If rx is a list, try each one for a match
        (or (mu4e-message-maildir-matches msg (car rx))
            (mu4e-message-maildir-matches msg (cdr rx)))
      ;; Not a list, check rx
      (string-match rx (mu4e-message-field msg :maildir)))))

;; Choose account label to feed msmtp -a option based on From header
;; in Message buffer; This function must be added to
;; message-send-mail-hook for on-the-fly change of From address before
;; sending message since message-send-mail-hook is processed right
;; before sending message.
(defun choose-msmtp-account ()
  (if (message-mail-p)
      (save-excursion
        (let*
            ((from (save-restriction
                     (message-narrow-to-headers)
                     (message-fetch-field "from")))
             (account
              (cond
               ((string-match "arjen@wiersma.org" from) "fastmail")
               ((string-match "arjenw@gmail.com" from) "gmail"))))
          (setq message-sendmail-extra-arguments (list '"-a" account))))))

;; Configure sending mail.
(setq message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "/usr/local/bin/msmtp"
      user-full-name "Arjen Wiersma")

;; Use the correct account context when sending mail based on the from header.
(setq message-sendmail-envelope-from 'header)
(add-hook 'message-send-mail-hook 'choose-msmtp-account)

(require 'org-mu4e)

;;store link to message if in header view, not to header query
(setq org-mu4e-link-query-in-headers-mode nil)

(use-package moody
  :config
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package minions
  :config (minions-mode 1))
