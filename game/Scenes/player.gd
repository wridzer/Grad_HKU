extends CharacterBody2D


const SPEED = 100.0


func _physics_process(delta: float) -> void:
	var directiony := Input.get_axis("ui_up", "ui_down")
	var directionx := Input.get_axis("ui_left", "ui_right")
	
	velocity.x = directionx * SPEED if directionx else move_toward(velocity.x, 0, SPEED)
	velocity.y = directiony * SPEED if directiony else move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
