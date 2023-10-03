(defun c:entityProbe ()
  (entget (ssname (ssget "_:S+.") 0))
)