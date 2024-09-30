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
const FOLLOW_DISTANCE := 10.0

var is_talking: bool = false

var saved_spawn_pos: Vector2


func _ready() -> void:
	# Assert that all necessary dialogue has been assigned
	assert(is_instance_valid(action_dialogue), "Please assign a valid action_dialogue to " + name)
	assert(is_instance_valid(hit_dialogue), "Please assign a valid hit_dialogue to " + name)
	assert(is_instance_valid(following_dialogue), "Please assign a valid following_dialogue to " + name)
	
	# Connect signals
	health_component.die.connect(die)
	health_component.hit.connect(hit)
	actionable.action.connect(start_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	game_manager.npc_follow.connect(follow)
	game_manager.npc_stop_following.connect(stop_following)
	game_manager.spawn.connect(spawn)
	game_manager.switch_level_cleanup.connect(cleanup)
	
	# Set display name label
	name_label.text = display_name


func _physics_process(delta: float) -> void:
	# Follow the player
	if Player.instance.following_npc == self:
		var player_pos: Vector2 = Player.instance.get_position()
		if position.distance_to(player_pos) > FOLLOW_DISTANCE:
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
	if Player.instance.following_npc != self:
		DialogueManager.show_dialogue_balloon(action_dialogue)
	elif Player.instance.following_npc == self:
		DialogueManager.show_dialogue_balloon(following_dialogue)
	is_talking = true


func _on_dialogue_ended(resource: DialogueResource) -> void:
	is_talking = false


func follow() -> void:
	if is_talking:
		if !Player.instance.following_npc:
			Player.instance.following_npc = self
		else:
			DialogueManager.show_dialogue_balloon(action_dialogue, "already_following")


func stop_following() -> void:
	if is_talking && Player.instance.following_npc == self:
		Player.instance.following_npc = null


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	if Player.instance.following_npc == self:
		saved_spawn_pos = spawn_pos
		self.position = spawn_pos + npc_offset


func cleanup() -> void:
	if Player.instance.following_npc != self:
		die()
