extends Node


var direction: Vector2 = Vector2.ZERO
var attack: bool = false
var block: bool = false
var disabled: bool = false

signal interact


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


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
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	direction = Vector2(directionx, directiony).normalized()
	
	attack = Input.is_action_just_pressed("attack")
	block = Input.is_action_just_pressed("block")
	
	if Input.is_action_just_pressed("interact"):
		interact.emit()


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	# Re-enable input when dialogue has ended
	toggle_input(true)


func toggle_input(enable: bool) -> void:
	if enable: 
		await get_tree().create_timer(.4).timeout
		
	disabled = !enable
