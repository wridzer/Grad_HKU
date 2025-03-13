class_name UtilitySystem
extends Node


static var instance: UtilitySystem = null
var current_state: String


func _ready() -> void:
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple utility systems found in scene, deleting last loaded")
		queue_free()
	
	game_manager.return_to_hub.connect(calculate)


func calculate() -> void:
	calculate_playstyle()
	calculate_weapon_usage()
	calculate_level_ups()


func reset_values() -> void:
	var clear_values: Array[String] = [
		"damage_done",
		"amount_blocked",
		"enemies_alive",
		"sword_used_amount",
		"shield_used_amount",
		"bow_used_amount",
		"enemies_killed",
		"keys",
	]
	Blackboard.clear_utility_data(clear_values)


func calculate_playstyle() -> void:
	var sword_hit: int = Blackboard.get_data("sword_hit_enemy_amount") if Blackboard.get_data("sword_hit_enemy_amount") else 0
	var shield_hit: int = Blackboard.get_data("shield_hit_enemy_amount") if Blackboard.get_data("shield_hit_enemy_amount") else 0
	var arrow_hit: int = Blackboard.get_data("arrow_hit_enemy_amount") if Blackboard.get_data("arrow_hit_enemy_amount") else 0
	var damage_done: int = sword_hit + arrow_hit
	var damage_blocked: int = shield_hit
	var enemies_killed: int = Blackboard.get_data("enemies_killed") if Blackboard.get_data("enemies_killed") else 0
	var enemies_left_alive: int = Blackboard.get_data("enemies_alive") if Blackboard.get_data("enemies_alive") else 0
	var sword_used: int = Blackboard.get_data("sword_used_amount") if Blackboard.get_data("sword_used_amount") else 0
	var shield_used: int = Blackboard.get_data("shield_used_amount") if Blackboard.get_data("shield_used_amount") else 0
	var bow_used: int = Blackboard.get_data("bow_used_amount") if Blackboard.get_data("bow_used_amount") else 0
	
	var total_enemies: float = enemies_killed + enemies_left_alive
	var enemy_killed_percentage: float = enemies_killed / total_enemies * 100
	Blackboard.add_data("enemy_killed_percentage", enemy_killed_percentage)
	
	var mission_choices = Blackboard.get_data("mission_choices")
	if !is_instance_valid(mission_choices):
		mission_choices = []
	mission_choices = mission_choices as Array[DungeonGenerator.MissionType]
	
	# Calculate playstyle points, using 3's and 4's as weighting to avoid ties
	var points_aggressive: int = 0
	var points_defensive: int = 0
	var points_evasive: int = 0
	
	# Weapon usage heuristic
	match max(sword_used, shield_used, bow_used):
		sword_used:
			points_aggressive += 3
		shield_used:
			points_defensive += 3
		bow_used:
			points_evasive += 3
	
	# Mission type heuristic
	if mission_choices.count(DungeonGenerator.MissionType.ITEM) > mission_choices.count(DungeonGenerator.MissionType.SLAY):
		points_evasive += 3
		points_defensive += 3
	else:
		points_aggressive += 3
	
	# Enemy damaging heuristic
	if damage_done >= damage_blocked:
		points_aggressive += 4
	elif enemies_left_alive >= enemies_killed:
		points_evasive += 4
	else:
		points_defensive += 4
		
	# Total point calculation
	match max(points_aggressive, points_defensive, points_evasive):
		points_aggressive:
			current_state = "Aggressive"
		points_defensive:
			current_state = "Defensive"
		points_evasive:
			current_state = "Evasive"
	
	var playstyles: Array[String] = []
	if Blackboard.get_data("playstyles"):
		playstyles = Blackboard.get_data("playstyles")
	playstyles.append(current_state)
	Blackboard.add_data("playstyles", playstyles)


static func calculate_weapon_usage() -> Vector3:
	var sword_used: int = Blackboard.get_data("sword_used_amount") if Blackboard.get_data("sword_used_amount") else 0
	var shield_used: int = Blackboard.get_data("shield_used_amount") if Blackboard.get_data("shield_used_amount") else 0
	var bow_used: int = Blackboard.get_data("bow_used_amount") if Blackboard.get_data("bow_used_amount") else 0
	
	var total_use: float = bow_used + shield_used + sword_used
	
	if total_use == 0:
		Blackboard.add_data("usage_percent_sword_shield_bow", Vector3.ZERO)
		return Vector3.ZERO
	
	var usage_percent_sword_shield_bow = Vector3(
		sword_used / total_use * 100,
		shield_used / total_use * 100,
		bow_used / total_use * 100
	)
	
	Blackboard.add_data("usage_percent_sword_shield_bow", usage_percent_sword_shield_bow)
	return usage_percent_sword_shield_bow


