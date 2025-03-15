(require 'surround)


;;;###autoload
(defun helix-surround-add (char)
  "Surrounds region or current symbol with a pair defined by CHAR."
  (interactive
   (list (char-to-string (read-char "character: "))))
  (surround-insert char)
  (setq deactivate-mark nil))

;;;###autoload
(defun helix-surround-delete (char)
  "Surrounds region or current symbol with a pair defined by CHAR."
  (interactive
   (list (char-to-string (read-char "character: "))))
  (surround-delete char)
  (setq deactivate-mark nil))

;;;###autoload
(defun helix-surround-replace (char-from char-to)
  (interactive
   (list (read-char "Character from: ")
         (read-char "Character to: ")))
  (surround-delete (char-to-string char-from))
  (surround-insert (char-to-string char-to))  
  (setq deactivate-mark nil))

(provide 'helix-match)


