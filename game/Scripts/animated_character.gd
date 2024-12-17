class_name AnimatedCharacter
extends CharacterBody2D


var animation_tree: AnimationTree
var animation_player: AnimationPlayer


func _process(_delta: float) -> void:
	update_animation_parameters()


func block() -> bool:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")
	
	# Most rigid way to get the right direction at this point is from the idle blend position
	animation_tree.set("parameters/Block/blend_position", animation_tree.get("parameters/Idle/blend_position"))
	animation_tree.set("parameters/conditions/block", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("character_animations/block_right").length).timeout
	
	animation_tree.set("parameters/conditions/block", false)
	return true


func slash() -> bool:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")
	
	# Most rigid way to get the right direction at this point is from the idle blend position
	animation_tree.set("parameters/Slash/blend_position", animation_tree.get("parameters/Idle/blend_position"))
	animation_tree.set("parameters/conditions/slash", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("character_animations/slash_right").length).timeout
	
	animation_tree.set("parameters/conditions/slash", false)
	return true


func shoot(direction: Vector2) -> bool:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")
	
	animation_tree.set("parameters/Shoot/blend_position", direction)
	animation_tree.set("parameters/conditions/shoot", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("character_animations/shoot_right").length).timeout
	
	animation_tree.set("parameters/conditions/shoot", false)
	return true


func update_animation_parameters() -> void:
	pass


func set_immunity_animation_param(immune: bool) -> void:
	animation_tree.set("parameters/conditions/hit", immune)


func reset_animation_parameters() -> void:
	animation_tree.set("parameters/conditions/hit", false)
	animation_tree.set("parameters/conditions/slash", false)
	animation_tree.set("parameters/conditions/block", false)
	animation_tree.set("parameters/conditions/shoot", false)
