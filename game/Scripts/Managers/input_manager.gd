extends Node


var direction: Vector2 = Vector2.ZERO
var attack: bool = false
var block: bool = false
var disabled: bool = false

signal interact


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		return
	
	# Reset movement direction when input is disabled
	if disabled:
		direction = Vector2.ZERO
		return
	
	# Set movement direction from input axes
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	direction = Vector2(direction_x, direction_y).normalized()
	
	attack = Input.is_action_just_pressed("attack")
	block = Input.is_action_just_pressed("block")
	
	# Debug go to hub action
	if Input.is_action_just_pressed("debug_gotohub"):
		game_manager.load_level()
	
	if Input.is_action_just_pressed("interact"):
		interact.emit()


func toggle_input(enable: bool) -> void:
	if enable: 
		await get_tree().create_timer(.4).timeout
		
	disabled = !enable
