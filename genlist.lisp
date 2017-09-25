;; Generate playlist based on directory


;; read ~/music
;; for each sub directory, create a play list file
;; add all music to that file

;; for the top level, create a top.m3u

(defun directory_p (path)
  ;; check if has extension
  (not (pathname-type path)))

(defun list-file (path)
  (remove-if #'directory_p
             (directory (make-pathname :name :wild :type :wild
                                       :defaults path))))

(defun list-directory (path)
  "list all directories inside path"
  (directory (make-pathname :name :wild :type nil
                            :defaults path)))

(defun join-lines (lines)
  (format nil "~{~A~%~}" lines))

(defun save-playlist (songs file)
  (with-open-file (stream file :direction :output
                          :if-exists :overwrite
                          :if-does-not-exist :create)
    (write-string (join-lines songs) stream)))

(defun genlist (toplevel)
  ;; create playlists dir if not exists
  ;; for top level
  (save-playlist (mapcar #'file-namestring (list-file toplevel))
                 "playlists/top.m3u")
  ;; for all sub directories
  (mapcar (lambda (path)
            (let* ((dirname (car (last (pathname-directory path))))
                  (files (mapcar (lambda (s)
                      (concatenate 'string dirname "/" s))
                                 (mapcar #'file-namestring
                                         (list-file path)))))
              (save-playlist files
                             (concatenate 'string
                                          "playlists/" dirname ".m3u"))))
          (list-directory toplevel)))

(genlist (pathname "~/music/"))
