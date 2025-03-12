class_name MissionReport
extends Node2D


@onready var stats: RichTextLabel = $Control/Background/Stats
@onready var close_button: Button = $Control/Background/CloseButton


func do_mission_report() -> void:
	var data = Blackboard.get_data("sword_used_amount")
	var sword_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("shield_used_amount")
	var shield_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("bow_used_amount")
	var bow_used_amount: String = str(data) if data else "0"
	
	data = Blackboard.get_data("enemies_killed")
	var enemies_killed: String = str(data) if data else "0"
	
	data = Blackboard.get_data("enemies_alive")
	var enemies_alive: String = str(data) if data else "0"
	
	data = Blackboard.get_data("npc_choices")
	var npc_name: String = (data as Array)[-1] if data else "None"
	
	data = Blackboard.get_data("npc")
	var npc_level: String = str((data as Npc).level) if is_instance_valid(data) else "17"
	
	data = Blackboard.get_data("sword_level")
	var sword_level: String = str(data) if data else "17"
	
	data = Blackboard.get_data("shield_level")
	var shield_level: String = str(data) if data else "17"
	
	data = Blackboard.get_data("bow_level")
	var bow_level: String = str(data) if data else "17"
	
	
	stats.text = \
"Sword used: " + sword_used_amount + " times
Shield used: " + shield_used_amount + " times
Bow used: " + bow_used_amount + " times
Enemies slain: " + enemies_killed + "
Enemies left alive: " + enemies_alive + "
Companion taken: " + npc_name + "
Companion level: " + npc_level + "
Sword level: " + sword_level + "
Shield level: " + shield_level + "
Bow level: " + bow_level
	
	visible = true


func _on_close_button_button_down():
	visible = false
