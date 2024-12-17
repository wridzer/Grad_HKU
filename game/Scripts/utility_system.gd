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


func calculate_playstyle() -> void:
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


func calculate_weapon_usage() -> void:
	var sword_used : int = Blackboard.get_data("sword_used_amount") if Blackboard.get_data("sword_used_amount") else 0
	var shield_used : int = Blackboard.get_data("shield_used_amount") if Blackboard.get_data("shield_used_amount") else 0
	var bow_used : int = Blackboard.get_data("bow_used_amount") if Blackboard.get_data("bow_used_amount") else 0
	
	var total_use = bow_used + shield_used + sword_used
	
	if(total_use == 0):
		return
		
	var input_vector = Vector3()
	input_vector.x = sword_used/total_use*100
	input_vector.y = shield_used/total_use*100
	input_vector.z = bow_used/total_use*100
	
	
	var new_usage_percent_sword_shield_bow = [input_vector]
	var usage_percent_sword_shield_bow = Blackboard.get_data("usage_percent_sword_shield_bow")
	if !is_instance_valid(usage_percent_sword_shield_bow):
		usage_percent_sword_shield_bow = []
	usage_percent_sword_shield_bow[usage_percent_sword_shield_bow.size()] = new_usage_percent_sword_shield_bow
	Blackboard.add_data("usage_percent_sword_shield_bow", usage_percent_sword_shield_bow)
