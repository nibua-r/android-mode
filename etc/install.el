;; Author: R. Aubin
;; Created: 11 Oct 2011
;; Time-stamp: <2011-10-11 22:08:25>
;; Adapted from https://github.com/m2ym/auto-complete.

(require 'cl)

(when (or (not (featurep 'android-mode))
          (yes-or-no-p "You are trying to upgrade auto-complete within an existed Emacs which has loaded its older version.
It causes sometimes errors or installation fault. Are you sure? "))
  (let* ((basedir (file-name-directory (directory-file-name (file-name-directory load-file-name))))
         (default-dir "~/.emacs.d/")
         (todir (or (car command-line-args-left)
                    (read-file-name "Install to: " default-dir default-dir))))
    (cond
     ((not (file-directory-p basedir))
      (error "Base directory is not found"))
     ((or (eq (length todir) 0)
          (not (file-directory-p todir)))
      (error "To directory is empty or not found"))
     (t
      (message "Installing to %s from %s" todir basedir)
      (add-to-list 'load-path basedir)
      (loop for file in (directory-files basedir t "^.*\\.el$")
            do (byte-compile-file file))
      (loop for file in (directory-files basedir t "^.*\\.elc?$")
            do (copy-file file todir t))

      (let ((msg (concat "Successfully installed!

Add the following code to your .emacs:

"
                         (if (and (not (member (expand-file-name todir) load-path))
                                  (not (member (concat (expand-file-name todir) "/") load-path)))
                             (format "(add-to-list 'load-path \"%s\")\n" todir)
                           "")
                         "(require 'android-mode)\n")))
        (if noninteractive
            (princ-list msg)
          (switch-to-buffer "*Installation Result*")
          (erase-buffer)
          (insert msg)))))))
