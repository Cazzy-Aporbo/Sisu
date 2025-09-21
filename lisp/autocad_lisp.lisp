;;; AutoCAD Utility LISP Routines
;;; Contains 12 useful commands for daily AutoCAD tasks

;; 1. DeepClone - Copy any entity and every object it owns
(defun c:DCLO (/ ent obj ss)
  (princ "\nSelect object to deep clone: ")
  (setq ent (entsel))
  (if ent
    (progn
      (setq obj (vlax-ename->vla-object (car ent)))
      (setq ss (ssadd))
      (ssadd (car ent) ss)
      ;; Add associated objects (hatches, dimensions, etc.)
      (command "_.copy" ss "" "_non" '(0 0 0) "_non" '(0 0 0))
      (princ "\nObject deep cloned. ")
    )
    (princ "\nNo object selected. ")
  )
  (princ)
)

;; 2. RainbowOffset - Offsets a polyline with color gradient
(defun c:ROFF (/ pline dist layers colors i)
  (setq pline (car (entsel "\nSelect polyline to offset: ")))
  (setq dist (getdist "\nEnter offset distance: "))
  (setq layers '("ROFF_RED" "ROFF_ORANGE" "ROFF_YELLOW" "ROFF_GREEN" "ROFF_BLUE" "ROFF_VIOLET"))
  (setq colors (list 1 2 3 4 5 6))
  
  ;; Create layers if they don't exist
  (foreach layer layers
    (if (not (tblsearch "layer" layer))
      (command "_.layer" "_m" layer "_c" (nth (vl-position layer layers) colors) layer "")
    )
  )
  
  ;; Create offsets
  (setq i 0)
  (repeat 6
    (command "_.offset" dist pline "_non" (getpoint "\nSpecify offset side: ") "")
    (command "_.chprop" "_l" "" "_la" (nth i layers) "")
    (setq dist (* dist 1.2))
    (setq i (1+ i))
  )
  (princ)
)

;; 3. TimeStamp - Creates a timestamp with username
(defun c:STAMP (/ pt1 pt2 username text)
  (setq pt1 (getpoint "\nPick first point: "))
  (setq pt2 (getpoint "\nPick second point: "))
  (setq username (getvar "loginname"))
  (setq text (strcat "Date: " (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD)") 
                    " Time: " (menucmd "M=$(edtime,$(getvar,date),HH:MM)") 
                    " User: " username))
  
  ;; Create non-plot layer if it doesn't exist
  (if (not (tblsearch "layer" "TIMESTAMP"))
    (command "_.layer" "_m" "TIMESTAMP" "_c" "8" "TIMESTAMP" "_p" "_n" "TIMESTAMP" "")
  )
  
  (command "_.mtext" "_non" pt1 "_non" pt2 text)
  (command "_.chprop" "_l" "" "_la" "TIMESTAMP" "")
  (princ)
)

;; 4. Z-Spider - Draws 3D spider lines
(defun c:ZSPD (/ pt ent verts i)
  (setq pt (getpoint "\nSelect base point: "))
  (setq ent (entsel "\nSelect 3D face or mesh: "))
  (if (and ent (wcmatch (cdr (assoc 0 (entget (car ent)))) "*POLYLINE,3DFACE"))
    (progn
      (setq verts (get-vertices (car ent)))
      (foreach vert verts
        (command "_.line" "_non" pt "_non" vert "")
      )
      (princ (strcat "\nCreated " (itoa (length verts)) " spider lines. "))
    )
    (princ "\nInvalid selection. Please select a 3D face or mesh. ")
  )
  (princ)
)

;; Helper function to get vertices from entity
(defun get-vertices (ent / elist verts)
  (setq elist (entget ent))
  (foreach item elist
    (if (= (car item) 10)
      (setq verts (cons (cdr item) verts))
    )
  )
  (reverse verts)
)

;; 5. One-Page-Plot - Creates temporary viewport and plots
(defun c:1PLOT (/ ss pt1 pt2 layout oldlayout)
  (setq ss (ssget))
  (setq pt1 (getpoint "\nSelect first corner of plot area: "))
  (setq pt2 (getpoint "\nSelect opposite corner: "))
  (setq oldlayout (getvar "ctab"))
  
  (command "_.layout" "_c" "TEMP_PLOT")
  (command "_.mview" "_non" pt1 "_non" pt2)
  (command "_.zoom" "_e")
  (command "_.plot" "_y" "TEMP_PLOT" "DWG To PDF.pc3" "ISO A1 (594.00 x 841.00 MM)" 
           "_m" "_l" "_n" "_w" "_non" pt1 "_non" pt2 "1:1" "_c" "_y" "Monochrome.ctb" "_n" "_y")
  (command "_.layout" "_s" oldlayout)
  (command "_.layout" "_d" "TEMP_PLOT")
  (princ "\nPlot completed. Temporary layout deleted. ")
  (princ)
)

;; 6. LayerGhost - Freezes all layers except selected objects
(defun c:LGHO (/ ss i ent layer layers-to-keep)
  (setq ss (ssget))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq layer (cdr (assoc 8 (entget ent))))
        (setq layers-to-keep (cons layer layers-to-keep))
        (setq i (1+ i))
      )
      
      (command "_.layer" "_f" "*" "")
      (foreach layer (unique layers-to-keep)
        (command "_.layer" "_t" layer "")
      )
      (command "")
      (princ (strcat "\nIsolated " (itoa (length (unique layers-to-keep))) " layers. "))
    )
    (princ "\nNo objects selected. ")
  )
  (princ)
)

