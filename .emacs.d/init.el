;; init.el --- Emacs configuration

;; Set OSX function key as Meta


;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)
(add-to-list 'package-archives                                                                                                        
             '("elpy" . "http://jorgenschaefer.github.io/packages/"))   
(add-to-list 'package-archives
       '("melpa" . "https://melpa.org/packages/") t)

;; activate all packages
(package-initialize)

;; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

;; define list of packages to install
(defvar myPackages
  '(better-defaults
   ;; material-theme
    exec-path-from-shell
    elpy
    pyenv-mode))

;; install all packages in list
(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

;; Use shell's $PATH
(exec-path-from-shell-copy-env "PATH")

;; init.el ends here


;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t)   ;; hide the startup message
;;(load-theme 'material t)           ;; load material theme
(global-linum-mode t)              ;; enable line numbers globally
(setq linum-format "%4d \u2502 ")  ;; format line number spacing
;; Allow hash to be entered  
(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))



;; define list of packages to install
(defvar myPackages
  '(better-defaults
    material-theme
    elpy))


(elpy-enable)
(pyenv-mode)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#ffffff" "#f36c60" "#8bc34a" "#fff59d" "#4dd0e1" "#b39ddb" "#81d4fa" "#262626"))
 '(beacon-color "#cc6666")
 '(custom-safe-themes
   (quote
    ("a2cde79e4cc8dc9a03e7d9a42fabf8928720d420034b66aecc5b665bbf05d4e9" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "5e3fc08bcadce4c6785fc49be686a4a82a356db569f55d411258984e952f194a" "04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "a24c5b3c12d147da6cef80938dca1223b7c7f70f2f382b26308eba014dc4833a" "732b807b0543855541743429c9979ebfb363e27ec91e82f463c91e68c772f6e3" "a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "ab04c00a7e48ad784b52f34aa6bfa1e80d0c3fcacc50e1189af3651013eb0d58" "7356632cebc6a11a87bc5fcffaa49bae528026a78637acd03cae57c091afd9b9" "7153b82e50b6f7452b4519097f880d968a6eaf6f6ef38cc45a144958e553fbc6" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "332fcf3c7208aca9fab65d54203f78a242482e7fd65f5725a2482c20b1730732" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" default)))
 '(diary-entry-marker (quote font-lock-variable-name-face))
 '(emms-mode-line-icon-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *note[] = {
/* width height num_colors chars_per_pixel */
\"    10   11        2            1\",
/* colors */
\". c #358d8d\",
\"# c None s None\",
/* pixels */
\"###...####\",
\"###.#...##\",
\"###.###...\",
\"###.#####.\",
\"###.#####.\",
\"#...#####.\",
\"....#####.\",
\"#..######.\",
\"#######...\",
\"######....\",
\"#######..#\" };")))
 '(fci-rule-color "#3a3a3a")
 '(flycheck-color-mode-line-face-to-color (quote mode-line-buffer-id))
 '(frame-background-mode (quote dark))
 '(gnus-logo-colors (quote ("#0d7b72" "#adadad")))
 '(gnus-mode-line-image-cache
   (quote
    (image :type xpm :ascent center :data "/* XPM */
static char *gnus-pointer[] = {
/* width height num_colors chars_per_pixel */
\"    18    13        2            1\",
/* colors */
\". c #358d8d\",
\"# c None s None\",
/* pixels */
\"##################\",
\"######..##..######\",
\"#####........#####\",
\"#.##.##..##...####\",
\"#...####.###...##.\",
\"#..###.######.....\",
\"#####.########...#\",
\"###########.######\",
\"####.###.#..######\",
\"######..###.######\",
\"###....####.######\",
\"###..######.######\",
\"###########.######\" };")))
 '(hl-sexp-background-color "#121212")
 '(package-selected-packages
   (quote
    (auto-complete js2-mode alect-themes dracula-theme color-theme-sanityinc-tomorrow pyenv-mode elpy exec-path-from-shell material-theme better-defaults which-key web-mode use-package restclient rainbow-delimiters racer paredit-everywhere org-journal moody minions magit-gitflow lsp-ui lsp-java langtool java-snippets ivy-hydra htmlize html-to-hiccup highlight-parentheses guru-mode gotest go-snippets go-guru go-errcheck go-eldoc git-gutter flycheck-rust flycheck-golangci-lint emmet-mode dockerfile-mode diminish dap-mode counsel-projectile company-lsp company-go command-log-mode clojure-snippets clj-refactor cargo bm ace-jump-mode)))
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#f36c60")
     (40 . "#ff9800")
     (60 . "#fff59d")
     (80 . "#8bc34a")
     (100 . "#81d4fa")
     (120 . "#4dd0e1")
     (140 . "#b39ddb")
     (160 . "#f36c60")
     (180 . "#ff9800")
     (200 . "#fff59d")
     (220 . "#8bc34a")
     (240 . "#81d4fa")
     (260 . "#4dd0e1")
     (280 . "#b39ddb")
     (300 . "#f36c60")
     (320 . "#ff9800")
     (340 . "#fff59d")
     (360 . "#8bc34a"))))
 '(vc-annotate-very-old-color nil)
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
