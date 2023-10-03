(defun c:plinePoints
  (/
    plineProps
    plineLayer
    ; plineVertices ((Number X-coord Y-coord)...)
    plineVertices
    vertexNumber
    textHeight
    selection
  )
  (setq textHeight 5)
  (setq selection nil)
  (while (= selection nil)
    (prompt "Select polyline")
    (setq selection (ssget "_:S+." '((0 . "LWPOLYLINE"))))
  )
  (setq plineProps (entget (ssname selection 0)))
  (setq plineLayer (cdr (assoc 8 plineProps)))
  (setq plineVertices ())
  (setq vertexNumber 1)
  (foreach group plineProps
    (if (= (car group) 10)
      ((lambda ()
        (setq plineVertices (append plineVertices (list (cons vertexNumber (cdr group)))))
        (setq vertexNumber (+ vertexNumber 1))
      ))
    )
  )
  (foreach vertex plineVertices
    (entmake
      (list
        (cons 0 "TEXT")
        (cons 8 plineLayer)
        (cons 10 (cdr vertex))
        (cons 1 (itoa (nth 0 vertex)))
        (cons 7 (getvar "textstyle"))
        (cons 40 textHeight)
        (cons 72 1)
        (cons 11 (list (nth 1 vertex) (+ (nth 2 vertex) (* textHeight 0.5))))
      )
    )
  )
  (entmake
    (append
      (list
        ; 0 Entity name (ACAD_TABLE)
        (cons 0 "ACAD_TABLE")
        ; 100 Subclass marker. (AcDbEntity)
        (cons 100 "AcDbEntity")
        ; 8 Layer name
        (cons 8 plineLayer)
        ; 100 Subclass marker. (AcDbBlockReference)
        (cons 100 "AcDbBlockReference")
        ; 10,20,30 Insertion point
        (cons 10 (cdr (car (reverse plineVertices))))
        ; 100 Subclass marker. (AcDbTable)
        (cons 100 "AcDbTable")
        ; 91 Number of rows
        (cons 91 (+ 2 (length plineVertices)))
        ; 92 Number of columns
        (cons 92 3)
      )
      ; 141 Row height; this value is repeated, 1 value per row
      ; Title and Header rows
      (list
        ; Title row
        (cons 141 8.0)
        ; Header row
        (cons 141 8.0)
      )
      ; Data rows
      (mapcar
        '(lambda (vertex)
          (cons 141 8.0)
        )
        plineVertices
      )
      ; 142 Column height; this value is repeated, 1 value per column
      (list
        (cons 142 20.0)
        (cons 142 40.0)
        (cons 142 40.0)
      )
      
      ; Cells
      ; 171 Cell type; this value is repeated, 1 value per cell: 1 = text type, 2 = block type
      ; 173 Cell merged value; this value is repeated, 1 value per cell
      ; 175 Cell border width (applicable only for merged cells); this value is repeated, 1 value per cell
      ; 176 Cell border height ( applicable for merged cells); this value is repeated, 1 value per cell
      ; 145 Rotation value (real; applicable for a block-type cell and a text-type cell)
      ; 301 Cell value block begin (from AutoCAD 2007)
      ; 1 Text string in a cell.
      ; 302 Text string in a cell.

      ; Title and Header rows
      (list
        ; Title row
        '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        (cons 1 plineLayer)
        (cons 302 plineLayer)
        '(304 . "ACVALUE_END")

        '(171 . 1) '(173 . 1) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        '(1 . "")
        '(302 . "")
        '(304 . "ACVALUE_END")
      
        '(171 . 1) '(173 . 1) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        '(1 . "")
        '(302 . "")
        '(304 . "ACVALUE_END")
        ; Header row
        '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        '(1 . "Point Number")
        '(302 . "Point number")
        '(304 . "ACVALUE_END")
        
        '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        '(1 . "X coordinates")
        '(302 . "X coordinates")
        '(304 . "ACVALUE_END")
        
        '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
        '(1 . "Y coordinates")
        '(302 . "Y coordinates")
        '(304 . "ACVALUE_END")
      )
      ; Data rows
      (apply 'append
        (mapcar
          '(lambda (vertex)
            (list
              ; Point Number
              '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
              (cons 1 (itoa (nth 0 vertex)))
              (cons 302 (itoa (nth 0 vertex)))
              '(304 . "ACVALUE_END")
              ; X coordinate
              '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
              (cons 1 (rtos (nth 1 vertex) 2 3))
              (cons 302 (rtos (nth 1 vertex) 2 3))
              '(304 . "ACVALUE_END")
              ; Y coordinate
              '(171 . 1) '(173 . 0) '(175 . 0) '(176 . 0) '(145 . 0.0) '(301 . "CELL_VALUE") '(90 . 4)
              (cons 1 (rtos (nth 2 vertex) 2 3))
              (cons 302 (rtos (nth 2 vertex) 2 3))
              '(304 . "ACVALUE_END")
            )
          )
          plineVertices
        )
      )
    )
  )
  (print)
)