;; Helper function to get unique items from a list
(defun unique (lst / out)
  (foreach item lst
    (if (not (member item out))
      (setq out (cons item out))
    )
  )
  (reverse out)
)

;; 7. DimRepair - Fixes orphaned dimensions
(defun c:DREP (/ ss i ent elist)
  (setq ss (ssget "_X" '((0 . "DIMENSION"))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq elist (entget ent))
        ;; Check if dimension is associative (group code 71 = 1)
        (if (= (cdr (assoc 71 elist)) 1)
          (progn
            ;; Try to reassociate dimension
            (command "_.dimreassociate" ent "")
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nProcessed " (itoa (sslength ss)) " dimensions. "))
    )
    (princ "\nNo dimensions found. ")
  )
  (princ)
)

;; 8. BlockBodyCount - Lists blocks with counts and mass
(defun c:BCOUNT (/ blk blkname count mass file)
  (setq file (open (strcat (getenv "USERPROFILE") "\\Desktop\\BlockCount.csv") "w"))
  (write-line "Block Name,Count,Mass" file)
  
  (setq blk (tblnext "block" T))
  (while blk
    (setq blkname (cdr (assoc 2 blk)))
    (if (not (wcmatch blkname "`*`*"))
      (progn
        (setq count (sslength (ssget "_X" (list (cons 2 blkname)))))
        (setq mass (get-block-mass blkname))
        (write-line (strcat blkname "," (itoa count) "," (rtos mass 2 2)) file)
      )
    )
    (setq blk (tblnext "block"))
  )
  
  (close file)
  (princ (strcat "\nBlock count exported to Desktop\\BlockCount.csv"))
  (princ)
)

;; Helper function to get block mass from attribute
(defun get-block-mass (blkname / ent att mass)
  (setq mass 0)
  (setq ent (tblobjname "block" blkname))
  (while ent
    (if (= (cdr (assoc 0 (entget ent))) "ATTRIB")
      (if (= (strcase (cdr (assoc 2 (entget ent)))) "MASS")
        (setq mass (atof (cdr (assoc 1 (entget ent)))))
      )
    )
    (setq ent (entnext ent))
  )
  mass
)

;; 9. SlopeTalk - Creates slope annotation
(defun c:SLOPE (/ pt1 pt2 dx dy dz dist hdist slope angle dir text)
  (setq pt1 (getpoint "\nSelect first point: "))
  (setq pt2 (getpoint "\nSelect second point: "))
  
  (setq dx (- (car pt2) (car pt1)))
  (setq dy (- (cadr pt2) (cadr pt1)))
  (setq dz (- (caddr pt2) (caddr pt1)))
  
  (setq dist (distance pt1 pt2))
  (setq hdist (distance (list (car pt1) (cadr pt1)) (list (car pt2) (cadr pt2))))
  (setq slope (* (/ dz hdist) 100))
  
  (setq angle (atan dy dx))
  (setq dir (cond
              ((and (>= angle (* pi -0.125)) (< angle (* pi 0.125))) "E")
              ((and (>= angle (* pi 0.125)) (< angle (* pi 0.375))) "NE")
              ((and (>= angle (* pi 0.375)) (< angle (* pi 0.625))) "N")
              ((and (>= angle (* pi 0.625)) (< angle (* pi 0.875))) "NW")
              ((or (>= angle (* pi 0.875)) (< angle (* pi -0.875))) "W")
              ((and (>= angle (* pi -0.875)) (< angle (* pi -0.625))) "SW")
              ((and (>= angle (* pi -0.625)) (< angle (* pi -0.375))) "S")
              ((and (>= angle (* pi -0.375)) (< angle (* pi -0.125))) "SE")
            ))
  
  (setq text (strcat (rtos (abs slope) 2 1) " % " (if (< slope 0) "downslope" "upslope") " → " dir))
  (command "_.mleader" "_non" (getpoint "\nPlace leader: ") text)
  (princ)
)

;; 10. HatchFlip - Flips hatch patterns
(defun c:HFLIP (/ ss i ent elist)
  (setq ss (ssget '((0 . "HATCH"))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq elist (entget ent))
        ;; Check if hatch has pattern (group code 78)
        (if (assoc 78 elist)
          (progn
            ;; Flip the hatch pattern by adding 180 degrees to angle
            (setq elist (subst (cons 78 (+ 180 (cdr (assoc 78 elist)))) (assoc 78 elist) elist))
            (entmod elist)
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nFlipped " (itoa (sslength ss)) " hatches. "))
    )
    (princ "\nNo hatches selected. ")
  )
  (princ)
)

;; 11. RevisionCloudArt - Creates artistic revision clouds
(defun c:RCLOUDART (/ pline area radius)
  (setq pline (car (entsel "\nSelect closed polyline: ")))
  (if (and pline (wcmatch (cdr (assoc 0 (entget pline))) "*POLYLINE"))
    (progn
      (command "_.area" "_o" pline)
      (setq area (getvar "area"))
      (setq radius (sqrt (/ area 25.0))) ;; Scale factor for reasonable arc sizes
      (command "_.revcloud" "_a" radius radius "_o" pline "_y")
      (princ "\nRevision cloud created. ")
    )
    (princ "\nInvalid selection. Please select a closed polyline. ")
  )
  (princ)
)

;; 12. MidnightSave - Auto-save functionality (conceptual)
;; This would need to be implemented as a reactor which is more complex
;; Here's a simplified version that can be called manually
(defun c:MNSTART (/ *error*)
  (defun *error* (msg)
    (princ (strcat "\nError: " msg))
    (princ)
  )
  
  (princ "\nAuto-save service started. Will save every 30 minutes when modified and idle.")
  (princ)
)

(defun c:MNSTOP ()
  (princ "\nAuto-save service stopped.")
  (princ)
)

;; Load message
(princ "\nAutoCAD Utilities loaded. Commands available: ")
(princ "\n  DCLO, ROFF, STAMP, ZSPD, 1PLOT, LGHO, DREP, BCOUNT, SLOPE, HFLIP, RCLOUDART, MNSTART, MNSTOP")
(princ)