;;;; shmup-test.lisp

;;TODO MAKE MAKE-COPY METHOD

(in-package #:shmup-test)

(defclass game-object (mover)
  ((HP     :reader   HP 
	   :initarg :HP          
	   :initform 1
	   :documentation "Health points, dead if <= 0")
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
		 (make-instance 'hitbox
				:center-x x
				:center-y y
				:width width
				:height height)
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

;;; Getters
(defmethod get-hitbox ((object game-object))
  (hitbox object))

;;; Setters
(defmethod set-HPf ((object game-object) (value number))
  ;; If passed a value <= 0 the dead flag is set to true
  (setf (slot-value object 'HP) value)
  (%determine-health-dead object))

(defmethod set-incf-HPf ((object game-object) (value number))
  ;; incf for HP adjustments with dead flag hook
  (incf (slot-value object 'HP) value)
  (%determine-health-dead object))

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


