(require 'helix-vars)
(require 'helix-core)
(require 'helix-helpers)

(helix-define-state normal
  "Helix NORMAL state minor mode."
  :lighter " [N]"
  :face helix-normal-cursor)

(helix-define-state insert
  "Helix INSERT state minor mode."
  :lighter " [I]"
  :face helix-insert-cursor
  ;; (if helix-insert-mode
  ;;     (run-hooks 'helix-insert-enter-hook)
  ;;   (when (and helix--insert-pos
  ;;              (or helix-select-on-change
  ;;                  helix-select-on-append
  ;;                  helix-select-on-insert)
  ;;              (not (= (point) helix--insert-pos)))
  ;;     (thread-first
  ;;       (helix--make-selection '(select . transient) helix--insert-pos (point))
  ;;       (helix--select)))
  ;;   (run-hooks 'helix-insert-exit-hook)
  ;;   (setq-local helix--insert-pos nil))
  )



(helix-define-state view
  "Helix VIEW state minor mode."
  :lighter " [V]"
  :face helix-view-cursor)

(provide 'helix-states)
