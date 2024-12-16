class_name UtilitySystem
extends Node


static var instance: UtilitySystem = null
var current_state : String


func _ready() -> void:
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple utility systems found in scene, deleting last loaded")
		queue_free()


func calculate() -> void:
	var damage_done : int = Blackboard.get_data("damage_done") if Blackboard.get_data("damage_done") else 0
	var damage_blocked : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_killed : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_left_alive : int = Blackboard.get_data("enemies_alive") if Blackboard.get_data("enemies_alive") else 0
	
	if  (enemies_left_alive >= enemies_killed):
		current_state = "Avoiding"
	elif (damage_done >= damage_blocked):
		current_state = "Aggressive"
	else:
		current_state = "Defensive"
	
	print(current_state)
