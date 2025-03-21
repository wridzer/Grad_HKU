extends Node


signal interact
signal pause(paused)

var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var attack: bool = false
var block: bool = false
var bow: bool = false
var disabled: bool = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		pause.emit(get_tree().paused)
	
	if get_tree().paused:
		return
	
	# Reset movement direction when input is disabled
	if disabled:
		direction = Vector2.ZERO
		mouse_direction = Vector2.ZERO
		return
	
	# Set movement direction from input axes
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	direction = Vector2(direction_x, direction_y).normalized()
	
	# Set mouse direction
	mouse_direction = (get_viewport().get_camera_2d().get_global_mouse_position() - Player.instance.global_position).normalized()
	
	attack = Input.is_action_just_pressed("attack")
	block = Input.is_action_just_pressed("block")
	bow = Input.is_action_just_pressed("bow")
	
	# Debug go to hub action
	if Input.is_action_just_pressed("debug_gotohub"):
		game_manager.load_level()
	
	if Input.is_action_just_pressed("interact"):
		interact.emit()


func toggle_input(enable: bool) -> void:
	if enable: 
		await get_tree().create_timer(.4).timeout
		
	disabled = !enable
