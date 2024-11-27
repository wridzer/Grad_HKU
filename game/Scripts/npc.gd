class_name Npc
extends AnimatedCharacter


enum CombatType {ATTACK, DEFEND, AVOID}

@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable: Area2D = $Actionable
@onready var name_label: Label = $NameLabel
@onready var state_machine: StateMachine = $StateMachine

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var preferred_combat: CombatType
@export var adapatable_combat: CombatType
@export var unadaptable_combat: CombatType
@export_file var arrow_path: String

var direction: Vector2 = Vector2.ZERO
var affection: int
var saved_spawn_pos: Vector2

var _goals
var _current_goal
var _current_plan
var _current_plan_step = 0

var _actor

#
# On every loop this script checks if the current goal is still
# the highest priority. if it's not, it requests the action planner a new plan
# for the new high priority goal.
#
func _process(delta):
	var goal = _get_best_goal()
	if _current_goal == null or goal != _current_goal:
	# You can set in the blackboard any relevant information you want to use
	# when calculating action costs and status. I'm not sure here is the best
	# place to leave it, but I kept here to keep things simple.
		Blackboard.add_data("npc_location", _actor.position)

		_current_goal = goal
		_current_plan = $GoapPlanner.get_action_planner().get_plan(_current_goal)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)


func init(actor, goals: Array):
	_actor = actor
	_goals = goals


#
# Returns the highest priority goal available.
#
func _get_best_goal():
	var highest_priority

	for goal in $GoapPlanner._goals:
		if goal.is_valid() and (highest_priority == null or goal.priority() > highest_priority.priority()):
			highest_priority = goal

	return highest_priority


#
# Executes plan. This function is called on every game loop.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(plan, delta):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1

func _ready() -> void:
	# Destroy instance if any other instance exists that is following the player
	if Player.instance.following_npc:
		if Player.instance.following_npc.display_name == display_name:
			die()
	
	# Assert that all necessary dialogue has been assigned
	assert(is_instance_valid(idle_dialogue), "Please assign a valid idle_dialogue to " + name)
	assert(is_instance_valid(hit_dialogue), "Please assign a valid hit_dialogue to " + name)
	assert(is_instance_valid(following_dialogue), "Please assign a valid following_dialogue to " + name)
	
	# Assert that all combat preferences are unique types
	assert(preferred_combat != adapatable_combat, name + "'s preferred_combat and adapatable_combat are the same")
	assert(adapatable_combat != unadaptable_combat, name + "'s adapatable_combat and unadaptable_combat are the same")
	assert(unadaptable_combat != preferred_combat, name + "'s unadaptable_combat and preferred_combat are the same")
	
	health_component.immune.connect(set_immunity_animation_param)
	health_component.immune.connect(hit)
	health_component.die.connect(die)
	
	# Set display name label
	name_label.text = display_name
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true


func die() -> void:
	if Player.instance.following_npc == self:
		Player.instance.following_npc = null
	
	queue_free()


func hit(immune: bool) -> void:
	if immune:
		dialogue_manager.start_dialogue(hit_dialogue)


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	# TODO: npc animations
	animation_tree.set("parameters/conditions/idle", direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", direction != Vector2.ZERO)
	
	if direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", direction)
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
	
	super.update_animation_parameters()
