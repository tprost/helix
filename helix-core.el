;;; helix-core.el --- Mode definitions for Helix  -*- lexical-binding: t; -*-

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Modes definition in Helix.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(require 'helix-util)
;; (require 'helix-command)
;; (require 'helix-keypad)
;; (require 'helix-var)
;; (require 'helix-esc)
;; (require 'helix-shims)
;; (require 'helix-beacon)
(require 'helix-helpers)


;;;###autoload
(define-minor-mode helix-mode
  "Helix minor mode.
This minor mode is used by helix-global-mode, should not be enabled directly."
  :init-value nil
  :interactive nil
  :global nil
  ;; :keymap helix-keymap
  (if helix-mode
      (helix--enable)
    (helix--disable)))

;;;###autoload
(defun helix-indicator ()
  "Indicator showing current mode."
  (or helix--indicator (helix--update-indicator)))

;;;###autoload
(define-global-minor-mode helix-global-mode helix-mode
  (lambda ()
    (unless (minibufferp)
      (helix-mode 1)))
  :group 'helix
  (if helix-mode
      (helix--global-enable)
    (helix--global-disable)))

(defun helix--enable ()
  "Enable Helix.

This function will switch to the proper state for current major
mode. Firstly, the variable `helix-mode-state-list' will be used.
If current major mode derived from any mode from the list,
specified state will be used.  When no result is found, give a
test on the commands bound to the keys a-z. If any of the command
names contains \"self-insert\", then NORMAL state will be used.
Otherwise, VIEW state will be used.
"
  (let ((state (helix--mode-get-state))
        (motion (lambda ()
                  (helix--disable-current-state)
                  (helix--save-origin-commands)
                  (helix-motion-mode 1)))

	)
    (cond
     ;; ;; if MOTION is specified
     ;; ((eq state 'motion)
     ;;  (funcall motion))

     (state
      (helix--disable-current-state)
      (helix--switch-state state t))

     (t (funcall motion))


     )))

(defun helix--disable ()
  "Disable Helix."
  (mapc (lambda (state-mode) (funcall (cdr state-mode) -1)) helix-state-mode-alist)
  ;; (helix--beacon-remove-overlays)
  (when (secondary-selection-exist-p)
    (helix--cancel-second-selection)))

(defun helix--enable-theme-advice (theme)
  "Prepare face if the theme to enable is `user'."
  (when (eq theme 'user)
    (helix--prepare-face)))

(defun helix--minibuffer-setup ()
  (local-set-key (kbd "<escape>") #'helix-minibuffer-quit)
  (setq-local helix-normal-mode nil)
  (when (or (member this-command helix-grab-fill-commands)
            (member helix--keypad-this-command helix-grab-fill-commands))
    (when-let* ((s (helix--second-sel-get-string)))
      (helix--insert s))))

(defun helix--global-enable ()
  "Enable helix globally."
  (setq-default helix-normal-mode t)
  (helix--init-buffers)
  (add-hook 'window-state-change-functions #'helix--on-window-state-change)
  (add-hook 'minibuffer-setup-hook #'helix--minibuffer-setup)
  (add-hook 'pre-command-hook 'helix--highlight-pre-command)
  ;; (add-hook 'post-command-hook 'helix--maybe-toggle-beacon-state)
  (add-hook 'suspend-hook 'helix--on-exit)
  (add-hook 'suspend-resume-hook 'helix--update-cursor)
  (add-hook 'kill-emacs-hook 'helix--on-exit)
  (add-hook 'desktop-after-read-hook 'helix--init-buffers)

  ;; (helix--enable-shims)
  ;; helix-esc-mode fix ESC in TUI
  ;; (helix-esc-mode 1)
  ;; raise Helix keymap priority
  ;; (add-to-ordered-list 'emulation-mode-map-alists
  ;;                     `((helix-motion-mode . ,helix-motion-state-keymap)))
  (add-to-ordered-list 'emulation-mode-map-alists
                      `((helix-normal-mode . ,helix-normal-state-keymap)))
  ;; (add-to-ordered-list 'emulation-mode-map-alists
  ;;                     `((helix-keypad-mode . ,helix-keypad-state-keymap)))
  ;; (add-to-ordered-list 'emulation-mode-map-alists
  ;;                     `((helix-beacon-mode . ,helix-beacon-state-keymap)))
  (when helix-use-cursor-position-hack
    (setq redisplay-highlight-region-function #'helix--redisplay-highlight-region-function)
    (setq redisplay-unhighlight-region-function #'helix--redisplay-unhighlight-region-function))
  (helix--prepare-face)
  (advice-add 'enable-theme :after 'helix--enable-theme-advice)


  )

(defun helix--global-disable ()
  "Disable Helix globally."
  (setq-default helix-normal-mode nil)
  (remove-hook 'window-state-change-functions #'helix--on-window-state-change)
  (remove-hook 'minibuffer-setup-hook #'helix--minibuffer-setup)
  (remove-hook 'pre-command-hook 'helix--highlight-pre-command)
  ;; (remove-hook 'post-command-hook 'helix--maybe-toggle-beacon-state)
  (remove-hook 'suspend-hook 'helix--on-exit)
  (remove-hook 'suspend-resume-hook 'helix--update-cursor)
  (remove-hook 'kill-emacs-hook 'helix--on-exit)
  (remove-hook 'desktop-after-read-hook 'helix--init-buffers)
  ;; (helix--disable-shims)
  (helix--remove-modeline-indicator)
  (when helix-use-cursor-position-hack
    (setq redisplay-highlight-region-function helix--backup-redisplay-highlight-region-function)
    (setq redisplay-unhighlight-region-function helix--backup-redisplay-unhighlight-region-function))
  ;; (helix-esc-mode -1)
  (advice-remove 'enable-theme 'helix--enable-theme-advice))

(provide 'helix-core)
;;; helix-core.el ends here
