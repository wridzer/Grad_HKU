class_name Npc
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable: Area2D = $Actionable
@onready var name_label: Label = $NameLabel

@export var display_name: String
@export var action_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource

const SPEED := 2500.0

var is_talking: bool = false
var following: bool = false


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)
	actionable.action.connect(start_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	game_manager.npc_follow.connect(follow)
	
	name_label.text = display_name


func _physics_process(delta: float) -> void:
	if following:
		var player_pos: Vector2 = Player.instance.get_position()
		if position.distance_to(player_pos) > 10:
			var target_pos: Vector2 = (player_pos - position).normalized()
			velocity = target_pos * SPEED * delta
			move_and_slide()
			look_at(player_pos)


func die() -> void:
	queue_free()


func hit() -> void:
	input_manager.toggle_input(false)
	DialogueManager.show_dialogue_balloon(hit_dialogue, "start")
	is_talking = true


func start_dialogue() -> void:
	input_manager.toggle_input(false)
	if !following:
		DialogueManager.show_dialogue_balloon(action_dialogue)
	elif following:
		DialogueManager.show_dialogue_balloon(following_dialogue)
	is_talking = true


func _on_dialogue_ended(resource: DialogueResource) -> void:
	is_talking = false


func follow() -> void:
	if is_talking:
		following = true
