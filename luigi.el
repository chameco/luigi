;;; luigi.el --- Line-oriented user interfaces -*- lexical-binding: t -*-

;;; Commentary:
;; Conceptually inspired by LUI, a similar library created by Jordan Schaefer.

;;; Code:
(defgroup luigi nil
  "Line-oriented user interfaces."
  :group 'convenience)

(defgroup luigi-faces nil
  "Faces for `luigi'."
  :group 'luigi
  :group 'faces)

(defface luigi-prompt-face
  '((t :inherit highlight))
  "Face used to highlight the current selection.")

(defvar luigi-prompt-function (lambda () "> "))

(defvar luigi-do-function (lambda (_)))

(defvar luigi-mode-map (make-sparse-keymap))
(define-key luigi-mode-map (kbd "<return>") 'luigi-do)
(define-key luigi-mode-map (kbd "C-l") 'luigi-clear)

(defvar-local luigi-prompt-marker nil)

;;;###autoload
(define-derived-mode luigi-mode nil "Luigi"
  "Major mode for line-oriented user interfaces."
  :after-hook (luigi-clear)
  (setq-local luigi-prompt-marker (make-marker))
  (setq-local luigi-do-function (lambda (str) (luigi-write str))))

(defun luigi-emit-prompt ()
  "Display the prompt from the line interface."
  (save-excursion
    (erase-buffer)
    (goto-char (point-min))
    (insert (funcall luigi-prompt-function))
    (set-marker luigi-prompt-marker (point))
    (add-text-properties
     (line-beginning-position)
     (point)
     '(field luigi-prompt
             read-only t
             face luigi-prompt-face
             rear-nonsticky t
             front-sticky t))))

(defun luigi-clear ()
  "Clear the line interface (removing all past outputs)."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (luigi-emit-prompt)
    (goto-char (point-max))))

(defun luigi-read ()
  "Read and return user input from the line interface."
  (buffer-substring-no-properties
   (marker-position luigi-prompt-marker)
   (point-max)))

(defun luigi-write (str)
  "Write STR to the line interface."
  (let ((inhibit-read-only t)
        (inhibit-field-text-motion t))
    (save-excursion
      (goto-char (marker-position luigi-prompt-marker))
      (beginning-of-line)
      (let ((begin (point)))
        (insert (concat str "\n"))
        (add-text-properties
         begin
         (point)
         '(read-only t
                     front-sticky t))))))

(defun luigi-clear-input ()
  "Clear user input in the line interface."
  (delete-region
   (marker-position luigi-prompt-marker)
   (point-max)))

(defun luigi-do ()
  "Process user input using `luigi-do-function'."
  (interactive)
  (let ((str (luigi-read)))
    (luigi-clear-input)
    (funcall luigi-do-function str)))

(provide 'luigi)
;;; luigi.el ends here
