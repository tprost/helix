(require 'rect)
(require 'thingatpt)
(require 'cl-lib)

(defun helix-forward-chars (chars &optional count)
  "Move point to the end or beginning of a sequence of CHARS.
CHARS is a character set as inside [...] in a regular expression."
  (let ((notchars (if (= (aref chars 0) ?^)
                      (substring chars 1)
                    (concat "^" chars))))
    (helix-motion-loop (dir (or count 1))
      (cond
       ((< dir 0)
        (skip-chars-backward notchars)
        (skip-chars-backward chars))
       (t
        (skip-chars-forward notchars)
        (skip-chars-forward chars))))))

(defmacro helix-motion-loop (spec &rest body)
  "Loop a certain number of times.
Evaluate BODY repeatedly COUNT times with VAR bound to 1 or -1,
depending on the sign of COUNT. Set RESULT, if specified, to the
number of unsuccessful iterations, which is 0 if the loop completes
successfully. This is also the return value.

Each iteration must move point; if point does not change, the loop
immediately quits.

\(fn (VAR COUNT [RESULT]) BODY...)"
  (declare (indent defun)
           (debug ((symbolp form &optional symbolp) body)))
  (let* ((var (or (pop spec) (make-symbol "unitvar")))
         (count (or (pop spec) 0))
         (result (or (pop spec) var))
         (i (make-symbol "loopvar")))
    `(let* ((,i ,count)
            (,var (if (< ,i 0) -1 1)))
       (while (and (/= ,i 0)
                   (/= (point) (progn ,@body (point))))
         (setq ,i (if (< ,i 0) (1+ ,i) (1- ,i))))
       (setq ,result ,i))))


(defun helix-forward-nearest (count &rest forwards)
  "Move point forward to the first of several motions.
FORWARDS is a list of forward motion functions (i.e. each moves
point forward to the next end of a text object (if passed a +1)
or backward to the preceeding beginning of a text object (if
passed a -1)). This function calls each of these functions once
and moves point to the nearest of the resulting positions. If
COUNT is positive point is moved forward COUNT times, if negative
point is moved backward -COUNT times."
  (helix-motion-loop (dir (or count 1))
    (let ((pnt (point))
          (nxt (if (< dir 0) (point-min) (point-max))))
      (dolist (fwd forwards)
        (goto-char pnt)
        (ignore-errors
          (helix-with-restriction
              (when (< dir 0)
                (save-excursion
                  (goto-char nxt)
                  (line-beginning-position 0)))
              (when (> dir 0)
                (save-excursion
                  (goto-char nxt)
                  (line-end-position 2)))
            (and (zerop (funcall fwd dir))
                 (/= (point) pnt)
                 (if (< dir 0) (> (point) nxt) (< (point) nxt))
                 (setq nxt (point))))))
      (goto-char nxt))))



(defun forward-helix-word (&optional count)
  "Move forward COUNT words.
Moves point COUNT words forward or (- COUNT) words backward if
COUNT is negative.  Point is placed after the end of the word (if
forward) or at the first character of the word (if backward).  A
word is a sequence of word characters matching
\[[:word:]] (recognized by `forward-word'), a sequence of
non-whitespace non-word characters '[^[:word:]\\n\\r\\t\\f ]', or
an empty line matching ^$."
  (helix-forward-nearest
   count
   #'(lambda (&optional cnt)
       (let ((word-separating-categories helix-cjk-word-separating-categories)
             (word-combining-categories helix-cjk-word-combining-categories)
             (pnt (point)))
         (forward-word cnt)
         (if (= pnt (point)) cnt 0)))
   #'(lambda (&optional cnt)
       (helix-forward-chars "^[:word:]\n\r\t\f " cnt))
   #'forward-helix-empty-line))

(defun forward-helix-WORD (&optional count)
  "Move forward COUNT \"WORDS\".
Moves point COUNT WORDS forward or (- COUNT) WORDS backward if
COUNT is negative. Point is placed after the end of the WORD (if
forward) or at the first character of the WORD (if backward). A
WORD is a sequence of non-whitespace characters
'[^\\n\\r\\t\\f ]', or an empty line matching ^$."
  (helix-forward-nearest count
                        #'(lambda (&optional cnt)
                            (helix-forward-chars "^\n\r\t\f " cnt))
                        #'forward-helix-empty-line))

(defun forward-helix-symbol (&optional count)
  "Move forward COUNT symbols.
Moves point COUNT symbols forward or (- COUNT) symbols backward
if COUNT is negative. Point is placed after the end of the
symbol (if forward) or at the first character of the symbol (if
backward). A symbol is either determined by `forward-symbol', or
is a sequence of characters not in the word, symbol or whitespace
syntax classes."
  (helix-forward-nearest
   count
   #'(lambda (&optional cnt)
       (helix-forward-syntax "^w_->" cnt))
   #'(lambda (&optional cnt)
       (let ((pnt (point)))
         (forward-symbol cnt)
         (if (= pnt (point)) cnt 0)))
   #'forward-helix-empty-line))

(defun forward-helix-defun (&optional count)
  "Move forward COUNT defuns.
Moves point COUNT defuns forward or (- COUNT) defuns backward
if COUNT is negative.  A defun is defined by
`beginning-of-defun' and `end-of-defun' functions."
  (helix-motion-loop (dir (or count 1))
    (if (> dir 0) (end-of-defun) (beginning-of-defun))))

(defun forward-helix-sentence (&optional count)
  "Move forward COUNT sentences.
Moves point COUNT sentences forward or (- COUNT) sentences
backward if COUNT is negative.  This function is the same as
`forward-sentence' but returns the number of sentences that could
NOT be moved over."
  (helix-motion-loop (dir (or count 1))
    (ignore-errors (forward-sentence dir))))

(defun forward-helix-paragraph (&optional count)
  "Move forward COUNT paragraphs.
Moves point COUNT paragraphs forward or (- COUNT) paragraphs backward
if COUNT is negative.  A paragraph is defined by
`start-of-paragraph-text' and `forward-paragraph' functions."
  (helix-motion-loop (dir (or count 1))
    (cond
     ((> dir 0) (forward-paragraph))
     ((not (bobp)) (start-of-paragraph-text) (beginning-of-line)))))

;; (defvar helix-forward-quote-char ?\"
;;   "The character to be used by `forward-helix-quote'.")

;; (defun forward-helix-quote (&optional count)
;;   "Move forward COUNT strings.
;; The quotation character is specified by the global variable
;; `helix-forward-quote-char'. This character is passed to
;; `helix-forward-quote'."
;;   (helix-forward-quote helix-forward-quote-char count))

;; (defun forward-helix-quote-simple (&optional count)
;;   "Move forward COUNT strings.
;; The quotation character is specified by the global variable
;; `helix-forward-quote-char'. This functions uses Vim's rules
;; parsing from the beginning of the current line for quotation
;; characters. It should only be used when looking for strings
;; within comments and buffer *must* be narrowed to the comment."
;;   (let ((dir (if (> (or count 1) 0) 1 -1))
;;         (ch helix-forward-quote-char)
;;         (pnt (point))
;;         (cnt 0))
;;     (beginning-of-line)
;;     ;; count number of quotes before pnt
;;     (while (< (point) pnt)
;;       (when (= (char-after) ch)
;;         (setq cnt (1+ cnt)))
;;       (forward-char))
;;     (setq cnt (- (* 2 (abs count)) (mod cnt 2)))
;;     (cond
;;      ((> dir 0)
;;       (while (and (not (eolp)) (not (zerop cnt)))
;;         (when (= (char-after) ch) (setq cnt (1- cnt)))
;;         (forward-char))
;;       (when (not (zerop cnt)) (goto-char (point-max))))
;;      (t
;;       (while (and (not (bolp)) (not (zerop cnt)))
;;         (when (= (char-before) ch) (setq cnt (1- cnt)))
;;         (forward-char -1))
;;       (when (not (zerop cnt)) (goto-char (point-min)))))
;;     (/ cnt 2)))

;;; Motion functions
(defun helix-forward-beginning (thing &optional count)
  "Move forward to beginning of THING.
The motion is repeated COUNT times."
  (setq count (or count 1))
  (if (< count 0)
      (forward-thing thing count)
    (let ((bnd (bounds-of-thing-at-point thing))
          rest)
      (when (and bnd (< (point) (cdr bnd)))
        (goto-char (cdr bnd)))
      (ignore-errors
        (when (zerop (setq rest (forward-thing thing count)))
          (when (and (bounds-of-thing-at-point thing)
                     (not (bobp))
                     ;; handle final empty line
                     (not (and (bolp) (eobp))))
            (backward-char))
          (beginning-of-thing thing)))
      rest)))

(defun helix-backward-beginning (thing &optional count)
  "Move backward to beginning of THING.
The motion is repeated COUNT times. This is the same as calling
`helix-backward-beginning' with -COUNT."
  (helix-forward-beginning thing (- (or count 1))))

(defun helix-forward-end (thing &optional count)
  "Move forward to end of THING.
The motion is repeated COUNT times."
  (setq count (or count 1))
  (if (> count 0)
      (progn (unless (eobp) (forward-char))
             (prog1 (forward-thing thing count)
               (unless (bobp) (backward-char))))
    (let ((bnd (bounds-of-thing-at-point thing))
          rest)
      (when (and bnd (< (point) (cdr bnd) ))
        (goto-char (car bnd)))
      (ignore-errors
        (when (zerop (setq rest (forward-thing thing count)))
          (end-of-thing thing)
          (backward-char)))
      rest)))

(defun helix-backward-end (thing &optional count)
  "Move backward to end of THING.
The motion is repeated COUNT times. This is the same as calling
`helix-backward-end' with -COUNT."
  (helix-forward-end thing (- (or count 1))))

(defun helix-forward-word (&optional count)
  "Move by words.
Moves point COUNT words forward or (- COUNT) words backward if
COUNT is negative. This function is the same as `forward-word'
but returns the number of words by which point could *not* be
moved."
  (setq count (or count 1))
  (let* ((dir (if (>= count 0) +1 -1))
         (count (abs count)))
    (while (and (> count 0)
                (forward-word dir))
      (setq count (1- count)))
    count))

(provide 'helix-things)
