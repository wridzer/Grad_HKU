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
	calculate_playstyle()
	calculate_weapon_usage()
	reset_values()


func reset_values() -> void:
	var clear_values: Array[String] = [
		"damage_done",
		"amount_blocked",
		"enemies_alive",
		"sword_used_amount",
		"shield_used_amount",
		"bow_used_amount"
	]
	Blackboard.clear_utility_data(clear_values)


func calculate_playstyle() -> void:
	var damage_done : int = Blackboard.get_data("damage_done") if Blackboard.get_data("damage_done") else 0
	var damage_blocked : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_killed : int = Blackboard.get_data("amount_blocked") if Blackboard.get_data("amount_blocked") else 0
	var enemies_left_alive : int = Blackboard.get_data("enemies_alive") if Blackboard.get_data("enemies_alive") else 0
	
	var enemy_killed_percentage = enemies_killed / (enemies_killed + enemies_left_alive) * 100
	Blackboard.add_data("enemy_killed_percentage", enemy_killed_percentage)
	
	if  (enemies_left_alive >= enemies_killed):
		current_state = "Avoiding"
	elif (damage_done >= damage_blocked):
		current_state = "Aggressive"
	else:
		current_state = "Defensive"
	
	var data: Array[String] = []
	if(Blackboard.get_data("playstyle")):
		data = Blackboard.get_data("playstyle")
	data.append(current_state)
	Blackboard.add_data("playstyle", data)


func calculate_weapon_usage() -> void:
	var sword_used : int = Blackboard.get_data("sword_used_amount") if Blackboard.get_data("sword_used_amount") else 0
	var shield_used : int = Blackboard.get_data("shield_used_amount") if Blackboard.get_data("shield_used_amount") else 0
	var bow_used : int = Blackboard.get_data("bow_used_amount") if Blackboard.get_data("bow_used_amount") else 0
	
	var total_use: float = bow_used + shield_used + sword_used
	
	if(total_use == 0):
		return
	
	var usage_percent_sword_shield_bow = Vector3(
		sword_used / total_use * 100,
		shield_used / total_use * 100,
		bow_used / total_use * 100
	)
	
	var data: Array[Vector3] = []
	if(Blackboard.get_data("usage_percent_sword_shield_bow")):
		data = Blackboard.get_data("usage_percent_sword_shield_bow")
	data.append(usage_percent_sword_shield_bow)
	Blackboard.add_data("usage_percent_sword_shield_bow", data)
