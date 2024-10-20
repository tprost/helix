(defun helix-define-key (states scope key command)
  "Define key bindings for different STATES in the given SCOPE.
STATES should be a list of symbols representing states like 'normal or 'visual.
SCOPE should be either 'global or a specific keymap.normal
KEY is the key sequence to bind, and COMMAND is the function to call."
  (dolist (state (if (listp states) states (list states)))
    (let* ((map-symbol (intern (format "helix-%s-state-keymap" state)))
           (keymap (symbol-value map-symbol)))
      (define-key keymap key command))))

(helix-define-key '(normal visual) 'global (kbd "1") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "2") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "3") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "4") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "5") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "6") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "7") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "8") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "9") 'digit-argument)
(helix-define-key '(normal visual) 'global (kbd "0") 'digit-argument)

;; movement
(helix-define-key '(normal visual) 'global (kbd "k") 'previous-line)
(helix-define-key '(normal visual) 'global (kbd "j") 'next-line)
(helix-define-key '(normal visual) 'global (kbd "l") 'forward-char)
(helix-define-key '(normal visual) 'global (kbd "h") 'backward-char)

;; insert mode
(helix-define-key '(normal visual) 'global (kbd "i") 'helix-insert)
(helix-define-key '(normal visual) 'global (kbd "a") 'helix-append)
(helix-define-key 'insert 'global (kbd "ESC") 'helix-normal-mode)

;; word motions
(helix-define-key '(normal visual) 'global (kbd "e") 'helix-move-next-word-end)
(helix-define-key '(normal visual) 'global (kbd "E") 'helix-move-next-long-word-end)
(helix-define-key '(normal visual) 'global (kbd "b") 'helix-move-previous-word-start)
(helix-define-key '(normal visual) 'global (kbd "B") 'helix-move-previous-long-word-start)
(helix-define-key '(normal visual) 'global (kbd "w") 'helix-move-next-word-start)
(helix-define-key '(normal visual) 'global (kbd "W") 'helix-move-next-long-word-start)
(helix-define-key '(normal visual) 'global (kbd "C") 'helix-add-cursor-below)
(helix-define-key '(normal visual) 'global (kbd "x") 'helix-extend-line-below)
(helix-define-key '(normal visual) 'global (kbd "d") 'helix-delete-region-or-char)
(helix-define-key '(normal visual) 'global (kbd "p") 'yank)
(helix-define-key '(normal visual) 'global (kbd "y") 'helix-kill-ring-save)
(helix-define-key '(normal visual) 'global (kbd "u") 'undo)
(helix-define-key '(normal visual) 'global (kbd "U") 'redo)
;; (helix-define-key 'normal 'global (kbd "q")   'helix-toggle-kmacro-recording)
;; (helix-define-key 'normal 'global (kbd "Q")   'kmacro-call-macro)
(helix-define-key '(normal visual) 'global (kbd ";") 'helix-collapse-region)
(helix-define-key '(normal visual) 'global (kbd "f") 'helix-find-char)
(helix-define-key '(normal visual) 'global (kbd "c") 'helix-change)
(helix-define-key '(normal visual) 'global (kbd "o") 'helix-open-below)
(helix-define-key '(normal visual) 'global (kbd "O") 'helix-open-above)
(helix-define-key '(normal visual) 'global (kbd "G") 'goto-line)
(helix-define-key 'normal 'global (kbd "s") 'mc/mark-all-in-region-regexp)

(helix-define-key 'normal 'global (kbd "v") 'helix-visual-state)
(helix-define-key 'visual 'global (kbd "v") 'helix-normal-state)
(helix-define-key 'visual 'global (kbd "ESC") 'helix-normal-state)
;; (helix-define-key 'normal 'global (kbd "ESC") 'keyboard-quit)
;; (helix-define-key 'normal 'global (kbd "M-x") 'execute-extended-command)
(helix-define-key '(normal visual) 'global (kbd "%") 'mark-whole-buffer)

(define-prefix-command 'helix-goto-prefix-command)
(define-key 'helix-goto-prefix-command (kbd "g") 'beginning-of-buffer)
(define-key 'helix-goto-prefix-command (kbd "e") 'end-of-buffer)
(define-key 'helix-goto-prefix-command (kbd "s") 'beginning-of-line-text)
(define-key 'helix-goto-prefix-command (kbd "h") 'start-of-line)
(define-key 'helix-goto-prefix-command (kbd "l") 'end-of-line)
(define-key 'helix-goto-prefix-command (kbd "n") 'next-buffer)
(define-key 'helix-goto-prefix-command (kbd "p") 'previous-buffer)
(define-key 'helix-goto-prefix-command (kbd ".") 'goto-last-change)
(define-key 'helix-goto-prefix-command (kbd "y") 'lsp-goto-type-definition)
(define-key 'helix-goto-prefix-command (kbd "i") 'lsp-implementation)
(define-key 'helix-goto-prefix-command (kbd "d") 'lsp-find-definition)
(define-key 'helix-goto-prefix-command (kbd "r") 'lsp-find-references)
(helix-define-key (list 'normal 'visual) 'global (kbd "g") 'helix-goto-prefix-command)

(helix-define-key 'normal 'global (kbd "mm") 'helix-match-brackets)

;; (helix-set-leader '(normal visual) (kbd "SPC"))

(provide 'helix-keybindings)
