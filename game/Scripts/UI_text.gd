extends Panel

func _process(_delta: float) -> void:
	$Label.text = UtilitySystem.instance.current_state
