class_name UtilitySystem
extends Node

static var instance: UtilitySystem = null
var current_state : String

func _ready() -> void:
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple players found in scene, deleting last loaded")
		queue_free()

func calculate() -> void:
	var damage_done : int = Blackboard.get_data("damage_done") if Blackboard.get_data("damage_done") else 0
	var damage_blocked : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_killed : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_left_alive : int = Blackboard.get_data("enemies_alive") if Blackboard.get_data("enemies_alive") else 0
	
	if (damage_blocked > damage_done):
		current_state = "Defensive"
	elif  (enemies_left_alive > enemies_killed):
		current_state = "Avoiding"
	else:
		current_state = "Aggressive"
	
	print(current_state)

func reset_values() -> void:
	Blackboard.clear_data()
	Blackboard.save_data()
	print("data cleared")
