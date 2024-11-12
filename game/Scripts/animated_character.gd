class_name AnimatedCharacter
extends CharacterBody2D


var animation_tree: AnimationTree
var animation_player: AnimationPlayer


func _process(_delta: float) -> void:
	update_animation_parameters()


func block() -> void:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")
	animation_tree.set("parameters/conditions/block", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("block_right").length).timeout
	
	animation_tree.set("parameters/conditions/block", false)


func slash() -> void:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")
	animation_tree.set("parameters/conditions/slash", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("slash_right").length).timeout
	
	animation_tree.set("parameters/conditions/slash", false)


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	animation_tree.set("parameters/conditions/idle", input_manager.direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", input_manager.direction != Vector2.ZERO)
	
	if input_manager.direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", input_manager.direction)
		animation_tree.set("parameters/Idle/blend_position", input_manager.direction)
		animation_tree.set("parameters/Walk/blend_position", input_manager.direction)
	
	if input_manager.attack && !animation_tree.get("parameters/conditions/slash"):
		# Easiest way to get the right direction at this point
		animation_tree.set("parameters/Slash/blend_position", animation_tree.get("parameters/Idle/blend_position"))
		slash()
	
	if input_manager.block && !animation_tree.get("parameters/conditions/block"):
		# Easiest way to get the right direction at this point
		animation_tree.set("parameters/Block/blend_position", animation_tree.get("parameters/Idle/blend_position"))
		block()


func set_immunity_animation_param(immune: bool) -> void:
	animation_tree.set("parameters/conditions/hit", immune)
