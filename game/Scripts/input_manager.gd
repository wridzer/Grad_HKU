extends Node

var direction : Vector2
signal attack


func _process(_delta: float) -> void:
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	direction = Vector2(directionx, directiony).normalized()
	
	if Input.is_action_just_pressed("attack"):
		attack.emit()
