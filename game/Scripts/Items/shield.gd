extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.scene_file_path == "res://Scenes/enemy.tscn"):
		if (Blackboard.get_data("amount_blocked")):
			Blackboard.add_data("amount_blocked", Blackboard.get_data("amount_blocked") + 1)
		else:
			Blackboard.add_data("amount_blocked", 1)
