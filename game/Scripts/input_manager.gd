extends Node

var direction : Vector2
var disabled : bool = false
signal attack


func _ready() -> void:
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)


func _process(_delta: float) -> void:
	# Stop moving when input is disabled
	direction = Vector2.ZERO
	if disabled:
		return
	
	# Set movement direction from input axes
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	direction = Vector2(directionx, directiony).normalized()
	
	if Input.is_action_just_pressed("attack"):
		attack.emit()


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	# Re-enable input when dialogue has ended
	toggle_input(true)


func toggle_input(enabled: bool) -> void:
	disabled = !enabled
	print(disabled)
