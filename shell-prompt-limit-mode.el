;;; shell-prompt-limit.el --- Limits the length of shell prompt.

;; Copyright (C) 2020 Nathaniel Flath

;; Author: Nathaniel Flath <flat0103@gmail.com>
;; Maintainer: Nathaniel Flath <flat0103@gmail.com>
;; Created: 8 Feb 2020
;; Version: 1.0
;; URL: https://github.com/nflath/shell-prompt-limit

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; dirtrack forces the full path to be in your shell prompt.  Sometimes, this
;; means that your shell prompt will be extremely long; this package is
;; designed so that the prompt displayed is still a reasonable length.

;; Usage:
;; (require 'shell-prompt-limit.el)
;; (shell-prompt-limit-mode t)

;; shell-prompt-limit-max-prompt-len limits the length of the replaced prompt;
;; shell-prompt-limit-prompt-replacement controls the format of the new prompt,
;; only used if the old one was too long.  $1 will be replaced with the
;; rightmost part of the path.

;;; Code:
(defvar shell-prompt-limit-max-prompt-len 40 "Maximum length of your prompt string.")
(defvar shell-prompt-limit-prompt-replacement "user@...$1$ " "Pattern to use as prompt after trimming down the length.  $1 will be replaced with a left-truncated path.")

;; Pulled from s.el in order to limit dependencies
(defun shell-prompt-limit-s-replace (old new s)
  "Replaces OLD with NEW in S."
  (declare (pure t) (side-effect-free t))
  (replace-regexp-in-string (regexp-quote old) new s t t))

;; Dirtrack forces the prompt to contain the full working directory, but this
;; sometimes causes the prompt to be too long.  The following code will cause
;; your prompt to only contain the last 40 characters of the current directory.
(defun dirtrack-buffer-name-track-shorten-prompt (input)
  "Shortens any prompts displayed to max-prompt-len chars."
  (let* ((prompt (progn (if (string-match (car dirtrack-list) input)
                            (match-string 0 input))))
         (prompt-len (if prompt (length prompt) 0))
         (truncate-dir-len (- shell-prompt-limit-max-prompt-len (length shell-prompt-limit-prompt-replacement)))
         (replacement-prompt (shell-prompt-limit-s-replace "$1" (substring default-directory truncate-dir-len) shell-prompt-limit-prompt-replacement )))
    (message "yo")
    (message replacement-prompt)
    (print prompt-len)
    (print shell-prompt-limit-max-prompt-len)
    (if (> prompt-len shell-prompt-limit-max-prompt-len)
          (shell-prompt-limit-s-replace prompt replacement-prompt input)
      input)))

(define-minor-mode shell-prompt-limit-mode
  "Minor mode to replace prompt with a truncated version."
  :init-value nil
  :group 'shell-prompt-limit-mode
  (if shell-prompt-limit-mode
      (add-hook 'comint-preoutput-filter-functions 'dirtrack-buffer-name-track-shorten-prompt)
    (remove-hook 'comint-preoutput-filter-functions 'dirtrack-buffer-name-track-shorten-prompt)))

(provide 'shell-prompt-limit-mode)

;;; shell-prompt-limit-mode ends here
