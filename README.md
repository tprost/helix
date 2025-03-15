Emulating [Helix Editor](https://docs.helix-editor.com) by forking `meow-mode` and Frankenstein combinining it with `surround`, `multiple-cursors`, `expand-region` and a few snippets of `evil-mode`.

# Installation

```elisp
(use-package surround)
(use-package multiple-cursors)
(use-package expand-region)
(use-package helix
  :straight (helix :type git :host github :repo "tprost/helix"))
(require 'helix)
(global-helix-mode 1)
```