static func update_npc_playstyle_priorities() -> void:
	var npc = Blackboard.get_data("npc")
	if !is_instance_valid(npc):
		return
	npc = npc as Npc
	var player_weapon_usage: Vector3 = calculate_weapon_usage()
	var possible_playstyles = npc.adapatable_playstyle + npc.preferred_playstyle
	match possible_playstyles:
		1: # Aggressive + Defensive
			Blackboard.add_data("slash_priority", npc.base_slash_priority + (player_weapon_usage.y * 0.5))
			Blackboard.add_data("block_priority", npc.base_block_priority + (player_weapon_usage.z * 0.5))
		2: # Aggressive + Evasive
			Blackboard.add_data("slash_priority", npc.base_slash_priority + (player_weapon_usage.y * 0.5))
			Blackboard.add_data("shoot_priority", npc.base_shoot_priority + (player_weapon_usage.x * 0.5))
		3: # Defensive + Evasive
			Blackboard.add_data("block_priority", npc.base_block_priority + (player_weapon_usage.z * 0.5))
			Blackboard.add_data("shoot_priority", npc.base_shoot_priority + (player_weapon_usage.x * 0.5))


static func update_aggro() -> void:
	var enemies_killed: int = Blackboard.get_data("enemies_killed_in_room") if Blackboard.get_data("enemies_killed") else 0
	var enemies_left_alive: int = Blackboard.get_data("enemies_in_room") if Blackboard.get_data("enemies_alive") else 0
	if enemies_killed == 0 && enemies_left_alive == 0:
		return
	
	var total_enemies: float = enemies_killed + enemies_left_alive
	var enemy_killed_percentage: float = enemies_killed / total_enemies * 100
	Blackboard.add_data("enemy_killed_percentage_in_room", enemy_killed_percentage)


static func calculate_level_ups() -> void:
	var last_playstyle: String = get_last_playstyle()
	
	var sword_level: int = Blackboard.get_data("sword_level") if Blackboard.get_data("sword_level") else 1
	var shield_level: int = Blackboard.get_data("shield_level") if Blackboard.get_data("shield_level") else 1
	var bow_level: int = Blackboard.get_data("bow_level") if Blackboard.get_data("bow_level") else 1
	
	var npc = Blackboard.get_data("npc")
	if !is_instance_valid(npc):
		return
	npc = npc as Npc
	
	match last_playstyle:
		"Aggressive":
			if npc.adapatable_playstyle == Npc.Playstyle.EVASIVE:
				npc.level = min(3, npc.level + 1)
			elif npc.preferred_playstyle == Npc.Playstyle.AGGRESSIVE:
				npc.level = min(2, npc.level + 1)
			else:
				npc.level = max(1, npc.level - 1)
			
			Blackboard.add_data("sword_level", min(3, sword_level + 1))
			Blackboard.add_data("shield_level", max(1, shield_level - 1))
			Blackboard.add_data("bow_level", max(1, bow_level - 1))
		"Defensive":
			if npc.adapatable_playstyle == Npc.Playstyle.AGGRESSIVE:
				npc.level = min(3, npc.level + 1)
			elif npc.preferred_playstyle == Npc.Playstyle.DEFENSIVE:
				npc.level = min(2, npc.level + 1)
			else:
				npc.level = max(1, npc.level - 1)
			
			Blackboard.add_data("shield_level", min(3, sword_level + 1))
			Blackboard.add_data("sword_level", max(1, sword_level - 1))
			Blackboard.add_data("bow_level", max(1, bow_level - 1))
		"Evasive":
			if npc.adapatable_playstyle == Npc.Playstyle.DEFENSIVE:
				npc.level = min(3, npc.level + 1)
			elif npc.preferred_playstyle == Npc.Playstyle.EVASIVE:
				npc.level = min(2, npc.level + 1)
			else:
				npc.level = max(1, npc.level - 1)
			
			Blackboard.add_data("bow_level", min(3, sword_level + 1))
			Blackboard.add_data("sword_level", max(1, sword_level - 1))
			Blackboard.add_data("shield_level", max(1, shield_level - 1))


static func get_last_playstyle() -> String:
	var playstyles: Array[String] = []
	if Blackboard.get_data("playstyles"):
		playstyles = Blackboard.get_data("playstyles")
	return playstyles[-1]
