;;;; shmup-test.lisp

;;TODO MAKE MAKE-COPY METHOD

(in-package #:shmup-test)

(defclass game-object (mover)
  ((HP     :accessor   HP 
	   :initarg :HP          
	   :initform 1
	   :documentation "Health points, dead if setf <= 0")
   (hitbox :accessor hitbox
	   :initarg :hitbox 
	   :initform nil
	   :documentation "may be nil or a hitbox instance")
   (dead   :accessor dead 
	   :initform nil
	   :documentation "A simple flag for dead object in game")))

(defmethod %hitbox-recenter ((object game-object))
  ;; Hooks hitbox if not nil and repositions it to center
  (when (typep (hitbox object) 'hitbox)
    (set-positionf (hitbox object)
		   (x object) 
		   (y object))))

;; Optional creation function
(defun make-game-object (x y &key 
			       (speed 0.0)
			       (direction 0.0)
			       (width nil)
			       (height nil))
    (make-instance 'game-object
     :hitbox (if (and (numberp width) (numberp height))
		 (make-hitbox width height x y)
		 nil)
     :x x
     :y y
     :speed speed
     :direction direction))


(defmethod initialize-instance :after ((object game-object) &key)
  (%hitbox-recenter object))


(defmethod %determine-health-dead ((object game-object))
  ;; Sets the dead flag if HP is <= 0
  (when (<= (HP object) 0.0)
    (setf (dead object) t)))

 (defmethod (setf HP) (val (object game-object)) 
   (with-slots (HP) object
     (setf HP val) 
     (%determine-health-dead object)))

 (defmethod (setf x) (val (object game-object)) 
   (with-slots (x) object
     (setf x val) 
     (%hitbox-recenter object)))

 (defmethod (setf y) (val (object game-object)) 
   (with-slots (y) object
     (setf y val) 
     (%hitbox-recenter object)))

(defmethod (setf hitbox) (val (object game-object))
    (with-slots (hitbox) object
      (setf hitbox val)
      (%hitbox-recenter object)))  

(defmethod stepf :after ((object game-object))
  ;; Reposition the hitbox
  (%hitbox-recenter object))


;;; Predicates
(defmethod collidep ((object game-object) (object2 game-object))
  (if (and (typep (hitbox object) 'hitbox) 
	   (typep (hitbox object2) 'hitbox))

      ;; Both valid hitboxes, return the test results
      (collidep (hitbox object) (hitbox object2))

      ;; One or more is Nil, test returns NIL
      nil))

(defmethod alivep ((object game-object))
  (not (dead object)))

