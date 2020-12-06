;; ~/.emacs needs this at the beginning:
;; (let
;;     ((site-init-file "~/Projects/dotfiles/.emacs"))
;;   (message site-init-file)
;;   (if (file-readable-p site-init-file)
;;       (load site-init-file)
;;     (message "%s not readable!" site-init-file)))

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
