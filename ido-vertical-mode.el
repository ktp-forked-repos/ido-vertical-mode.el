;;; ido-vertical-mode.el --- Makes ido-mode display vertically

;; Author: Steven Degutis
;; URL: https://github.com/sdegutis/ido-vertical-mode.el
;; Version: 0.1

(setq sd/ido-decorations '("\n-> "
                           ""
                           "\n   "
                           "\n   ..."
                           "["
                           "]"
                           " [No match]"
                           " [Matched]"
                           " [Not readable]"
                           " [Too big]"
                           " [Confirm]"
                           "\n-> "
                           ""))

(defun sd/ido-completions (name)
  ;; Return the string that is displayed after the user's text.
  ;; Modified from `icomplete-completions'.

  (let* ((comps ido-matches)
	 (ind (and (consp (car comps)) (> (length (cdr (car comps))) 1)
		   ido-merged-indicator))
	 first)

    (if (and ind ido-use-faces)
	(put-text-property 0 1 'face 'ido-indicator ind))

    (if (and ido-use-faces comps)
	(let* ((fn (ido-name (car comps)))
	       (ln (length fn)))
	  (setq first (format "%s" fn))
	  (put-text-property 0 ln 'face
			     (if (= (length comps) 1)
                                 (if ido-incomplete-regexp
                                     'ido-incomplete-regexp
                                   'ido-only-match)
			       'ido-first-match)
			     first)
	  (if ind (setq first (concat first ind)))
	  (setq comps (cons first (cdr comps)))))

    (cond ((null comps)
	   (cond
	    (ido-show-confirm-message
	     (or (nth 10 ido-decorations) " [Confirm]"))
	    (ido-directory-nonreadable
	     (or (nth 8 ido-decorations) " [Not readable]"))
	    (ido-directory-too-big
	     (or (nth 9 ido-decorations) " [Too big]"))
	    (ido-report-no-match
	     (nth 6 ido-decorations))  ;; [No match]
	    (t "")))
	  (ido-incomplete-regexp
           (concat " " (car comps)))
	  ((null (cdr comps))		;one match
	   (concat (concat (nth 11 ido-decorations)  ;; [ ... ]
                           (ido-name (car comps))
                           (nth 12 ido-decorations))
		   (if (not ido-use-faces) (nth 7 ido-decorations))))  ;; [Matched]
	  (t				;multiple matches
	   (let* ((items (if (> ido-max-prospects 0) (1+ ido-max-prospects) 999))
		  (alternatives
		   (apply
		    #'concat
		    (cdr (apply
			  #'nconc
			  (mapcar
			   (lambda (com)
			     (setq com (ido-name com))
			     (setq items (1- items))
			     (cond
			      ((< items 0) ())
			      ((= items 0) (list (nth 3 ido-decorations))) ; " | ..."
			      (t
			       (list (or ido-separator (nth 2 ido-decorations)) ; " | "
				     (let ((str (substring com 0)))
				       (if (and ido-use-faces
						(not (string= str first))
						(ido-final-slash str))
					   (put-text-property 0 (length str) 'face 'ido-subdir str))
				       str)))))
			   comps))))))

	     (concat
	      ;; put in common completion item -- what you get by pressing tab
	      (if (and (stringp ido-common-match-string)
		       (> (length ido-common-match-string) (length name)))
		  (concat (nth 4 ido-decorations)   ;; [ ... ]
			  (substring ido-common-match-string (length name))
			  (nth 5 ido-decorations)))
	      ;; list all alternatives
	      (nth 0 ido-decorations)  ;; { ... }
	      alternatives
	      (nth 1 ido-decorations)))))))

(defun turn-on-ido-vertical ()
  (setq sd/old-ido-decorations ido-decorations)
  (setq sd/old-ido-completions (symbol-function 'ido-completions))
  (setq ido-decorations sd/ido-decorations)
  (fset 'ido-completions 'sd/ido-completions))

(defun turn-off-ido-vertical ()
  (setq ido-decorations sd/old-ido-decorations)
  (fset 'ido-completions sd/old-ido-completions))

(define-minor-mode ido-vertical-mode
  "Makes ido-mode display vertically."
  :global t
  (if ido-vertical-mode
      (turn-on-ido-vertical)
    (turn-off-ido-vertical)))

(provide 'ido-vertical-mode)

;;; ido-vertical-mode.el ends here