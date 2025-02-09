;; ~/.emacs needs this at the beginning:
;; (let
;;     ((shared-dot-emacs-file "<wherever-this-file-is>/.emacs"))
;;   (message shared-dot-emacs-file)
;;   (if (file-readable-p shared-dot-emacs-file)
;;       (load shared-dot-emacs-file)
;;     (message "%s not readable!" shared-dot-emacs-file)))

(package-initialize)

(defun paranoid-exit-from-emacs ()
  (interactive)
  (if (yes-or-no-p "Do you want to exit? ")
      (save-buffers-kill-emacs)))

(fset 'yes-or-no-p 'y-or-n-p)

;; http://www.delorie.com/gnu/docs/emacs-lisp-intro/emacs-lisp-intro_208.html
(defun count-words-region (beginning end)
  "Print number of words in the region."
  (interactive "r")
  (message "Counting words in region ... ")
  (save-excursion
    (let ((count 0))
      (goto-char beginning)
      (while (and (< (point) end)
                  (re-search-forward "\\w+\\W*" end t))
        (setq count (1+ count)))
      (cond ((zerop count)
             (message
              "The region does NOT have any words."))
            ((= 1 count)
             (message
              "The region has 1 word."))
            (t
             (message
              "The region has %d words." count))))))

(defun delete-leading-whitespace ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (delete-horizontal-space)))

(defun python-pep-8 ()
  (add-hook 'python-mode-hook
	    (function (lambda ()
			(setq indent-tabs-mode nil
			      tab-width 4)))))

(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single
    logical line.  This is useful, e.g., for use with
    `visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

(defun uniquify-all-lines-region (start end)
  "Find duplicate lines in region START to END keeping first occurrence."
  (interactive "*r")
  (save-excursion
    (let ((end (copy-marker end)))
      (while
	  (progn
	    (goto-char start)
	    (re-search-forward "^\\(.*\\)\n\\(\\(.*\n\\)*\\)\\1\n" end t))
	(replace-match "\\1\n\\2")))))

;; https://stackoverflow.com/a/6174107
(defun shuffle-lines (beg end)
  "Shuffle lines in region."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (let ;; To make `end-of-line' and etc. to ignore fields.
          ((inhibit-field-text-motion t))
        (sort-subr nil 'forward-line 'end-of-line nil nil
                   (lambda (s1 s2) (eq (random 2) 0)))))))

(defun load-guadvorak ()
  (interactive) 
  (defvar dvorak-prefix "\C-q" "Some backward compatibility fixes. ")
  (defvar dvorak-keymap nil "Dvorak keymap. ")
  
  (define-prefix-command 'dvorak-prefix-command 'dvorak-keymap )
  (global-set-key dvorak-prefix 'dvorak-prefix-command)
  
  (global-set-key "\M-q" 'execute-extended-command)

  ;(global-unset-key "\C-o")
  (global-set-key "\C-x\C-c" 'paranoid-exit-from-emacs)
  (global-set-key "\C-q\C-j" 'paranoid-exit-from-emacs)
  (global-set-key "\C-q\C-o" 'save-buffer)
  (global-set-key "\C-q\C-u" 'find-file)
  
  ;; Editing 101
  (global-unset-key "\C-h")
  (global-set-key "\C-h" 'delete-backward-char)
  (global-unset-key "\C-w")
  (global-set-key "\C-w" 'backward-kill-word)
  
  ;; Copy & paste
  (global-set-key "\C-q\C-q" 'kill-region)
  (global-set-key "\C-q\C-i" 'kill-ring-save)

  ; Compile
  (global-set-key "\C-cc" 'compile)

  ; Fill paragraph
  (global-set-key "\C-cf" 'fill-paragraph))

(defun setup-mac-keyboard ()
  (setq mac-right-option-modifier 'none) ; disable right alt handling by emacs (alt gr keys)

  ;; swap left option and cmd, disable left option
  (setq mac-option-key-is-meta nil)
  (setq mac-command-key-is-meta t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier nil))

(defun fix-macports-gnutls ()
  (require 'gnutls)
  (add-to-list 'gnutls-trustfiles "/opt/local/etc/openssl/cert.pem")
  (setq tls-program '("/opt/local/bin/gnutls-cli --x509cafile %t -p %p %h" "gnutls-cli --x509cafile %t -p %p %h --protocols ssl3")))

;; Rid of ugly backups
(setq make-backup-files t)
(setq version-control t)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

;; UI defaults
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(show-paren-mode t)

;; Common aliases
(defalias 'eb 'eval-buffer)
(defalias 'rrx 'replace-regexp)
(defalias 'ir 'indent-region)
(defalias 'ee 'eval-expression)

;; Load libraries from ~/.emacs.d
(unless (boundp 'user-emacs-directory)
  (defvar user-emacs-directory "~/.emacs.d/"
    "Directory beneath which additional per-user Emacs-specific files are placed. Various programs in Emacs store information in this directory. Note that this should end with a directory separator. See also ‘locate-user-emacs-file’."))

(add-to-list 'load-path "~/.emacs.d/lisp")

;; Load defaults & personal, non-site stuff
(customize-set-variable 'fill-column 78)
(customize-set-variable 'ido-mode "both")
(set-keyboard-coding-system 'mule-utf-8)
(load-guadvorak)
(python-pep-8)

(let
    ((site-init-file "~/.emacs.d/lisp/site-init.el"))
  (message site-init-file)
  (if (file-readable-p site-init-file)
    (progn
      (load-file site-init-file)
      (if (fboundp 'site-init)
	  (site-init)
	(message "site-init function not bound!")))
    (message "%s not readable!" site-init-file)))
