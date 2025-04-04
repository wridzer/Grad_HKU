extends Node2D


@onready var _keys_text: RichTextLabel = $Control/KeysText


func _ready() -> void:
	assert(is_instance_valid(_keys_text), "Please assign a valid _keys_text to KeysHud")
	game_manager.toggle_keys_hud.connect(toggle_keys_hud)
	game_manager.key_used.connect(func(x): update_keys())


func toggle_keys_hud(enabled: bool) -> void:
	update_keys()
	visible = enabled


func update_keys() -> void:
	var keys: String = str(Blackboard.get_data("keys")) if Blackboard.get_data("keys") else "0"
	_keys_text.text = "Keys Left: " + keys
