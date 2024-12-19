extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.scene_file_path == "res://Scenes/enemy.tscn"):
		Blackboard.increment_data("shield_hit_enemy_amount", 1)


func _on_hitbox_component_shield_body_entered(body: Node2D) -> void:
	if(body.scene_file_path == "res://Scenes/enemy.tscn"):
		Blackboard.increment_data("shield_hit_enemy_amount", 1)
