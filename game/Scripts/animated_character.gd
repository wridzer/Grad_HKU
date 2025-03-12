class_name AnimatedCharacter
extends CharacterBody2D


@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var animation_direction: Node2D


func _ready() -> void:
	assert(is_instance_valid(animation_tree), "Please assign a valid AnimationTree to AnimatedCharacter")
	assert(is_instance_valid(animation_player), "Please assign a valid AnimationPlayer to AnimatedCharacter")


func _process(_delta: float) -> void:
	update_animation_parameters()


func attack_animation(type: String, level: int = 1) -> bool:
	# Apply animation level and enable animation condition
	animation_tree.set("parameters/" + type.capitalize() + "/blend_position", level)
	animation_tree.set("parameters/conditions/" + type, true)
	
	var animation_length: float = animation_tree.get_animation("character_animations/" + type + "_" + str(level)).length
	await get_tree().create_timer(animation_length).timeout
	
	# Disable animation condition
	animation_tree.set("parameters/conditions/" + type, false)
	
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


func toggle_hide(_enabled: bool) -> void:
	pass
